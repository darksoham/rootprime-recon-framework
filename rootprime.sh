#!/usr/bin/env bash

# Root Prime Recon Framework v2
# Advanced Recon Toolkit

set -e

OUTPUT="output"

RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

banner() {
clear
echo -e "${GREEN}"
echo "██████╗  ██████╗  ██████╗ ████████╗"
echo "██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝"
echo "██████╔╝██║   ██║██║   ██║   ██║"
echo "██╔══██╗██║   ██║██║   ██║   ██║"
echo "██║  ██║╚██████╔╝╚██████╔╝   ██║"
echo "╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝"
echo ""
echo "ROOT PRIME RECON FRAMEWORK v2"
echo -e "${RESET}"
}

install_tools(){

echo -e "${CYAN}Installing recon tools...${RESET}"

sudo apt update

sudo apt install -y subfinder assetfinder amass httpx gau waybackurls \
naabu nuclei whatweb ffuf gobuster hakrawler jq

echo -e "${GREEN}Tools installed${RESET}"

}

subdomain_enum(){

read -p "Target domain: " domain

mkdir -p $OUTPUT/$domain
cd $OUTPUT/$domain

echo -e "${BLUE}Subdomain enumeration...${RESET}"

subfinder -d $domain -silent > subfinder.txt &
assetfinder --subs-only $domain > assetfinder.txt &
amass enum -passive -d $domain > amass.txt &

wait

cat *.txt | sort -u > subdomains.txt

echo -e "${GREEN}Subdomains collected${RESET}"

cd ../../
}

live_hosts(){

read -p "Target domain: " domain

cd $OUTPUT/$domain

echo -e "${BLUE}Checking live hosts...${RESET}"

cat subdomains.txt | httpx -silent > live.txt

cd ../../
}

js_endpoints(){

read -p "Target domain: " domain

cd $OUTPUT/$domain

echo -e "${BLUE}Collecting JS files...${RESET}"

cat live.txt | gau | grep "\.js" > js_files.txt

echo -e "${BLUE}Extracting endpoints...${RESET}"

cat js_files.txt | xargs -I % curl -s % | \
grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" \
> js_endpoints.txt

cd ../../
}

api_finder(){

read -p "Target domain: " domain

cd $OUTPUT/$domain

echo -e "${BLUE}Searching API endpoints...${RESET}"

grep -Ei "api|v1|v2|graphql|rest" urls.txt \
> api_endpoints.txt || true

cd ../../
}

admin_finder(){

read -p "Target domain: " domain

cd $OUTPUT/$domain

echo -e "${BLUE}Finding admin panels...${RESET}"

cat live.txt | while read url
do
ffuf -u $url/FUZZ -w /usr/share/wordlists/dirb/common.txt \
-mc 200 -t 50 2>/dev/null | \
grep -Ei "admin|dashboard|panel" >> admin_panels.txt
done

cd ../../
}

menu(){

echo ""
echo "1. Install Tools"
echo "2. Subdomain Enumeration"
echo "3. Live Host Detection"
echo "4. JS Endpoint Finder"
echo "5. API Endpoint Finder"
echo "6. Admin Panel Finder"
echo "0. Exit"
echo ""

read -p "Select option: " opt

case $opt in

1) install_tools ;;
2) subdomain_enum ;;
3) live_hosts ;;
4) js_endpoints ;;
5) api_finder ;;
6) admin_finder ;;
0) exit ;;

*) echo "Invalid option"

esac
}

banner

while true
do
menu
done
