#!/usr/bin/env bash
# ==========================================================
# VTX HUB - DARKPLAYZZ
# Clean animated installer hub
# ==========================================================

set -u

RESET='\033[0m'
BOLD='\033[1m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
WHITE='\033[1;37m'

is_termux() {
    [[ -n "${PREFIX:-}" || -d /data/data/com.termux ]]
}

pause_menu() {
    echo
    read -r -p "Press ENTER to return..." _
}

spinner() {
    local msg="$1"
    local i
    printf "%b" "${CYAN}${msg} ${RESET}"
    for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
        printf "%b" "${MAGENTA}█${RESET}"
        sleep 0.035
    done
    echo
}

banner() {
    clear 2>/dev/null || true
    printf "%b" "${CYAN}${BOLD}"
    cat <<'EOF'
██╗   ██╗████████╗██╗  ██╗
██║   ██║╚══██╔══╝╚██╗██╔╝
╚██╗ ██╔╝   ██║    ╚███╔╝
 ╚████╔╝    ██║    ██╔██╗
  ╚██╔╝     ██║   ██╔╝ ██╗
   ╚═╝      ╚═╝   ╚═╝  ╚═╝
EOF
    printf "%b\n" "${RESET}"
    printf "%b\n" "${MAGENTA}${BOLD}             V T X   H U B${RESET}"
    printf "%b\n\n" "${YELLOW}             BY DARKPLAYZZ${RESET}"
}

confirm() {
    local answer
    read -r -p "$1 [y/N]: " answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

require_server() {
    if is_termux; then
        printf "%b\n\n" "${YELLOW}TERMUX TEST MODE${RESET}"
        printf "%b\n" "${WHITE}This module needs a supported Linux VPS/root environment.${RESET}"
        printf "%b\n" "${GREEN}✓ VTX HUB button is working${RESET}"
        return 1
    fi

    if [[ "$(id -u)" != "0" ]]; then
        printf "%b\n" "${RED}Root access is required for this installer.${RESET}"
        return 1
    fi
    return 0
}

run_remote_installer() {
    local title="$1"
    local url="$2"
    local mode="${3:-}"

    banner
    printf "%b\n\n" "${CYAN}${BOLD}${title}${RESET}"

    if ! require_server; then
        pause_menu
        return
    fi

    printf "%b\n\n" "${YELLOW}The real installer will now start.${RESET}"
    printf "%b\n" "${WHITE}Only the verified source configured in this VTX HUB module is used.${RESET}"
    echo

    spinner "Preparing"

    if [[ -n "$mode" ]]; then
        bash <(curl -fsSL "$url") "$mode"
    else
        bash <(curl -fsSL "$url")
    fi

    local rc=$?
    echo
    if [[ $rc -eq 0 ]]; then
        printf "%b\n" "${GREEN}✓ Installer finished.${RESET}"
    else
        printf "%b\n" "${RED}✗ Installer exited with code ${rc}.${RESET}"
    fi
    pause_menu
}

pterodactyl() {
    while true; do
        banner
        printf "%b\n" "${CYAN}${BOLD}PTERODACTYL${RESET}"
        echo
        echo "  [1] Panel"
        echo "  [2] Wings"
        echo "  [3] Panel + Wings"
        echo "  [0] Back"
        echo
        read -r -p "PTERO > " choice

        case "$choice" in
            1)
                # Community automated installer; Pterodactyl itself does not publish
                # an official one-line installer.
                run_remote_installer \
                    "PTERODACTYL PANEL" \
                    "https://pterodactyl-installer.se" \
                    "panel"
                ;;
            2)
                run_remote_installer \
                    "PTERODACTYL WINGS" \
                    "https://pterodactyl-installer.se" \
                    "wings"
                ;;
            3)
                run_remote_installer \
                    "PTERODACTYL PANEL + WINGS" \
                    "https://pterodactyl-installer.se" \
                    "both"
                ;;
            0) return ;;
            *) printf "%b\n" "${RED}Invalid option.${RESET}"; sleep 0.8 ;;
        esac
    done
}

