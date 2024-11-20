#!/bin/bash

# Function To Display The Menu
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 5)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Function To Get Ping Host
HOST="google.com"
COUNT=5
INTERVAL=2
TIMEOUT=10

# Function To Get The Script Name
SCRIPTNAME=$(basename "$0")

# Detects Which operating system you're using
checkos() {
    local operatingsystem=arch
    if [ -f /etc/${operatingsystem}-release ]; then
        animate_text "$OK $operatingsystem was detected!"
        sleep 2
        return 0
    else
        animate_text "$ERROR Not running on $operatingsystem"
        sleep 2
        animate_text "$NOTE Exiting..."
        sleep 2
        return 1
    fi
}

# Function to Display the Loading Screen
display_loading() {
    local ishowspeed=0.05
    local duration=1
    local width=68
    local progress=0
    local step=$((width / duration))
    local spin_index=0
    local hidecursor="\033[?25l"  # Hide cursor
    local showcursor="\033[?25h"  # Show cursor
    local spinner=('|' '/' '-' '\')

    echo -ne ${hidecursor}  # Hide cursor

    while [ $progress -le $width ]; do
        clear
        printf "\rLoading: ["
        for ((i=0; i<$progress; i++)); do
            printf "#"
        done
        for ((i=$progress; i<$width; i++)); do
            printf " "
        done
        printf "] %3d%% ${spinner[$spin_index]}" $((progress * 100 / width))
        sleep $ishowspeed
        progress=$((progress + 1))
        spin_index=$(( (spin_index + 1) % 4 ))
    done

    printf "\rLoading: ["; printf '%0.s#' $(seq 1 $width); printf "] 100%%\n"
    echo -ne ${showcursor}
}

# Function to animate text output
animate_text() {
    local text="$1"
    local delay=0.05
    for ((i = 0; i < ${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo
}

# Function to display menu
show_menu() {
    animate_text "==================================================="
    animate_text "                   MENU OPTIONS"
    animate_text "==================================================="
    animate_text "1. Display Current date and time"
    animate_text "2. List Files in current directory"
    animate_text "3. Display Current working directory"
    animate_text "4. Check Disk usage"
    animate_text "5. Network Speed"
    animate_text "6. Update Archlinux"
    animate_text "7. Check Pings"
    animate_text "8. Exit"
    animate_text "==================================================="
}

# Reusable Yes/No prompt
yes_no_prompt() {
    local prompt="$1"
    local response
    while true; do
        read -p "$prompt (y/n): " response
        case $response in
            [Yy]* ) return 0 ;;  # Yes
            [Nn]* ) return 1 ;;  # No
            * ) echo "${WARN} Please answer yes(y) or no(n)." ;;
        esac
    done
}

# Function to check if nethogs is installed
check_nethogs() {
    if ! command -v nethogs &> /dev/null; then
        animate_text "${ERROR} nethogs is not installed."
        if yes_no_prompt "Would you like to install it now?"; then
            animate_text "${CAT} Installing nethogs..."
            sudo pacman -S --noconfirm nethogs
            if [[ $? -eq 0 ]]; then
                animate_text "${OK} nethogs installed successfully."
            else
                animate_text "${ERROR} Failed to install nethogs."
                return 1
            fi
        else
            animate_text "${NOTE} nethogs installation skipped."
            return 1
        fi
    fi
    return 0
}

# Function to handle user choice
handle_choice() {
    case $1 in
        1)
            display_loading
            animate_text "$OK Current date and time: $(date)"
            ;;
        2)
            display_loading
            animate_text "$OK Files in current directory:"
            ls -l
            ;;
        3)
            display_loading
            animate_text "$OK Current working directory: $(pwd)"
            ;;
        4)
            display_loading
            animate_text "$OK Disk usage:"
            df -h
            ;;
        5)
            display_loading
            clear
            animate_text "$OK Checking network speed..."
            if check_nethogs; then
                animate_text "${CAT} Running nethogs. Use Ctrl+C to exit."
                sleep 2
                sudo nethogs
            else
                animate_text "${ERROR} Network speed test canceled."
            fi
            ;;
        6)
            display_loading
            animate_text "$OK Ensuring pacman database is up-to-date..."
            if yes_no_prompt "$OK Proceed with updating ArchLinux packages?"; then
                sudo pacman -Sy
                if [[ $? -eq 0 ]]; then
                    animate_text "$OK Updating ArchLinux packages..."
                    sudo pacman -Syu --noconfirm
                    if [[ $? -eq 0 ]]; then
                        animate_text "$OK ArchLinux is up-to-date."
                    else
                        animate_text "$ERROR Failed to update packages."
                    fi
                else
                    animate_text "$ERROR Failed to synchronize pacman database."
                fi
            else
                animate_text "${NOTE} Update skipped."
            fi
            sleep 3
            clear
            ;;
        7)
            display_loading
            clear
            sleep 2
            animate_text "$OK Checking ping to $HOST..."
            if ping -c $COUNT -i $INTERVAL -w $TIMEOUT $HOST; then
                animate_text "$OK Host $HOST is Reachable."
            else
                animate_text "$ERROR Host $HOST is not Reachable."
            fi
            sleep 3
            clear
            ;;
        8)
            animate_text "$OK Exiting. Goodbye!"
            sleep 2
            exit 0
            ;;
        *)
            animate_text "${ERROR} Invalid choice. Please try again."
            ;;
    esac
}

iusearchbtw() {
    # Main script loop
    while true; do
        checkos
        if [[ $? -ne 0 ]]; then
            break
        fi
        show_menu
        read -p "Enter your choice [1-8]: " choice
        handle_choice $choice
        echo ""
    done
}

iusearchbtw
