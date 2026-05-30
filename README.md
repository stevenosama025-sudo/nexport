# 🚀 NexPort v3.0

> **Professional Network Port Intelligence & Penetration Testing Automation Utility**
> 
> **Developed by:** [Steven Osama](https://github.com/stevenosama025-sudo) (Alias: **zeroman**)  
> **Official Repository:** [https://github.com/stevenosama025-sudo/nexport.git](https://github.com/stevenosama025-sudo/nexport.git)

---

NexPort v3.0 is an advanced, high-performance security reconnaissance and automation tool tailored for **Kali Linux** and security operations. Designed and engineered by cybersecurity professional **Steven Osama (zeroman)**, it bridges the gap between raw network scanning and actionable vulnerability intelligence. By automating live `Nmap` analysis and mapping discovered ports to an extensive internal vulnerability database, NexPort gives security analysts a crystal-clear overview of historical CVEs, protocol details, encryption status, and potential exploit vectors in milliseconds.

Wrapped in a stunning, high-contrast **Cyberpunk ANSI neon interface**, NexPort ensures maximum data scannability under critical engagement timelines.

---

## ⚡ Key Features

* 📦 **System-Wide Auto Integration:** Features an advanced installer that deploys a native wrapper, granting you full execution rights from anywhere in the system.
* 🛠️ **Strict Modular Architecture:** Built with high software engineering standards. Code logic, UI rendering, Nmap engines, and databases are strictly separated across clean, self-documenting `.sh` files with **zero code bloat**.
* 🗄️ **Massive Vulnerability Database:** Features a deeply mapped catalog linking thousands of ports to their specific risk indices (HIGH/MED/LOW), encryption compliance flags (`[CLR]` for cleartext warnings), and known real-world exploits.
* 🔍 **Intelligent Live Nmap Parser:** Wraps Nmap into 5 professional deployment modes (Quick, Standard, Full, Common, Custom) with automated version extraction and lookup integration.
* 📊 **Production-Ready Reports:** Instantly exports scan findings and technical summaries into structured `JSON`, `CSV`, or clean `Markdown (.md)` format for final client reporting.
* 🎯 **Gamified Training Engine:** Features an interactive embedded Quiz Mode to train junior SOC analysts and junior penetration testers on critical ports and threat scenarios.

---

## ⚙️ System Installation & Global Deployment

NexPort includes a built-in automated compiler and installer configured by **zeroman** that deploys the global environment variables for you, allowing the tool to run globally like native utilities (e.g., `nmap` or `msfconsole`).

### 🛠️ Step-by-Step Installation & Usage:

```bash
# 1. Clone the official repository and enter the project folder:
git clone [https://github.com/stevenosama025-sudo/nexport.git](https://github.com/stevenosama025-sudo/nexport.git)
cd nexport

# 2. Grant execution permissions to the main script:
chmod +x nexport.sh

# 3. Install the tool system-wide using root privileges:
sudo ./nexport --install

# 4. Run the tool globally from anywhere in your system:
nexport

# 5. Access the help and lookup system directly:
nexport -h
# or
nexport --help

# ❌ Uninstallation:
# If you ever need to completely remove the tool and its databases from your system, execute:
sudo nexport --uninstall
