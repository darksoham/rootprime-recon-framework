#!/usr/bin/env bash

# Root Prime Recon Framework
# Author: Root Prime

set -e

OUTPUT_DIR="output"

banner() {
echo "=========================================="
echo "        ROOT PRIME RECON FRAMEWORK"
echo "=========================================="
}

check_tool() {
if ! command -v "$1" >/dev/null 2>&1; then
echo "[!] $1 not found. Installing..."
sudo apt update
sudo apt install -y "$1"
else
echo "[+] $1 installed"
fi
}

install_tools() {

echo "[*] Installing required tools..."

check_tool subfinder
check_tool assetfinder
check_tool amass
check_tool httpx
check_tool gau
check_tool waybackurls
check_tool naabu
check_tool nuclei
check_tool whatweb
check_tool ffuf
check_tool gobuster

echo "[+] Tool installation finished"

}

subdomain_scan() {

read -rp "Enter Target Domain: " domain

mkdir -p "$OUTPUT_DIR/$domain"
cd "$OUTPUT_DIR/$domain"

echo "[+] Running Subfinder"
subfinder -d "$domain" -silent > subfinder.txt || true

echo "[+] Running Assetfinder"
assetfinder --subs-only "$domain" > assetfinder.txt || true

echo "[+] Running Amass"
amass enum -passive -d "$domain" > amass.txt || true

echo "[+] Merging Subdomains"
cat subfinder.txt assetfinder.txt amass.txt | sort -u > all_subdomains.txt

echo "[+] Checking Live Hosts"
cat all_subdomains.txt | httpx -status-code -silent > live_status.txt || true

echo "[+] Filtering Status Codes"

grep "200" live_status.txt > status_200.txt || true
grep "301" live_status.txt > status_301.txt || true
grep "403" live_status.txt > status_403.txt || true

echo "[+] Finding Login Pages"

grep -Ei "login|signin|auth|account|dashboard" live_status.txt > login_pages.txt || true

echo "[+] Technology Detection"

while read -r url; do
whatweb "$url" >> technologies.txt 2>/dev/null || true
done < <(awk '{print $1}' status_200.txt)

echo "[+] Vulnerability Scan"

awk '{print $1}' status_200.txt | nuclei -silent >> vulnerabilities.txt || true

echo "[+] Scan Completed"

cd ../../
}

full_recon() {

read -rp "Enter Target Domain: " domain

mkdir -p "$OUTPUT_DIR/$domain"
cd "$OUTPUT_DIR/$domain"

echo "[+] Subdomain Enumeration"

subfinder -d "$domain" -silent > subfinder.txt || true
assetfinder --subs-only "$domain" > assetfinder.txt || true
amass enum -passive -d "$domain" > amass.txt || true

cat *.txt | sort -u > subdomains.txt

echo "[+] Live Host Detection"

cat subdomains.txt | httpx -silent > live_hosts.txt || true

echo "[+] URL Collection"

cat live_hosts.txt | gau > urls.txt || true

echo "[+] Directory Discovery"

while read -r url; do
ffuf -u "$url/FUZZ" -w /usr/share/wordlists/dirb/common.txt -mc 200 >> directories.txt 2>/dev/null || true
done < live_hosts.txt

echo "[+] Port Scanning"

cat live_hosts.txt | naabu -silent > open_ports.txt || true

echo "[+] Vulnerability Scan"

cat live_hosts.txt | nuclei -silent > vulnerabilities.txt || true

echo "[+] Full Recon Finished"

cd ../../
}

menu() {

echo ""
echo "1. Install Required Tools"
echo "2. Subdomain Recon"
echo "3. Full Recon Automation"
echo "0. Exit"
echo ""

read -rp "Select Option: " option

case $option in

1) install_tools ;;
2) subdomain_scan ;;
3) full_recon ;;
0) exit ;;
*) echo "Invalid option" ;;

esac

}

banner

while true
do
menu
done
