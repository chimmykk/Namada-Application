# Fetch the value and store it as "ttillfetch" after removing the percentage sign
ttillfetch=$(curl -s https://indexer.semjjonline.xyz/block/last/ | sed -n 's/.*"height":"\([^"]*\).*/\1/p' | tr -d '%')

# Define function to sync shielded data
function sync_shielded_data {
    local start=$1
    local end=$2
    local step=$3

    for ((i=start; i<=end; i+=step)); do
        namadac shielded-sync --node http://127.0.0.1:26657 --height $i
    done
}

# Sync shielded data for ranges
sync_shielded_data 0 100 1
sync_shielded_data 100 1000 100
sync_shielded_data 1000 10000 1

# Incremental sync until 100000
increment=10000
current=10000

while ((current < 100000)); do
    next=$((current + increment))
    sync_shielded_data $current $next 10000
    current=$next
done

# Incremental sync until ttillfetch
increment=100000
current=100000

while ((current < ttillfetch)); do
    next=$((current + increment))
    sync_shielded_data $current $next 10000
    current=$next
done
