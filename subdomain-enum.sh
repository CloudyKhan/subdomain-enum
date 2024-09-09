#!/bin/bash

# Ensure a domain name is provided as an argument
url=$1
if [ -z "$url" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

# Create necessary directories if they don't exist
if [ ! -d "$url" ]; then
  echo "[+] Creating directory for domain: $url"
  mkdir -p $url/recon
fi

# Ensure all necessary subdirectories are present for organization
mkdir -p $url/recon/scans $url/recon/httprobe $url/recon/potential_takeovers $url/recon/wayback/params $url/recon/wayback/extensions

# Ensure essential files exist, create them if they don't
touch $url/recon/httprobe/alive.txt $url/recon/final.txt

# Subdomain enum with assetfinder
echo "[+] Harvesting subdomains with assetfinder for $url..."
assetfinder $url > $url/recon/assets.txt

# Filter out unrelated domains and keep only subdomains for the target domain
echo "[+] Filtering subdomains..."
cat $url/recon/assets.txt | grep "\.$url$" >> $url/recon/final.txt
rm $url/recon/assets.txt

# Optional amass scan commented out, can be re-enabled for additional subdomain discovery
# echo "[+] Double checking for subdomains with amass..."
# amass enum -d $url >> $url/recon/f.txt
# sort -u $url/recon/f.txt >> $url/recon/final.txt
# rm $url/recon/f.txt

# Check if subdomains are alive using httprobe
echo "[+] Probing for alive domains with httprobe..."
cat $url/recon/final.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/httprobe/a.txt
sort -u $url/recon/httprobe/a.txt > $url/recon/httprobe/alive.txt
rm $url/recon/httprobe/a.txt

# Optional: Run GoWitness for screenshots of alive domains
# Uncomment the following lines if you want to use GoWitness to capture screenshots
# Make sure GoWitness is installed on your system (`go install github.com/sensepost/gowitness@latest`)

# echo "[+] Running GoWitness for screenshots of live domains..."
# gowitness file -f $url/recon/httprobe/alive.txt -d $url/recon/gowitness/ --log-level fatal


# Check for potential subdomain takeovers using subjack
echo "[+] Checking for possible subdomain takeovers..."
touch $url/recon/potential_takeovers/potential_takeovers.txt
subjack -w $url/recon/final.txt -t 100 -timeout 30 -ssl -c ~/go/src/github.com/haccer/subjack/fingerprints.json -v 3 -o $url/recon/potential_takeovers/potential_takeovers.txt

# Scan for open ports on the alive subdomains using nmap
echo "[+] Scanning for open ports with nmap..."
nmap -iL $url/recon/httprobe/alive.txt -T4 -oA $url/recon/scans/scanned.txt

# Scraping wayback machine data for URL recon
echo "[+] Scraping Wayback Machine data for $url..."
cat $url/recon/final.txt | waybackurls >> $url/recon/wayback/wayback_output.txt
sort -u $url/recon/wayback/wayback_output.txt > $url/recon/wayback/wayback_output_sorted.txt
mv $url/recon/wayback/wayback_output_sorted.txt $url/recon/wayback/wayback_output.txt

# Extract and compile possible parameters from the wayback data
echo "[+] Compiling possible parameters from wayback data..."
cat $url/recon/wayback/wayback_output.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >> $url/recon/wayback/params/wayback_params.txt
for line in $(cat $url/recon/wayback/params/wayback_params.txt); do echo "$line="; done

# Pull and compile various file types from the wayback data (e.g., JS, PHP, ASPX, JSON files)
echo "[+] Extracting and compiling files from wayback data..."
for line in $(cat $url/recon/wayback/wayback_output.txt); do
	ext="${line##*.}"
	if [[ "$ext" == "js" ]]; then
		echo $line >> $url/recon/wayback/extensions/js1.txt
		sort -u $url/recon/wayback/extensions/js1.txt >> $url/recon/wayback/extensions/js.txt
	fi
	if [[ "$ext" == "html" ]];then
		echo $line >> $url/recon/wayback/extensions/html1.txt
		sort -u $url/recon/wayback/extensions/html1.txt >> $url/recon/wayback/extensions/html.txt
	fi
	if [[ "$ext" == "json" ]];then
		echo $line >> $url/recon/wayback/extensions/json1.txt
		sort -u $url/recon/wayback/extensions/json1.txt >> $url/recon/wayback/extensions/json.txt
	fi
	if [[ "$ext" == "php" ]];then
		echo $line >> $url/recon/wayback/extensions/php1.txt
		sort -u $url/recon/wayback/extensions/php1.txt >> $url/recon/wayback/extensions/php.txt
	fi
	if [[ "$ext" == "aspx" ]];then
		echo $line >> $url/recon/wayback/extensions/aspx1.txt
		sort -u $url/recon/wayback/extensions/aspx1.txt >> $url/recon/wayback/extensions/aspx.txt
	fi
done

# Clean up intermediate files created during file extraction
rm $url/recon/wayback/extensions/js1.txt
rm $url/recon/wayback/extensions/html1.txt
rm $url/recon/wayback/extensions/json1.txt
rm $url/recon/wayback/extensions/php1.txt
rm $url/recon/wayback/extensions/aspx1.txt

# Optional: Run eyewitness for screenshots of alive domains (commented out)
# echo "[+] Running EyeWitness for screenshots of live domains..."
# python3 EyeWitness/EyeWitness.py --web -f $url/recon/httprobe/alive.txt -d $url/recon/eyewitness --resolve