feather() {
    banner
    printf "%b\n\n" "${CYAN}${BOLD}FEATHERPANEL${RESET}"

    if ! require_server; then
        pause_menu
        return
    fi

    printf "%b\n" "${WHITE}Official FeatherPanel stable installer${RESET}"
    echo
    if confirm "Start installation?"; then
        spinner "Preparing FeatherPanel"
        bash <(curl -fsSL "https://get.featherpanel.com/stable.sh")
        local rc=$?
        echo
        [[ $rc -eq 0 ]] \
            && printf "%b\n" "${GREEN}✓ FeatherPanel installer finished.${RESET}" \
            || printf "%b\n" "${RED}✗ Installer exited with code ${rc}.${RESET}"
    else
        printf "%b\n" "${YELLOW}Cancelled.${RESET}"
    fi
    pause_menu
}

jexactyl() {
    banner
    printf "%b\n\n" "${CYAN}${BOLD}JEXACTYL${RESET}"
    printf "%b\n" "${YELLOW}Jexactyl installation script: third-party/community source.${RESET}"
    printf "%b\n\n" "${WHITE}The Jexactyl project is separate from Pterodactyl and its current project branding is Jexpanel.${RESET}"

    if ! require_server; then
        pause_menu
        return
    fi

    if confirm "Start the community Jexactyl installer?"; then
        spinner "Preparing Jexactyl"
        bash <(curl -fsSL \
            "https://raw.githubusercontent.com/Blxvyy/Jexactyl-Installation-Script/main/install.sh")
        local rc=$?
        echo
        [[ $rc -eq 0 ]] \
            && printf "%b\n" "${GREEN}✓ Jexactyl installer finished.${RESET}" \
            || printf "%b\n" "${RED}✗ Installer exited with code ${rc}.${RESET}"
    else
        printf "%b\n" "${YELLOW}Cancelled.${RESET}"
    fi
    pause_menu
}

docker_menu() {
    banner
    printf "%b\n\n" "${CYAN}${BOLD}DOCKER${RESET}"

    if is_termux; then
        printf "%b\n" "${YELLOW}TERMUX TEST MODE${RESET}"
        printf "%b\n" "${GREEN}✓ Docker button is working${RESET}"
        printf "%b\n" "${WHITE}Real Docker Engine installation is for a supported Linux host.${RESET}"
        pause_menu
        return
    fi

    if [[ "$(id -u)" != "0" ]]; then
        printf "%b\n" "${RED}Root access is required.${RESET}"
        pause_menu
        return
    fi

    if command -v docker >/dev/null 2>&1; then
        printf "%b\n" "${GREEN}✓ Docker is already installed${RESET}"
        docker --version
    elif confirm "Install Docker Engine using Docker's official installer?"; then
        spinner "Installing Docker"
        curl -fsSL https://get.docker.com | sh
        local rc=$?
        echo
        [[ $rc -eq 0 ]] \
            && printf "%b\n" "${GREEN}✓ Docker installation finished.${RESET}" \
            || printf "%b\n" "${RED}✗ Docker installer exited with code ${rc}.${RESET}"
    else
        printf "%b\n" "${YELLOW}Cancelled.${RESET}"
    fi
    pause_menu
}

