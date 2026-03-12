![GitHub stars](https://img.shields.io/github/stars/USERNAME/rootprime-recon-framework)
![GitHub forks](https://img.shields.io/github/forks/USERNAME/rootprime-recon-framework)
![GitHub issues](https://img.shields.io/github/issues/USERNAME/rootprime-recon-framework)
![License](https://img.shields.io/github/license/USERNAME/rootprime-recon-framework)

# rootprime-recon-framework
Root Prime Recon Framework is a powerful automated recon toolkit that combines multiple security tools to perform fast and organized reconnaissance for bug bounty hunters and pentesters.


# Root Prime Recon Framework

Root Prime Recon Framework is an automated reconnaissance toolkit designed for bug bounty hunters, penetration testers, and security researchers.

It automates the information gathering phase by running multiple recon tools and organizing results into structured output.

---

## Features

* Automated reconnaissance workflow
* Subdomain enumeration using multiple tools
* Live host detection
* Status code filtering
* Login page detection
* URL collection
* Directory discovery
* Technology detection
* Vulnerability scanning
* Organized output structure
* Menu based interface
* Automatic tool installation

---

## Recon Workflow

Target Domain
↓
Subdomain Enumeration
↓
Subdomain Filtering
↓
Live Host Detection
↓
Status Code Filtering
↓
Login Page Discovery
↓
URL Collection
↓
Port Scanning
↓
Technology Detection
↓
Vulnerability Scanning

---

## Tools Used

### Subdomain Enumeration

* subfinder
* assetfinder
* amass
* sublist3r
* chaos
* crobat
* github-subdomains
* github-endpoints

### URL Collection

* gau
* waybackurls

### Scanning Tools

* httpx
* naabu
* nuclei
* whatweb
* ffuf
* gobuster

---

## Installation

Clone the repository:

```
git clone https://github.com/darksoham/rootprime-recon-framework.git
```

Enter the directory:

```
cd rootprime-recon-framework
```

Give execute permission:

```
chmod +x rootprime.sh
```

Run the tool:

```
./rootprime.sh
```

---

## Usage

When the tool starts a menu will appear:

```
1. Install Required Tools
2. Subdomain Recon
3. Full Recon Automation
0. Exit
```

Choose an option and follow the prompts.

---

## Output Structure

```
output/
   target.com/
      subfi
```
