#!/bin/bash

# Options
options=("Production" "Preview" "QA")
declare -A environments=( ["Production"]="production" ["Preview"]="preview" ["QA"]="qa" )

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

declare choice=${options[$current_choice]}

declare environment=${environments[$choice]}


declare url_prefix=""

if [ $environment != "production" ]; then
    url_prefix=$environment.
fi

declare port=3000

# test variables
export root_url=http://localhost
export mongo_url=mongodb://perdiem:123456@mongo:27017/perdiem?authSource=admin

# uncomment for actual deployment
#declare root_url=http://${url_prefix}perdiem.me
#declare mongo_url=mongodb://perdiem:40996572@localhost/perdiem_${environment}?authSource=admin

HOST_SSH_KEY="$(cat ~/.ssh/id_rsa)" PORT=$port ROOT_URL=$root_url MONGO_URL=$mongo_url ENVIRONMENT=$environment docker-compose up --build