cloudflare_menu() {
    banner
    printf "%b\n\n" "${CYAN}${BOLD}CLOUDFLARE${RESET}"
    echo "  [1] Install cloudflared"
    echo "  [2] Login to Cloudflare Tunnel"
    echo "  [3] Show cloudflared version"
    echo "  [0] Back"
    echo
    read -r -p "CLOUDFLARE > " choice

    case "$choice" in
        1)
            if is_termux; then
                printf "%b\n" "${YELLOW}Termux detected.${RESET}"
                printf "%b\n" "${WHITE}Use the Termux package manager for Termux builds; this module's Linux binary installer is for VPS hosts.${RESET}"
            elif [[ "$(id -u)" == "0" ]]; then
                spinner "Installing cloudflared"
                # Cloudflare's package repository for Debian/Ubuntu.
                apt-get update
                apt-get install -y curl gnupg
                install -d -m 0755 /usr/share/keyrings
                curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
                    -o /usr/share/keyrings/cloudflare-main.gpg
                . /etc/os-release
                case "${VERSION_CODENAME:-}" in
                    bookworm|bullseye|trixie|jammy|noble|focal)
                        echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared ${VERSION_CODENAME} main" \
                            > /etc/apt/sources.list.d/cloudflared.list
                        apt-get update
                        apt-get install -y cloudflared
                        ;;
                    *)
                        printf "%b\n" "${YELLOW}Your distro codename is not covered by this module. Use Cloudflare's official package instructions for your OS.${RESET}"
                        ;;
                esac
                command -v cloudflared >/dev/null 2>&1 && cloudflared --version
            else
                printf "%b\n" "${RED}Root access is required.${RESET}"
            fi
            pause_menu
            ;;
        2)
            if command -v cloudflared >/dev/null 2>&1; then
                cloudflared tunnel login
            else
                printf "%b\n" "${YELLOW}cloudflared is not installed yet. Choose option 1 first.${RESET}"
            fi
            pause_menu
            ;;
        3)
            if command -v cloudflared >/dev/null 2>&1; then
                cloudflared --version
            else
                printf "%b\n" "${YELLOW}cloudflared is not installed.${RESET}"
            fi
            pause_menu
            ;;
        0) return ;;
        *) printf "%b\n" "${RED}Invalid option.${RESET}"; sleep 0.8 ;;
    esac
}

blueprint() {
    banner
    printf "%b\n\n" "${CYAN}${BOLD}VTX BLUEPRINT FIXER${RESET}"

    if ! command -v git >/dev/null 2>&1; then
        if is_termux; then
            pkg install -y git
        elif [[ "$(id -u)" == "0" ]] && command -v apt-get >/dev/null 2>&1; then
            apt-get update && apt-get install -y git
        else
            printf "%b\n" "${RED}Git is required.${RESET}"
            pause_menu
            return
        fi
    fi

    local base="${HOME}/vtx-tools"
    mkdir -p "$base"
    cd "$base" || return

    if [[ -d BLUEPRINT-FIXER/.git ]]; then
        spinner "Updating Blueprint Fixer"
        git -C BLUEPRINT-FIXER pull --ff-only
    else
        spinner "Downloading Blueprint Fixer"
        git clone "https://github.com/advrajdeeplakha-cmd/BLUEPRINT-FIXER.git" BLUEPRINT-FIXER
    fi

    printf "%b\n" "${GREEN}✓ Blueprint Fixer repository is ready.${RESET}"
    pause_menu
}

system_info() {
    banner
    printf "%b\n\n" "${CYAN}${BOLD}SYSTEM INFORMATION${RESET}"

    printf "%b\n" "${WHITE}OS:${RESET}       $(uname -o 2>/dev/null || echo Unknown)"
    printf "%b\n" "${WHITE}Kernel:${RESET}   $(uname -r)"
    printf "%b\n" "${WHITE}Arch:${RESET}     $(uname -m)"
    printf "%b\n" "${WHITE}Host:${RESET}     $(hostname 2>/dev/null || echo Unknown)"

    if command -v nproc >/dev/null 2>&1; then
        printf "%b\n" "${WHITE}CPU cores:${RESET} $(nproc)"
    fi

    if command -v free >/dev/null 2>&1; then
        echo
        free -h
    fi

    echo
    if command -v df >/dev/null 2>&1; then
        df -h /
    fi

    if is_termux && command -v getprop >/dev/null 2>&1; then
        echo
        printf "%b\n" "${WHITE}Device:${RESET}   $(getprop ro.product.model)"
        printf "%b\n" "${WHITE}Android:${RESET}  $(getprop ro.build.version.release)"
    fi

    pause_menu
}

