#!/bin/bash


install_namada() {
    print_green "✓ Installing Namada..."
    curl -s https://itrocket.net/api/namada/autoinstall/ | bash
}

# logo
logo='
 __   __     ______     __    __     ______     _____     ______       
/\ "-.\ \   /\  __ \   /\ "-./  \   /\  __ \   /\  __-.  /\  __ \      
\ \ \-.  \  \ \  __ \  \ \ \-./\ \  \ \  __ \  \ \ \/\ \ \ \  __ \     
 \ \_\\"\_\  \ \_\ \_\  \ \_\ \ \_\  \ \_\ \_\  \ \____-  \ \_\ \_\    
  \/_/ \/_/   \/_/\/_/   \/_/  \/_/   \/_/\/_/   \/____/   \/_/\/_/    
                                                                       
'

# colors
print_green() {
    echo -e "\033[32m$1\033[0m"
}

print_yellow() {
    echo -e "\033[33m$1\033[0m"
}

print_red() {
    echo -e "\033[31m$1\033[0m"
}

# Detect OS and set BASE_DIR accordingly
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    BASE_DIR="$HOME/.local/share/namada"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    BASE_DIR="$HOME/Library/Application\ Support/Namada"
else
    print_red "Unsupported OS. Exiting..."
    exit 1
fi

# Export BASE_DIR and RPC
export BASE_DIR
export RPC="https://semjjonline.xyz/"

# Display logo with color
print_yellow "${logo}"

# Spacing for visual clarity
echo ""

# Main script
print_yellow "Do you want to install Namada? (yes/no):"
read -p $'➜ ' answer
echo "" # Additional space for clarity
case $answer in
    [Yy]*)
        install_namada
        ;;
    [Nn]*)
        print_yellow "✓ Skipping Namada installation..."
        ;;
    *)
        print_red "✗ Invalid input, skipping Namada installation..."
        ;;
esac

# Set default alias
ALIAS="shieldedaction"
export ALIAS
print_green "✓ Default alias set to: $ALIAS"

echo $'\e[38;5;111mSelect an option:\e[0m'
echo "0. Use an existing wallet"
echo "1. Derive a wallet"
echo "2. Create a new wallet"
echo "3. Perform Shielded Swap"
echo "4. Perform Shielded Action"
echo "5. Shield NAAN"
read -p $'\e[38;5;111mEnter your choice (0 1 2 3 4 5): \e[0m' choice

case $choice in

   0) echo "Displaying Available wallets"


print_yellow "Select Alias Only"

