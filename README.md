# 🚀 NEXPORT — Intelligent Threat Analysis Suite

> **Professional Network Port Intelligence & Live Threat Intelligence Platform**
>
> **Developed by:** [Steven Osama](https://github.com/stevenosama025-sudo) (Alias: **zeroman**)
> **Official Repository:** [https://github.com/stevenosama025-sudo/nexport.git](https://github.com/stevenosama025-sudo/nexport.git)
> **Copyright:** © 2026 Steven Osama (zeroman). All rights reserved.
> **Lead Developer:** Steven Osama | **GitHub:** [@stevenosama025-sudo](https://github.com/stevenosama025-sudo)

---

**NEXPORT** is an advanced, high-performance security reconnaissance and automation tool tailored for **Kali Linux** and security operations. Designed and engineered by cybersecurity professional **Steven Osama (zeroman)**, it bridges the gap between raw network scanning and actionable vulnerability intelligence.

NEXPORT features **Live Threat Intelligence** — real-time integration with the **Shodan API** and **CIRCL CVE API** that automatically enriches every scan with external perspective data, live CVE hits on detected service versions, and internet-facing vulnerability telemetry. NEXPORT now pulls live intelligence from the open threat landscape and injects it directly into the cyberpunk terminal UI.

Wrapped in a stunning, high-contrast **Cyberpunk ANSI neon interface**, NEXPORT ensures maximum data scannability under critical engagement timelines.

---

## ⚡ Key Features

* 📦 **System-Wide Auto Integration:** Advanced installer deploys a native wrapper granting full execution rights from anywhere in the system.
* 🛠️ **Strict Modular Architecture:** Code logic, UI rendering, Nmap engines, databases, and now live API clients are strictly separated across clean, self-documenting `.sh` files with **zero code bloat**.
* 🗄️ **Massive Vulnerability Database:** Deeply mapped catalog linking thousands of ports to risk indices (HIGH/MED/LOW), encryption compliance flags (`[CLR]`), and known real-world exploits.
* 🔍 **Intelligent Live Nmap Parser:** Wraps Nmap into 6 professional deployment modes (Quick, Standard, Full, Stealth, Vuln, Custom) with automated version extraction and lookup integration.
* 🌐 **Live Shodan Integration *(NEW)*:** Automatically queries the Shodan API for any public IP after a scan — fetches open ports, service banners, organization data, ISP, geolocation, and live CVEs from Shodan's internet-wide scan perspective.
* 🛡️ **Live CVE Lookup via CIRCL *(NEW)*:** Detects service version strings from nmap output and fires lightweight HTTP requests to `cve.circl.lu` to retrieve the top 5 most critical live CVE IDs for each detected version — in real time.
* 📊 **Production-Ready Reports:** Instantly exports scan findings to `JSON`, `CSV`, `Markdown (.md)`, or searchable `HTML` for client reporting.
* 🎯 **Gamified Training Engine:** Interactive Quiz Mode trains junior SOC analysts and penetration testers on critical ports and threat scenarios.

---

## 🌐 Live Threat Intelligence — Architecture

`modules/api_intel.sh` is the intelligence layer in NEXPORT. It operates as a **post-scan enrichment pipeline** and a standalone command, providing two independent data streams:

```
  [ nmap scan complete ]
         │
         ▼
  _summarize_nmap_output()          ← local database analysis (unchanged)
         │
         ▼
  run_live_threat_intel()           ← NEW: api_intel.sh
    ├── Shodan Host API             ← external ports, banners, org, vulns
    └── CIRCL CVE search API       ← live CVE IDs per detected version
```

**Key design properties:**
- Graceful degradation: if the network is unreachable, the section is silently skipped without disrupting the existing scan output.
- Private/RFC1918 addresses are automatically excluded from external Shodan lookups.
- No mandatory dependencies: `jq` is used for full JSON parsing when available; a regex-based fallback covers systems without it.
- API key stored with `chmod 600` in `~/.nexport/config` — never echoed to the terminal.

---

## 🔑 Shodan API Setup

```bash
# Save your Shodan API key (stored securely in ~/.nexport/config)
nexport intel set-key YOUR_SHODAN_API_KEY

# Alternatively, export it for the current session only:
export SHODAN_API_KEY=YOUR_SHODAN_API_KEY

# Remove a saved key:
nexport intel clear-key
```

> Get a free Shodan API key at [https://account.shodan.io](https://account.shodan.io)
> The free tier supports host lookups — sufficient for NexPort's query volume.

---

## 🛡️ Live CVE Lookup — CIRCL.LU

No API key required. CIRCL's CVE API is open and free.

NexPort automatically extracts versioned service strings from nmap banners after any Standard, Full, Stealth, Vuln, or Custom scan (modes that include `-sV`):

```
22/tcp  open  ssh     OpenSSH 8.4p1 Debian
80/tcp  open  http    Apache httpd 2.4.49
3306/tcp open mysql   MySQL 5.7.36-log
```

Each detected `<product> <version>` pair triggers a query to:
```
https://cve.circl.lu/api/search/<product>/<version>
```

The top 5 most critical CVE IDs are extracted from the JSON response and displayed inline in the **Live Threat Intel** section:

```
  443     https    apache httpd 2.4.49
          ☠ CVE-2021-41773
          ☠ CVE-2021-42013
```

> **Tip:** Run scans in **Standard (2)** or higher mode to enable `-sV` version detection, which is required for CIRCL CVE lookups.

---

## ⚙️ System Installation & Global Deployment

```bash
# 1. Clone the official repository:
git clone https://github.com/stevenosama025-sudo/nexport.git
cd nexport

# 2. Grant execution permissions:
chmod +x nexport/nexport

# 3. Install system-wide (requires root):
sudo ./nexport/nexport --install

# 4. Run globally from anywhere:
nexport

# 5. Set your Shodan API key after installation:
nexport intel set-key YOUR_SHODAN_API_KEY

# ❌ Uninstall:
sudo nexport --uninstall
```

---

## 📖 Full Command Reference

### 🔎 Lookup

| Command | Description | Example |
|---------|-------------|---------|
| `-h <port\|name>` | Deep info on a port | `-h 22`, `-h ssh`, `-h 443` |
| `-a`, `--all` | List all ports by category | `-a` |
| `-t`, `--top` | Top 30 most targeted ports | `-t` |

### 🔍 Search & Filter

| Command | Description | Example |
|---------|-------------|---------|
| `-s <keyword>` | Search name, protocol, description, CVE | `-s database` |
| `-c <category>` | Filter by category | `-c web` |
| `-p <proto>` | Filter by protocol | `-p tcp` |
| `-e <enc>` | Filter by encryption | `-e no` |
| `-r <level>` | Filter by risk level | `-r critical` |
| `--cve <CVE-ID>` | Find ports linked to a CVE | `--cve CVE-2020-1938` |

### 📡 Scan & Analyze

| Command | Description |
|---------|-------------|
| `scan <target>` | Live nmap scan + NexPort DB analysis + **Live Threat Intel** |
| `paste` / `summarize` | Paste existing nmap output for DB analysis |

**Scan modes available after `scan <target>`:**

| # | Mode | Flags | Notes |
|---|------|-------|-------|
| 1 | Quick | `-T4 --open` | No version detection (~10s) |
| 2 | Standard | `-T4 -sV --open` | Version detection — **enables CVE lookup** (~30s) |
| 3 | Full | `-T4 -sV -p- --open` | All 65535 ports + versions (~5-20min) |
| 4 | Stealth | `-T4 -sS -O -A --open` | Requires root |
| 5 | Vuln | `-T4 -sV --script=vuln --open` | NSE vuln scripts, requires root |
| 6 | Custom | user-defined | Enter your own nmap flags |

### 🌐 Live Threat Intel

| Command | Description |
|---------|-------------|
| `intel set-key <key>` | Save Shodan API key to `~/.nexport/config` |
| `intel clear-key` | Remove saved Shodan API key |
| `intel <public-ip>` | On-demand Shodan + CVE lookup for a specific IP |
| `intel help` | Show intel sub-command reference |

**Environment variable alternative:**
```bash
export SHODAN_API_KEY=your_key_here
```

**What the Live Threat Intel section displays after a scan:**

```
╔══════════════════════════════════════════════════════════════════════╗
║  🔥 LIVE THREAT INTELLIGENCE                                         ║
║  Real-time data from Shodan & CIRCL CVE API                          ║
╚══════════════════════════════════════════════════════════════════════╝

╔══ SHODAN EXTERNAL VIEW ══════════════════════════════════════════════╗
║  Target IP   :  8.8.8.8
║  Organization:  Google LLC
║  ISP         :  Google LLC
║  Location    :  Mountain View, United States
║  Hostname    :  dns.google
╠══ Ports (Shodan perspective) ════════════════════════════════════════╣
║  53  443
╠══ Vulnerabilities Detected by Shodan ════════════════════════════════╣
║  ☠ CVE-2021-XXXXX  CVE-2022-XXXXX
╠══ Service Banners ═══════════════════════════════════════════════════╣
║  53/udp  ISC BIND 9.11  →  DNS query response...
╚══════════════════════════════════════════════════════════════════════╝

[ LIVE CVE LOOKUP — CIRCL.LU ]
────────────────────────────────────────────────────────────────────
  80      http    apache httpd 2.4.49
          ☠ CVE-2021-41773
          ☠ CVE-2021-42013
```

### 📤 Export

| Command | Description |
|---------|-------------|
| `export json` | Export full database as JSON |
| `export csv` | Export as CSV spreadsheet |
| `export markdown` | Export as Markdown table |
| `export html` | Export as searchable HTML report |

### ⚙️ System

| Command | Description |
|---------|-------------|
| `-q`, `--quiz` | Interactive port knowledge quiz |
| `--install` | Install to `/usr/local/bin` (requires sudo) |
| `--uninstall` | Remove from system (requires sudo) |
| `--version` | Show version |
| `--help` | Show help |
| `exit` / `quit` | Exit NexPort |

---

## 🗂️ Project Structure

```
nexport/
├── nexport                     # Main entry point & dispatcher
├── lib/
│   ├── colors.sh               # ANSI color variables, badges, risk icons
│   └── ui.sh                   # Banner, dividers, port info printers
├── data/
│   ├── ports_db.sh             # Core port vulnerability database
│   ├── ports_db_ext1.sh        # Extended database — batch 1
│   ├── ports_db_ext2.sh        # Extended database — batch 2
│   └── ports_db_ext3.sh        # Extended database — batch 3
└── modules/
    ├── lookup.sh               # Port lookup and show-all logic
    ├── search.sh               # Keyword search, protocol/risk/enc filters, CVE search
    ├── category.sh             # Category listing and filtering
    ├── top_ports.sh            # Top 30 most targeted ports
    ├── quiz.sh                 # Interactive training quiz
    ├── nmap_scan.sh            # Live nmap scan engine
    ├── summarizer.sh           # Nmap output parser & threat summary
    ├── export.sh               # JSON / CSV / Markdown / HTML export
    └── api_intel.sh            # ★ NEW — Shodan + CIRCL live threat intel
```

---

## 🔗 API Endpoints Used

| API | Endpoint | Auth | Rate Limit |
|-----|----------|------|-----------|
| Shodan Host Lookup | `https://api.shodan.io/shodan/host/{ip}?key={key}` | API Key required | Per Shodan plan |
| CIRCL CVE Search | `https://cve.circl.lu/api/search/{product}/{version}` | None | Open, fair use |
| CIRCL CVE Fallback | `https://cve.circl.lu/api/search/{product}` | None | Open, fair use |

> NexPort uses `curl` with a **12-second timeout** for Shodan and an **8-second timeout** for CIRCL. All API calls fail gracefully — a failed or missing API key never breaks the scan output.

---

## 🧪 jq vs. Fallback Parsing

NexPort's `api_intel.sh` auto-detects `jq` at runtime:

| Feature | With `jq` | Without `jq` |
|---------|-----------|--------------|
| Shodan org/ISP/country | ✅ Full | ✅ Full |
| Shodan port list | ✅ Full | ✅ Full |
| Shodan banner details | ✅ Full (per-service breakdown) | ⚠️ Basic (regex, limited) |
| Shodan vuln CVE IDs | ✅ Full | ✅ Full |
| CIRCL CVE IDs | ✅ Full | ✅ Full |

Install `jq` for the richest output:
```bash
sudo apt install jq       # Debian / Ubuntu / Kali
sudo dnf install jq       # Fedora / RHEL
sudo pacman -S jq         # Arch Linux
brew install jq           # macOS
```

---

## ⚠️ Operational Notes

* **Version detection is required for CIRCL CVE lookup.** Quick scan mode (`-T4 --open`) does not invoke `-sV`, so no version strings are extracted and the CVE lookup section will advise you accordingly.
* **Shodan only enriches public IPs.** Private RFC1918 addresses (`10.x`, `172.16-31.x`, `192.168.x`), loopback, link-local, and multicast ranges are automatically excluded from external Shodan queries.
* **API keys are stored with `chmod 600`.** The key file at `~/.nexport/config` is restricted to the owner. It is never printed or logged.
* **curl is required** for live API calls. It is pre-installed on all major Linux distributions.
* The existing local scan summary and database lookup pipelines are **completely unmodified**. The Live Threat Intel section appends after them and never interferes with existing output.

---

## 📜 License

```
Copyright (c) 2026 Steven Osama (zeroman). All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

*NEXPORT — Intelligent Threat Analysis Suite*
*Developed by **Steven Osama (zeroman)** — https://github.com/stevenosama025-sudo*
