#!/bin/bash

# Get the script name (basename)
script_name=$(basename "$0")

# Check if the script has execute permission for the user
if [ ! -x "$0" ]; then
  echo "You do not have execute permissions for this script."
  echo "Granting execute permission..."

  # Grant execute permission to the script
  chmod u+x "$0"

  # Check again if permission was granted
  if [ ! -x "$0" ]; then
    echo "Failed to grant execute permission. Exiting..."
    exit 1
  fi
fi

echo "Script is executable, proceeding..."

sleep 2

# Check for available updates
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
