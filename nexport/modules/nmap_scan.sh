#!/usr/bin/env bash

# Copyright (c) 2026 Steven Osama (zeroman). All rights reserved.
# Lead Developer: Steven Osama | GitHub: @stevenosama025-sudo

NEXPORT_SCAN_OUTDIR="${HOME}/.nexport/scans"

_ensure_scan_dir() {
  mkdir -p "$NEXPORT_SCAN_OUTDIR"
}

_nmap_not_found() {
  echo -e "\n  ${RED}${FAIL} nmap is not installed on this system.${RESET}"
  echo -e "  ${YELLOW}Install with one of:${RESET}"
  printf "  ${GREEN}%-42s${RESET} %s\n" "sudo apt install nmap"  "(Debian / Ubuntu)"
  printf "  ${GREEN}%-42s${RESET} %s\n" "sudo dnf install nmap"  "(Fedora / RHEL)"
  printf "  ${GREEN}%-42s${RESET} %s\n" "sudo pacman -S nmap"    "(Arch Linux)"
  printf "  ${GREEN}%-42s${RESET} %s\n" "brew install nmap"      "(macOS)"
  echo -e "\n  ${GRAY}Use ${GREEN}paste${GRAY} to summarize existing nmap output without running a scan.${RESET}\n"
}

_select_scan_mode() {
  # All menu display goes to /dev/tty so it won't be captured when stdout is redirected
  echo -e "  ${CYAN}Select scan mode:${RESET}" >/dev/tty
  echo -e "  ${GREEN}1${RESET}  ${WHITE}Quick${RESET}      - Top 1000 ports, no service detection  ${DIM}(~10s)${RESET}" >/dev/tty
  echo -e "  ${GREEN}2${RESET}  ${WHITE}Standard${RESET}   - Top 1000 ports + version detection    ${DIM}(~30s)${RESET}" >/dev/tty
  echo -e "  ${GREEN}3${RESET}  ${WHITE}Full${RESET}       - All 65535 ports + version detection   ${DIM}(~5-20min)${RESET}" >/dev/tty
  echo -e "  ${GREEN}4${RESET}  ${WHITE}Stealth${RESET}    - SYN scan, OS detect, script engine    ${DIM}(requires root)${RESET}" >/dev/tty
  echo -e "  ${GREEN}5${RESET}  ${WHITE}Vuln${RESET}       - Top 1000 ports + NSE vuln scripts      ${DIM}(requires root)${RESET}" >/dev/tty
  echo -e "  ${GREEN}6${RESET}  ${WHITE}Custom${RESET}     - Enter your own nmap flags" >/dev/tty
  echo "" >/dev/tty

  local scan_choice
  while true; do
    echo -ne "  ${YELLOW}Choice [1-6]: ${RESET}" >/dev/tty
    read -r scan_choice </dev/tty

    case "$scan_choice" in
      1|2|3|4|5) break ;;
      6)
        echo -ne "  ${YELLOW}Enter nmap flags: ${RESET}" >/dev/tty
        local custom_flags
        read -r custom_flags </dev/tty
        if [[ -n "$custom_flags" ]]; then
          echo "$custom_flags"
        else
          echo -e "  ${RED}No flags entered. Defaulting to Quick scan.${RESET}" >/dev/tty
          echo "-T4 --open"
        fi
        return
        ;;
      "")
        echo -e "  ${YELLOW}No input detected. Please enter a number from 1 to 6.${RESET}" >/dev/tty
        ;;
      *)
        echo -e "  ${RED}Invalid choice '${scan_choice}'. Please enter a number from 1 to 6.${RESET}" >/dev/tty
        ;;
    esac
  done

  # Only the flags string goes to stdout
  case "$scan_choice" in
    1) echo "-T4 --open" ;;
    2) echo "-T4 -sV --open" ;;
    3) echo "-T4 -sV -p- --open" ;;
    4) echo "-T4 -sS -O -A --open" ;;
    5) echo "-T4 -sV --script=vuln --open" ;;
  esac
}

_parse_open_ports_from_nmap() {
  local nmap_output="$1"
  local ports=()
  while IFS= read -r line; do
    if [[ "$line" =~ ^([0-9]+)/[a-z]+[[:space:]]+open ]]; then
      ports+=("${BASH_REMATCH[1]}")
    fi
  done <<< "$nmap_output"
  echo "${ports[@]}"
}

_save_scan_report() {
  local target="$1"
  local output="$2"
  local flags="$3"
  _ensure_scan_dir
  local timestamp
  timestamp=$(date +"%Y%m%d_%H%M%S")
  local safe_target="${target//\//_}"
  local outfile="${NEXPORT_SCAN_OUTDIR}/scan_${safe_target}_${timestamp}.txt"
  {
    echo "NexPort v3.0 Scan Report"
    echo "Target  : $target"
    echo "Flags   : nmap $flags $target"
    echo "Date    : $(date)"
    echo "======================================"
    echo "$output"
  } > "$outfile"
  echo "$outfile"
}

run_nmap_scan() {
  local target="$1"

  if ! command -v nmap &>/dev/null; then
    _nmap_not_found
    return
  fi

  clear
  echo -e "\n  ${BOLD}${CYAN}NexPort - Live Nmap Scan Engine${RESET}"
  echo -e "  ${GRAY}Target: ${WHITE}${target}${RESET}\n"

  # Redirect stdout to temp file so only the flags line is captured
  local nmap_flags
  local _mode_tmp
  _mode_tmp=$(mktemp /tmp/nexport_mode_XXXXXX)
  _select_scan_mode > "$_mode_tmp"
  nmap_flags=$(cat "$_mode_tmp")
  rm -f "$_mode_tmp"

  if [[ -z "$nmap_flags" ]]; then
    echo -e "  ${RED}${FAIL} Failed to select scan mode. Aborting.${RESET}\n"
    return 1
  fi

  local output_file
  output_file=$(mktemp /tmp/nexport_scan_XXXXXX.txt)

  echo ""
  echo -e "  ${CYAN}Executing: ${WHITE}nmap ${nmap_flags} ${target}${RESET}"
  echo -e "  ${GRAY}Streaming results live...${RESET}"
  echo ""
  thick_divider

  nmap $nmap_flags "$target" 2>&1 | tee "$output_file"

  thick_divider
  echo ""

  local scan_output
  scan_output=$(cat "$output_file")

  if ! grep -q "open" "$output_file"; then
    echo -e "  ${YELLOW}${WARN} No open ports detected in scan output.${RESET}"
    echo -e "  ${GRAY}Check connectivity, firewall rules, and consider using sudo for SYN scan.${RESET}\n"
    rm -f "$output_file"
    return
  fi

  local saved_path
  saved_path=$(_save_scan_report "$target" "$scan_output" "$nmap_flags")

  echo -e "  ${GREEN}${OK} Scan saved: ${DIM}${saved_path}${RESET}"
  echo -e "  ${BOLD}${CYAN}Analyzing results against NexPort vulnerability database...${RESET}\n"

  _summarize_nmap_output "$scan_output" "$target"

  rm -f "$output_file"
}
