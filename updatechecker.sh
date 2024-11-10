#!/bin/bash

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

sleep 2
pkill konsole
