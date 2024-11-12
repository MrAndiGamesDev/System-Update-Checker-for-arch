#!/bin/bash

checkos() {
    local operatingsystem=arch
    for os in "$operatingsystem"; do
        if [ -f /etc/${os}-release ]; then
            echo "$os detected!"
            return 0
        else
            echo "Not running on $os"
            sleep 3
            echo "Exiting..."
            sleep 2
            exit
            return 1
        fi
    done
}

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

update() {
    outdated_packages=$(pacman -Qu)

    if [ -z "$outdated_packages" ]; then
        echo "Your system is up to date."
    else
    #Loop through each outdated package and display it
        echo "There are updates available for the following packages:"
        for package in $outdated_packages; do
        echo "$package"
        done
    fi

    sleep 2

    # List of pacman flags to update the system
    flags=("-Sy" "-Syy" "-Syu")

    # Loop through each flag and run the pacman command with that flag
    for flag in "${flags[@]}"; do
        echo "Running pacman $flag..."
        sudo pacman $flag --noconfirm

        # Check if there are any outdated packages after running the command
        outdated_packages=$(pacman -Qu)

        if [ -z "$outdated_packages" ]; then
            echo "No updates available."
        else
            echo "The following packages are outdated:"
            echo "$outdated_packages"
        fi

        echo ""  # Add a newline for better readability between operations
    done

    for i in {1..3}; do
        for dots in . .. ...; do
            clear  # Clears the screen before starting the animation
            echo -n "Exiting$dots"
            sleep 0.5  # Adjust this for the speed of the animation
            if [[ "$dots" == "..." ]]; then
                sleep 0.5  # Pause for a moment after "Exiting..."
                clear  # Clear the screen after "Exiting..."
            fi
            echo -ne "\r"  # Return the cursor to the beginning of the line
        done
        # Optionally reset the line and show a new "Exiting." before the next iteration
        echo -ne "\rExiting."  # Reset the animation to "Exiting."
        sleep 0.5  # Pause for a moment before clearing again
    done
}

display_loading
checkos
update
