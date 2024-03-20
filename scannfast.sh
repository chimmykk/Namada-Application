#!/bin/bash
if ! command -v jq &> /dev/null
then
   
    sudo apt update

    # Install jq
    sudo apt install -y jq
fi


height=0

max_height=$(curl -s https://indexer.semjjonline.xyz/block/last/ | jq -r '.header.height')


while [ $height -le $max_height ]; do

    namadac shielded-sync --node http://127.0.0.1:26657 --height $height

    # Increment the height based on the current value
    if [ $height -lt 1000 ]; then
        height=$((height + 1000))
    elif [ $height -lt 10000 ]; then
        height=$((height + 10000))
    else
        height=$((height + 100000))
    fi
done


