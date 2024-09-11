# Subdomain Enumeration Script

This Bash script automates subdomain enumeration, live domain checking, port scanning, and data extraction from the Wayback Machine. It integrates various tools such as `assetfinder`, `httprobe`, `subjack`, `nmap`, and `waybackurls` to conduct reconnaissance on a target domain.

## Features

- Automatically creates directory structures to organize the results.
- Gathers subdomains using `assetfinder` (optional `amass` integration).
- Probes for live subdomains using `httprobe`.
- Scans for subdomain takeover vulnerabilities using `subjack`.
- Performs port scanning using `nmap`.
- Extracts archived data from the Wayback Machine using `waybackurls` and organizes files by type (e.g., `.js`, `.php`, `.json`).
- Optionally captures screenshots of live subdomains using `EyeWitness` or `GoWitness`.

## Prereq

Ensure you have the following tools installed:

- **Go** (required for `assetfinder`, `httprobe`, `subjack`, and `waybackurls`)

To install Go, visit: [Go Installation](https://golang.org/dl/)

### **Required Tools**:

1. **Assetfinder**:
   - Install via Go:
     ```bash
     go install github.com/tomnomnom/assetfinder@latest
     ```

2. **Httprobe**:
   - Install via Go:
     ```bash
     go install github.com/tomnomnom/httprobe@latest
     ```

3. **Subjack** (for subdomain takeover detection):
   - Install via Go:
     ```bash
     go install github.com/haccer/subjack@latest
     ```

4. **Nmap**:
   - Install using your package manager:
     ```bash
     sudo apt-get install nmap  # for Debian/Ubuntu
     sudo yum install nmap      # for CentOS/RHEL
     ```

5. **Waybackurls**:
   - Install via Go:
     ```bash
     go install github.com/tomnomnom/waybackurls@latest
     ```

### **Optional Tools**:

1. **Amass** (for additional subdomain enumeration):
   - Install via:
     ```bash
     sudo apt-get install amass
     ```

2. **EyeWitness** (for screenshots of live domains):
   - Follow the instructions on [EyeWitness GitHub](https://github.com/FortyNorthSecurity/EyeWitness) for installation.

3. **GoWitness** (an alternative to EyeWitness):
   - Install via Go:
     ```bash
     go install github.com/sensepost/gowitness@latest
     ```

   - Make sure to adjust the path in the script if using **GoWitness** instead of **EyeWitness**.

## Installation

1. Clone the repository or download the script:

```bash
git clone https://github.com/CloudyKhan/subdomain-enum.git
```
2. Navigate to the folder containing the script:

```bash
cd subdomain-enum
````
3. Make script executable

```bash
chmod +x subdomain-enum.sh
```
## Usage

Run the script by providing the domain you want to enumerate subdomains for:
```bash
./subdomain-enum.sh <domain>
```

Uncomment or comment sections in the script as needed to your preferences.

## Output
The results should be saved in the following directory structure 
```
<domain>/recon/
  ├── scans/
  ├── httprobe/
  │   └── alive.txt
  ├── potential_takeovers/
  │   └── potential_takeovers.txt
  ├── wayback/
  │   ├── wayback_output.txt
  │   ├── params/
  │   │   └── wayback_params.txt
  │   └── extensions/
  │       ├── js.txt
  │       ├── php.txt
  │       ├── aspx.txt
  │       ├── json.txt
  │       ├── html.txt
  └── final.txt
```