addresses=($(namada wallet list | awk '
    /^Known transparent keys:/ { printing_addresses = 0 }
    /^Known shielded keys:/ { printing_addresses = 0 }
    /^Known payment addresses:/ { printing_addresses = 1 }
    printing_addresses && /^  "[^"]+":/ { gsub(/^  "|":/, ""); print }
'))

echo "Now, select a payment address:"

# Display the available payment addresses
index=1
for address in "${addresses[@]}"; do
    echo "$index: $address"
    ((index++))
done



read -p "Enter the number of the payment address you want to use: " choice

# Get the selected payment address
selected_address="${addresses[$(($choice - 1))]}"
echo "You selected payment address: $selected_address"
    paymentAddress=$selected_address

 
    while true; do
    print_yellow "Enter the amount to transfer (Min 40): "
    read -p $'➜ ' amount

    if [[ $amount -ge 40 ]]; then
        break
    else
        echo "Amount must be at least 40. Please try again."
    fi
done

echo "Amount entered: $amount"
echo "Performing IBC-Gen-Shielded"

echo "Do you want to use your own Channel ID? (y/n)"
read -r use_custom_channel

channel_id="channel-0" 

if [ "$use_custom_channel" = "y" ]; then
    echo "Enter your custom Channel ID: eg. channel-1357"
    read -r channel_id
fi

transfer_output=$(namada client ibc-gen-shielded --target $ALIAS-paymentAddress --token NAAN --amount "$amount" --channel-id "$channel_id" --node $RPC)
echo "$transfer_output"
print_green "✓ Shielded transfer initiated for NAAN"
memo_filename=$(echo "$transfer_output" | grep -o 'ibc_shielded_transfer_[^ ]*.memo')


if [ -z "$memo_filename" ]; then
    print_red "✗ Failed to extract memo file name."
    exit 1
fi


   print_yellow "Enter the receiver address:"
read -p $'➜ ' receiver_address
echo ""

receiving_address="$receiver_address"



         print_green "✓ Initiating transfer with memo..."
        echo " "
        print_green "✓ Running Shielded Sync"

        print_yellow "Select Spending key Also know as shielded keys"

aliases=($(namada wallet list | awk -F'"' '
    /^Known shielded keys:/ { printing_aliases = 1 }
    printing_aliases && /^  Alias/ { print $2 }
    /^Known transparent keys:/ { printing_aliases = 0 }
    /^Known payment addresses:/ { printing_aliases = 0; exit }
'))

echo "Now, select an alias:"

# Display the available aliases
index=1
for alias in "${aliases[@]}"; do
    echo "$index: $alias"
    ((index++))
done

read -p "Enter the number of the alias you want to use: " choice
selected_alias="${aliases[$(($choice - 1))]}"
echo "You selected alias: $selected_alias"
aliasspend=$selected_alias
 
 print_green() {
    printf "\033[0;32m$1\033[0m\n"
}

print_yellow() {
    printf "\033[0;33m$1\033[0m\n"
}

print_green "Now Select your Signing Key also known as transparent address"
print_yellow "Select Alias only not address"

# Assuming the derive command is similar to this example (adjust according to the actual command)
addresses=($(namada wallet list | awk '
    /^Known transparent keys:/ { printing_addresses = 1 }
    /^Known shielded keys:/ { printing_addresses = 0 }
    printing_addresses && /^  Alias/ { 
        gsub("Alias ", ""); 
        gsub(" \\(encrypted\\):", ""); 
        gsub("\"", ""); 
        print 
    }
'))

echo "Available Transparent addresses:"


index=1
for address in "${addresses[@]}"; do
    echo "$index: $address"
    ((index++))
done

read -p "Enter the number of the Transparent address you want to use: " choice

selected_address="${addresses[$(($choice - 1))]}"
echo "You selected Transparent address: $selected_address"
signkey=$selected_address



print_green "✓ Initiating transfer"
        echo " "
        print_green "✓ Running Shielded Sync"
  signkey=$selected_address
        namada client   shielded-sync 
  namada client --base-dir $HOME/Library/Application\ Support/Namada ibc-transfer  --source $aliasspend --receiver "$receiver_address" --token NAAN --amount $amount --channel-id channel-2 --memo-path "./$memo_filename" --signing-keys $signkey --node $RPC
        print_green "✓ Transfer completed with memo: \e[93m$memo_filename"
        
   print_yellow "Generating Exchange Value on market NAAN<> OSMO Pair"

# Get current Atom price
atom_price=$(curl -s http://localhost:3000/atom-price | awk -F '[:}]' '{print $2}' | tr -d ' ')
exchange_rate=$(echo "scale=2; $atom_price / 2" | bc)

echo "Current Atom Price = $atom_price"
echo "Calculated Exchange Rate = 1 ATOM OSMO = $exchange_rate NAAN"


naan_amount=$amount 
atom_to_receive=$(echo "scale=2; $naan_amount / $atom_price" | bc)
echo "Amount of Atom to receive for $naan_amount NAAN = $atom_to_receive"


atom_to_receive_int=$(printf "%.0f" "$atom_to_receive")


json_payload="{\"swapAmount\": $atom_to_receive_int}"
echo $json_payload

# Use the constructed JSON payload in the curl command
curl -X POST http://localhost:4000/swap -H "Content-Type: application/json" -d "$json_payload"

curl -X POST http://localhost:4000/getdetails -H "Content-Type: application/json" -d "{\"swapAmount\": $atom_to_receive_int, \"receiverAddress\": \"$receiving_address\"}"
echo "please wait txn is on process"
curl -X POST http://localhost:3500/finalltxn -H "Content-Type: application/json" -d "{\"receiver\": \"$receiving_address\", \"amount\": $atom_to_receive_int}"

        ;;
    1)
        echo "Deriving wallet with alias $ALIAS..."
        namada wallet derive --alias $ALIAS


        print_green "✓ Generating shielded wallet..."
namada wallet gen --shielded --alias "${ALIAS}-spendingKey"
print_green "✓ Alias for shielded wallet: ${ALIAS}-spendingKey"



print_green "✓ Creating payment address..."
namada wallet gen-payment-addr --key "${ALIAS}-spendingKey" --alias "${ALIAS}-paymentAddress"
print_green "✓ Payment address created with alias: ${ALIAS}-paymentAddress"


print_yellow " You have Successfully created Necessary wallet "

        ;;
    2)
      echo "Enter the alias for the new wallet:"
read -p $'➜ ' ALIAS
echo "Creating a new wallet with alias $ALIAS..."
echo "New wallet creation command: namada wallet create --alias $ALIAS"
namada wallet gen --alias $ALIAS


        print_green "✓ Generating shielded wallet..."
namada wallet gen --shielded --alias "${ALIAS}-spendingKey"
print_green "✓ Alias for shielded wallet: ${ALIAS}-spendingKey"



print_green "✓ Creating payment address..."
namada wallet gen-payment-addr --key "${ALIAS}-spendingKey" --alias "${ALIAS}-paymentAddress"
print_green "✓ Payment address created with alias: ${ALIAS}-paymentAddress"



print_yellow " You have Successfully created Necessary wallet"

        ;;
    3)
        
        print_yellow "Swap NAAN <> OSMOSIS"
echo "Note this automatically generate address"
       echo "Please Make sure you have suffiecient Shielded NAAN in your Account"
        print_yellow "Enter the amount to transfer:"
        read -p $'➜ ' amount

        print_green "Paste your Shielded Address (Start with z)"
        read -p $'➜ ' shielded_address

        print_yellow "Generating Exchange Value on market NAAN<> OSMO Pair"

        atom_price=$(curl -s http://localhost:3000/atom-price | awk -F '[:}]' '{print $2}' | tr -d ' ')
        exchange_rate=$(echo "scale=2; $atom_price / 2" | bc)

        echo "Current Atom Price = $atom_price"
        echo "Calculated Exchange Rate = 1 ATOM OSMO = $exchange_rate NAAN"

        transfer_output=$(namada client ibc-gen-shielded --target $ALIAS-paymentAddress --token NAAN --amount "$amount" --channel-id "channel-0" --node $RPC)

        echo "$transfer_output"
        print_green "✓ Shielded swap initiated for $amount NAAN"
        memo_filename=$(echo "$transfer_output" | grep -o 'ibc_shielded_transfer_[^ ]*.memo')
        if [ -z "$memo_filename" ]; then
            print_red "✗ Failed to extract memo file name."
            exit 1
        fi
        print_green "✓ Initiating transfer with memo..."
        echo " "
        print_green "✓ Running Shielded Swap"

        namada client shielded-sync 

        namada client --base-dir $HOME/Library/Application\ Support/Namada ibc-transfer  --source "${ALIAS}-spendingKey" --receiver "osmo1spa8mrur3zqumjuxtdvfgste498hfhtx0l5uhg" --token NAAN --amount "$amount" --channel-id channel-2 --memo-path "./$memo_filename" --signing-keys shieldedaction --node $RPC
        print_green "✓ Transfer completed with memo: $memo_filename"


         
   
        print_green "✓ Generating shielded wallet..."
        namada wallet gen --shielded --alias "${ALIAS}-spendingKey"
        print_green "✓ Alias for shielded wallet: ${ALIAS}-spendingKey"

        # Create payment address
        print_green "✓ Creating payment address..."
        namada wallet gen-payment-addr --key "${ALIAS}-spendingKey" --alias "${ALIAS}-paymentAddress"
        print_green "✓ Payment address created with alias: ${ALIAS}-paymentAddress"

        # Disclaimer for shielded balance
        print_yellow "Note: You must have enough shielded balance to proceed."

        # Prompt for amount input
        print_yellow "Enter the amount to transfer:"
        read -p $'➜ ' amount
        echo ""

        # Execute ibc-gen-shielded command and capture output
        transfer_output=$(namada client ibc-gen-shielded --target $ALIAS-paymentAddress --token NAM --amount "$amount" --channel-id "channel-0" --node $RPC)

        # Echo output for user confirmation
        echo "$transfer_output"
        print_green "✓ Shielded transfer initiated for $amount NAM"

        # Extract memo file name from the output
        memo_filename=$(echo "$transfer_output" | grep -o 'ibc_shielded_transfer_[^ ]*.memo')

        # Check if memo file name was extracted successfully
        if [ -z "$memo_filename" ]; then
            print_red "✗ Failed to extract memo file name."
            exit 1
        fi


        print_yellow "Enter the receiver address:"
        read -p $'➜ ' receiver_address
        echo ""


        print_green "✓ Initiating transfer with memo..."
        echo " "
        print_green "✓ Running Shielded Sync"

        namada client   shielded-sync 

        namada client --base-dir $HOME/Library/Application\ Support/Namada ibc-transfer  --source "${ALIAS}-spendingKey" --receiver "$receiver_address" --token NAM --amount $amount --channel-id channel-2 --memo-path "./$memo_filename" --signing-keys shieldedaction --node $RPC
        print_green "✓ Transfer completed with memo: \e[93m$memo_filename"


           print_yellow "Generating Exchange Value on market NAAN<> OSMO Pair"

# Get current Atom price
atom_price=$(curl -s http://localhost:3000/atom-price | awk -F '[:}]' '{print $2}' | tr -d ' ')
exchange_rate=$(echo "scale=2; $atom_price / 2" | bc)

echo "Current Atom Price = $atom_price"
echo "Calculated Exchange Rate = 1 ATOM OSMO = $exchange_rate NAAN"


naan_amount=$amount # Amount of NAAN you want to send
atom_to_receive=$(echo "scale=2; $naan_amount / $atom_price" | bc)
echo "Amount of Atom to receive for $naan_amount NAAN = $atom_to_receive"

# Construct the JSON payload with the correct format
atom_to_receive_int=$(printf "%.0f" "$atom_to_receive")

# Construct the JSON payload with the correct format
json_payload="{\"swapAmount\": $atom_to_receive_int}"
echo $json_payload

# Use the constructed JSON payload in the curl command
curl -X POST http://localhost:4000/swap -H "Content-Type: application/json" -d "$json_payload"

curl -X POST http://localhost:4000/getdetails -H "Content-Type: application/json" -d "{\"swapAmount\": $atom_to_receive_int, \"receiverAddress\": \"$receiving_address\"}"
echo "Please wait while txn is processing"


curl -X POST http://localhost:3500/finalltxn -H "Content-Type: application/json" -d "{\"receiver\": \"$receiving_address\", \"amount\": $atom_to_receive_int}"


;;

  4)
        echo "Performing Shielded Action (IBC NAAN<>NAAN)"
     

        echo $'\e[38;5;111mSelect an option:\e[0m'
        echo "0. Use an existing wallet"
        echo "1. Derive a wallet"
        echo "2. Create a new wallet"

        read -p "Enter your choice: " sub_option

        case $sub_option in
            0)
                echo "Using an existing wallet"
              
              print_yellow "Select Alias Only"

addresses=($(namada wallet list | awk '
    /^Known transparent keys:/ { printing_addresses = 0 }
    /^Known shielded keys:/ { printing_addresses = 0 }
    /^Known payment addresses:/ { printing_addresses = 1 }
    printing_addresses && /^  "[^"]+":/ { gsub(/^  "|":/, ""); print }
'))

echo "Now, select a payment address:"

# Display the available payment addresses
index=1
for address in "${addresses[@]}"; do
    echo "$index: $address"
    ((index++))
done


# Assuming you have a variable containing the list of payment addresses, adjust this accordingly
read -p "Enter the number of the payment address you want to use: " choice

# Get the selected payment address
selected_address="${addresses[$(($choice - 1))]}"
echo "You selected payment address: $selected_address"
    paymentAddress=$selected_address

       # Prompt for amount input
    while true; do
    print_yellow "Enter the amount to transfer (Min 40): "
    read -p $'➜ ' amount

    if [[ $amount -ge 40 ]]; then
        break
    else
        echo "Amount must be at least 40. Please try again."
    fi
done

echo "Amount entered: $amount"
echo "Performing IBC-Gen-Shielded"

echo "Do you want to use your own Channel ID? (y/n)"
read -r use_custom_channel

channel_id="channel-0" 

if [ "$use_custom_channel" = "y" ]; then
    echo "Enter your custom Channel ID: eg. channel-1357"
    read -r channel_id
fi

transfer_output=$(namada client ibc-gen-shielded --target $ALIAS-paymentAddress --token NAAN --amount "$amount" --channel-id "$channel_id" --node $RPC)
echo "$transfer_output"
print_green "✓ Shielded transfer initiated for NAAN"
memo_filename=$(echo "$transfer_output" | grep -o 'ibc_shielded_transfer_[^ ]*.memo')

# Check if memo file name was extracted successfully
if [ -z "$memo_filename" ]; then
    print_red "✗ Failed to extract memo file name."
    exit 1
fi


   print_yellow "Enter the receiver address: (znam..(Shielded Action NAAN<>NAAN(Shielded IBC)))"
read -p $'➜ ' receiver_address
echo ""

receiving_address="$receiver_address"



         print_green "✓ Initiating transfer with memo..."
        echo " "
        print_green "✓ Running Shielded Sync"

        print_yellow "Select Spending key Also know as shielded keys"

aliases=($(namada wallet list | awk -F'"' '
    /^Known shielded keys:/ { printing_aliases = 1 }
    printing_aliases && /^  Alias/ { print $2 }
    /^Known transparent keys:/ { printing_aliases = 0 }
    /^Known payment addresses:/ { printing_aliases = 0; exit }
'))

echo "Now, select an alias:"

# Display the available aliases
index=1
for alias in "${aliases[@]}"; do
    echo "$index: $alias"
    ((index++))
done

read -p "Enter the number of the alias you want to use: " choice
selected_alias="${aliases[$(($choice - 1))]}"
echo "You selected alias: $selected_alias"
aliasspend=$selected_alias
 
 print_green() {
    printf "\033[0;32m$1\033[0m\n"
}

print_yellow() {
    printf "\033[0;33m$1\033[0m\n"
}

print_green "Now Select your Signing Key also known as transparent address"
print_yellow "Select Alias only not address"

# Assuming the derive command is similar to this example (adjust according to the actual command)
addresses=($(namada wallet list | awk '
    /^Known transparent keys:/ { printing_addresses = 1 }
    /^Known shielded keys:/ { printing_addresses = 0 }
    printing_addresses && /^  Alias/ { 
        gsub("Alias ", ""); 
        gsub(" \\(encrypted\\):", ""); 
        gsub("\"", ""); 
        print 
    }
'))

echo "Available Transparent addresses:"

index=1
for address in "${addresses[@]}"; do
    echo "$index: $address"
    ((index++))
done

read -p "Enter the number of the Transparent address you want to use: " choice

selected_address="${addresses[$(($choice - 1))]}"
echo "You selected Transparent address: $selected_address"
signkey=$selected_address



print_green "✓ Initiating transfer"
        echo " "
        print_green "✓ Running Shielded Sync"
  signkey=$selected_address
        namada client   shielded-sync 
  namada client --base-dir $HOME/Library/Application\ Support/Namada ibc-transfer  --source $aliasspend --receiver "$receiver_address" --token NAAN --amount 10 --channel-id channel-2 --memo-path "./$memo_filename" --signing-keys $signkey --node $RPC
        print_green "✓ Transfer completed with memo: \e[93m$memo_filename"



                ;;
            1)
                echo "Deriving a wallet And Perform Shielded Action"
                read -p "Enter the alias of the wallet: " ALIAS
                echo "Deriving wallet with alias $ALIAS..."
                namada wallet derive --alias $ALIAS

            print_yellow "✓ Now you can proceed with Menu 0"
                ;;
            2)
         echo "Creating a new wallet with alias $ALIAS..."
        echo "New wallet creation command: namada wallet create --alias $ALIAS"
         namada wallet gen --alias $ALIAS
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac
        ;;


        5)
          print_yellow "✓ Getting Started"

        print_green "Now Select your Signing Key also known as transparent address"
print_yellow "Select Alias only not address"

# Assuming the derive command is similar to this example (adjust according to the actual command)
addresses=($(namada wallet list | awk '
    /^Known transparent keys:/ { printing_addresses = 1 }
    /^Known shielded keys:/ { printing_addresses = 0 }
    printing_addresses && /^  Alias/ { 
        gsub("Alias ", ""); 
        gsub(" \\(encrypted\\):", ""); 
        gsub("\"", ""); 
        print 
    }
'))

echo "Available Transparent addresses:"


index=1
for address in "${addresses[@]}"; do
    echo "$index: $address"
    ((index++))
done

read -p "Enter the number of the Transparent address you want to use: " choice

selected_address="${addresses[$(($choice - 1))]}"
echo "You selected Transparent address: $selected_address"
signkey=$selected_address


echo "now select for the payment address (znam)"

 echo "Finding Shielded address from existing wallet"
              
              print_yellow "Select Alias Only"

addresses=($(namada wallet list | awk '
    /^Known transparent keys:/ { printing_addresses = 0 }
    /^Known shielded keys:/ { printing_addresses = 0 }
    /^Known payment addresses:/ { printing_addresses = 1 }
    printing_addresses && /^  "[^"]+":/ { gsub(/^  "|":/, ""); print }
'))

echo "Now, select a payment address:"

# Display the available payment addresses
index=1
for address in "${addresses[@]}"; do
    echo "$index: $address"
    ((index++))
done


read -p "Enter the number of the payment address you want to use: " choice


selected_address="${addresses[$(($choice - 1))]}"
echo "You selected payment address: $selected_address"
    paymentAddress=$selected_address


 print_yellow "Enter the amount to shield: "
    read -p $'➜ ' amount

namada client transfer --source $signkey --target $paymentAddress --token NAAN --amount $amount --node $RPC

if [ $? -eq 0 ]; then
    # Print "✓Transaction Done" in green if successful
    print_green "✓Transaction Done"
else
    # Print an error message if an error occurs
    echo "Error: Transaction failed"
fi

        ;;

        *)
            echo "Invalid choice. Please try again."
            ;;
    esac

    read -p "Press Enter to closed the application."
    clear

