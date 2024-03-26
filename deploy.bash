#!/bin/bash

# Options
options=("Production" "Preview" "QA")

# Initial choice is the first one
current_choice=0

print_menu() {
    # Clear the screen and move the cursor to the top left
    echo -ne "\033c"
    
    echo "Deploy onto..."
    for i in "${!options[@]}"; do
        if [[ "$i" -eq "$current_choice" ]]; then
            # Highlight the current choice
            echo -e "\e[1m> ${options[$i]}\e[0m"
        else
            echo "  ${options[$i]}"
        fi
    done
}

# Listen for up and down arrow keys
while true; do
    print_menu
    # Wait for user input
    read -rsn3 input

    case $input in
        $'\x1B[A') # Up
            ((current_choice--))
            if ((current_choice < 0)); then current_choice=0; fi
            ;;
        $'\x1B[B') # Down
            ((current_choice++))
            if ((current_choice >= ${#options[@]})); then current_choice=$((${#options[@]} - 1)); fi
            ;;
        "") # Enter key
            break
            ;;
    esac
done

# Clear the screen one last time before displaying the selected option
echo -ne "\033c"
echo "You selected: ${options[$current_choice]}"
