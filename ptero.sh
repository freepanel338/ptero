#!/bin/bash

# ===== COLORS =====
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
NC='\033[0m'

# ===== LOADING =====
loading() {
    echo -e "${MAGENTA}Processing...${NC}"
    sleep 1
}

pause(){
 read -p "Press Enter to continue..."
}

# ===== HEADER =====
header() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════╗"
    echo "║        ryomenNodes Installer         ║"
    echo "║         made by PrimeNexus           ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

# ===== MAIN MENU =====
main_menu() {
    header
    echo -e "${GREEN}1.${NC} Pterodactyl Installer"
    echo -e "${GREEN}2.${NC} Wings Install"
    echo -e "${GREEN}3.${NC} Tailscale"
    echo -e "${GREEN}4.${NC} Blueprint + Themes"
    echo -e "${GREEN}5.${NC} Uninstall Tools"
    echo -e "${GREEN}6.${NC} Exit"
    echo ""
    read -p "Select option: " choice

    case $choice in
        1) ptero_menu ;;
        2) wings_auto ;;
        3) tailscale_auto ;;
        4) blueprint_auto ;;
        5) uninstall_tools ;;
        6) exit 0 ;;
        *) main_menu ;;
    esac
}

# ===== PTERO MENU =====
ptero_menu() {
    header
    echo -e "${YELLOW}Pterodactyl Menu${NC}"
    echo "1. Install Panel (Auto)"
    echo "2. Update Panel"
    echo "3. Uninstall Panel"
    echo "4. Back"
    read -p "Select option: " choice

    case $choice in
        1) install_panel_auto ;;
        2) update_panel ;;
        3) uninstall_panel ;;
        4) main_menu ;;
        *) ptero_menu ;;
    esac
}

# ===== AUTO PANEL INSTALL =====
install_panel_auto() {
    header
    echo -e "${GREEN}Auto Installing Panel...${NC}"

    apt update -y && apt upgrade -y
    apt install curl sudo git unzip -y

    # Official installer (auto mode minimal prompts)
    bash <(curl -s https://ptero-installer.se)

    echo -e "${GREEN}Panel Installed!${NC}"
    pause
    ptero_menu
}

# ===== UPDATE PANEL =====
update_panel() {
    header
    echo -e "${CYAN}Updating Panel...${NC}"

    cd /var/www/pterodactyl || { echo "Panel not found"; pause; ptero_menu; }

    php artisan down
    git pull
    composer install --no-dev --optimize-autoloader
    php artisan migrate --force
    php artisan up

    echo -e "${GREEN}Updated Successfully!${NC}"
    pause
    ptero_menu
}

# ===== UNINSTALL PANEL =====
uninstall_panel() {
    header
    echo -e "${RED}Removing Panel...${NC}"

    systemctl stop nginx apache2 mysql mariadb
    rm -rf /var/www/pterodactyl
    rm -rf /etc/nginx/sites-enabled/pterodactyl.conf

    echo -e "${RED}Panel Removed!${NC}"
    pause
    ptero_menu
}

# ===== WINGS AUTO =====
wings_auto() {
    header
    echo -e "${GREEN}Installing Wings...${NC}"

    bash <(curl -s https://ptero-installer.se)

    echo -e "${GREEN}Wings Installed!${NC}"
    pause
    main_menu
}

# ===== TAILSCALE =====
tailscale_auto() {
    header
    echo -e "${CYAN}Installing Tailscale...${NC}"

    curl -fsSL https://tailscale.com/install.sh | sh
    tailscale up

    echo -e "${GREEN}Tailscale Ready!${NC}"
    pause
    main_menu
}

# ===== BLUEPRINT =====
blueprint_auto() {
    header
    echo -e "${MAGENTA}Installing Blueprint...${NC}"

    bash <(curl -s https://raw.githubusercontent.com/BlueprintFramework/framework/main/install.sh)

    echo -e "${GREEN}Blueprint Installed!${NC}"
    pause
    main_menu
}

# ===== UNINSTALL TOOLS =====
uninstall_tools() {
    header
    echo -e "${RED}Removing Tools...${NC}"

    systemctl stop wings
    systemctl disable wings
    rm -rf /etc/pterodactyl

    apt remove tailscale -y

    echo -e "${RED}All tools removed!${NC}"
    pause
    main_menu
}

# ===== START =====
main_menu