network_info() {
    banner
    printf "%b\n\n" "${CYAN}${BOLD}NETWORK INFORMATION${RESET}"

    if command -v curl >/dev/null 2>&1; then
        local ip
        ip="$(curl -4 -fsS --max-time 5 https://api.ipify.org 2>/dev/null || true)"
        printf "%b\n" "${WHITE}Public IPv4:${RESET} ${GREEN}${ip:-Unavailable}${RESET}"
    fi

    if command -v ip >/dev/null 2>&1; then
        echo
        ip -br addr 2>/dev/null || true
    fi

    pause_menu
}

vtx_panel() {
    banner
    printf "%b\n\n" "${MAGENTA}${BOLD}             VTX VM PANEL${RESET}"
    printf "%b\n" "${YELLOW}               COMING SOON${RESET}"
    echo
    printf "%b\n" "${WHITE}VTX VM management panel is under development.${RESET}"
    pause_menu
}

menu() {
    while true; do
        banner
        printf "%b\n" "${BLUE}╔════════════════════════════════════════════════════╗${RESET}"
        printf "%b\n" "${WHITE}║                  PANEL INSTALLERS                 ║${RESET}"
        printf "%b\n" "${BLUE}╠════════════════════════════════════════════════════╣${RESET}"
        printf "%b\n" "${GREEN}║ [1]${RESET} 🐉 Pterodactyl Panel / Wings               ${BLUE}║${RESET}"
        printf "%b\n" "${GREEN}║ [2]${RESET} 🚀 Jexactyl / Jexpanel                     ${BLUE}║${RESET}"
        printf "%b\n" "${GREEN}║ [3]${RESET} 🪶 FeatherPanel                            ${BLUE}║${RESET}"
        printf "%b\n" "${GREEN}║ [4]${RESET} 🖥️  VTX VM Panel        ${YELLOW}[COMING SOON]${BLUE}   ║${RESET}"
        printf "%b\n" "${BLUE}╠════════════════════════════════════════════════════╣${RESET}"
        printf "%b\n" "${WHITE}║                    SERVER TOOLS                   ║${RESET}"
        printf "%b\n" "${BLUE}╠════════════════════════════════════════════════════╣${RESET}"
        printf "%b\n" "${GREEN}║ [5]${RESET} 🐳 Docker                                   ${BLUE}║${RESET}"
        printf "%b\n" "${GREEN}║ [6]${RESET} ☁️  Cloudflare / Tunnel                    ${BLUE}║${RESET}"
        printf "%b\n" "${GREEN}║ [7]${RESET} 🔧 VTX Blueprint Fixer                      ${BLUE}║${RESET}"
        printf "%b\n" "${GREEN}║ [8]${RESET} 📊 System Information                       ${BLUE}║${RESET}"
        printf "%b\n" "${GREEN}║ [9]${RESET} 🌐 Network Information                      ${BLUE}║${RESET}"
        printf "%b\n" "${BLUE}╠════════════════════════════════════════════════════╣${RESET}"
        printf "%b\n" "${RED}║ [0]${RESET} ❌ Exit                                      ${BLUE}║${RESET}"
        printf "%b\n\n" "${BLUE}╚════════════════════════════════════════════════════╝${RESET}"

        read -r -p "$(printf '%b' "${MAGENTA}${BOLD}VTX-HUB ❯ ${RESET}")" choice

        case "$choice" in
            1) pterodactyl ;;
            2) jexactyl ;;
            3) feather ;;
            4) vtx_panel ;;
            5) docker_menu ;;
            6) cloudflare_menu ;;
            7) blueprint ;;
            8) system_info ;;
            9) network_info ;;
            0)
                clear 2>/dev/null || true
                printf "%b\n" "${GREEN}${BOLD}VTX HUB CLOSED — BY DARKPLAYZZ 👋${RESET}"
                exit 0
                ;;
            *) printf "%b\n" "${RED}Invalid option.${RESET}"; sleep 0.7 ;;
        esac
    done
}

loading() {
    banner
    spinner "Initializing VTX HUB"
}

loading
menu
