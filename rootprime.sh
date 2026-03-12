#!/bin/bash

clear

echo "=========================================="
echo "        ROOT PRIME RECON FRAMEWORK"
echo "=========================================="

OUTPUT="output"

install_tool() {

if ! command -v $1 &> /dev/null
then
echo "[!] $1 not installed. Installing..."
sudo apt install $1 -y
else
echo "[+] $1 already installed"
fi

}

install_tools() {

echo "Installing required tools..."

install_tool subfinder
install_tool assetfinder
install_tool amass
install_tool httpx
install_tool gau
install_tool waybackurls
install_tool naabu
install_tool nuclei
install_tool whatweb
install_tool ffuf
install_tool gobuster

echo "Tool installation finished"

}

subdomain_scan() {

read -p "Enter Target Domain: " domain

mkdir -p $OUTPUT/$domain
cd $OUTPUT/$domain

echo "[+] Running Subfinder"
subfinder -d $domain -silent > subfinder.txt

echo "[+] Running Assetfinder"
assetfinder --subs-only $domain > assetfinder.txt

echo "[+] Running Amass"
amass enum -passive -d $domain > amass.txt

echo "[+] Merging Subdomains"
cat subfinder.txt assetfinder.txt amass.txt | sort -u > all_subdomains.txt

echo "[+] Checking Live Hosts"
cat all_subdomains.txt | httpx -status-code -silent > live_status.txt

echo "[+] Filtering Status Codes"

grep "200" live_status.txt > status_200.txt
grep "301" live_status.txt > status_301.txt
grep "403" live_status.txt > status_403.txt

echo "[+] Finding Login Pages"

grep -Ei "login|signin|auth|account|dashboard" live_status.txt > login_pages.txt

echo "[+] Technology Detection"

cat status_200.txt | awk '{print $1}' | while read url
do
whatweb $url >> technologies.txt
done

echo "[+] Vulnerability Scan"

cat status_200.txt | awk '{print $1}' | nuclei -silent >> vulnerabilities.txt

echo "Scan Completed"

cd ../../

}

full_recon() {

read -p "Enter Target Domain: " domain

mkdir -p $OUTPUT/$domain
cd $OUTPUT/$domain

echo "[+] Subdomain Enumeration"

subfinder -d $domain -silent > subfinder.txt
assetfinder --subs-only $domain > assetfinder.txt
amass enum -passive -d $domain > amass.txt

cat *.txt | sort -u > subdomains.txt

echo "[+] Live Host Detection"

cat subdomains.txt | httpx -silent > live_hosts.txt

echo "[+] URL Collection"

cat live_hosts.txt | gau > urls.txt

echo "[+] Directory Discovery"

cat live_hosts.txt | while read url
do
ffuf -u $url/FUZZ -w /usr/share/wordlists/dirb/common.txt -mc 200 >> directories.txt
done

echo "[+] Port Scanning"

cat live_hosts.txt | naabu -silent > open_ports.txt

echo "[+] Vulnerability Scan"

cat live_hosts.txt | nuclei -silent > vulnerabilities.txt

echo "Full Recon Finished"

cd ../../

}

menu() {

echo ""
echo "1. Install Required Tools"
echo "2. Subdomain Recon"
echo "3. Full Recon Automation"
echo "0. Exit"
echo ""

read -p "Select Option: " option

case $option in

1) install_tools ;;
2) subdomain_scan ;;
3) full_recon ;;
0) exit ;;
*) echo "Invalid option" ;;

esac

}

while true
do
menu
done