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

# Detects Which operating system your using
checkos() {
    local operatingsystem=arch
    if [ -f /etc/${operatingsystem}-release ]; then
        echo "$OK $operatingsystem detected!"
        return 0
    else
        echo "$ERROR Not running on $operatingsystem"
        echo "$NOTE Exiting..."
        return 1
    fi
}

# Function To Display The Loading Screen
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

# Function to display menu
show_menu() {
    echo "==================================================="
    echo "                   MENU OPTIONS"
    echo "==================================================="
    echo "1. Display current date and time"
    echo "2. List files in current directory"
    echo "3. Display current working directory"
    echo "4. Check disk usage"
    echo "5. Network Speed"
    echo "6. Update Archlinux"
    echo "7. Check pings"
    echo "8. Exit"
    echo "==================================================="
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
        echo "${ERROR} nethogs is not installed."
        if yes_no_prompt "Would you like to install it now?"; then
            echo "${CAT} Installing nethogs..."
            sudo pacman -S --noconfirm nethogs
            if [[ $? -eq 0 ]]; then
                echo "${OK} nethogs installed successfully."
            else
                echo "${ERROR} Failed to install nethogs."
                return 1
            fi
        else
            echo "${NOTE} nethogs installation skipped."
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
            echo "$OK Current date and time: $(date)"
            ;;
        2)
            display_loading
            echo "$OK Files in current directory:"
            ls -l
            ;;
        3)
            display_loading
            echo "$OK Current working directory: $(pwd)"
            ;;
        4)
            display_loading
            echo "$OK Disk usage:"
            df -h
            ;;
        5)
            display_loading
            clear
            echo "$OK Checking network speed..."
            if check_nethogs; then
                echo "${CAT} Running nethogs. Use Ctrl+C to exit."
                sleep 2
                sudo nethogs
            else
                echo "${ERROR} Network speed test canceled."
            fi
            ;;
        6)
            display_loading
            echo "$OK Ensuring pacman database is up-to-date..."
            if yes_no_prompt "$OK Proceed with updating ArchLinux packages?"; then
                sudo pacman -Sy
                if [[ $? -eq 0 ]]; then
                    echo "$OK Updating ArchLinux packages..."
                    sudo pacman -Syu --noconfirm
                    if [[ $? -eq 0 ]]; then
                        echo "$OK ArchLinux is up-to-date."
                    else
                        echo "$ERROR Failed to update packages."
                    fi
                else
                    echo "$ERROR Failed to synchronize pacman database."
                fi
            else
                echo "${NOTE} Update skipped."
            fi
            sleep 3
            clear
            ;;
        7)
            display_loading
            clear
            sleep 2
            echo "$OK Checking ping to $HOST..."
            if ping -c $COUNT -i $INTERVAL -w $TIMEOUT $HOST; then
                printf "$OK Host $HOST is Reachable."
            else
                printf "$ERROR Host $HOST is not Reachable."
            fi
            sleep 3
            clear
            ;;
        8)
            echo "$OK Exiting. Goodbye!"
            sleep 2
            exit 0
            ;;
        *)
            echo "${ERROR} Invalid choice. Please try again."
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
