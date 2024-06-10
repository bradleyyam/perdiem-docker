#!/bin/bash

# Options
options=("Production" "QA" "Staging")
declare -A environments=( ["Production"]="production" ["QA"]="qa" ["Staging"]="staging" )
declare -A addresses=( ["staging"]=140.82.2.145 )

# Initial choice is the first one
current_choice=0

menu_choose_env() {
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

# Initial choice
while true; do
    menu_choose_env
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

declare choice=${options[$current_choice]}
declare environment=${environments[$choice]}

cd ansible && ansible-playbook -i inventory deploy.yml --extra-vars "DEPLOY_ENV=$environment"
