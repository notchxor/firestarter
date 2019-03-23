SYSTEM_ACCOUNTS="eosio.bpay eosio.msig eosio.names eosio.ram eosio.ramfee eosio.saving eosio.stake eosio.token
eosio.vpay eosio.sudo"

EOS_ISSUE="1000000000.0000 "$CORE_SYMBOL
tmp=$(mktemp)
###################################################
#      KEYS
###################################################
EOSIO_PUB=EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV
EOSIO_PRIV=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3


SIGN_PUB=EOS7HWfNo5DHkWndg48xQfn5EGBvz3XxoveCtjQ2GHVmAg5ibZRNN
SIGN_PRIV=5J4gZSeebvRK7ZFxcL4WqV4Lhttm7453B6duCGxYjC6DM9SN6uu

BPS="aaablockprod bbbblockprod cccblockprod dddblockprod eeeblockprod fffblockprod gggblockprod hhhblockprod iiiblockprod jjjblockprod kkkblockprod lllblockprod mmmblockprod nnnblockprod oooblockprod pppblockprod qqqblockprod rrrblockprod sssblockprod tttblockprod uuublockprod vvvblockprod wwwblockprod"
EXTRA="devdevdevdev xxxblockprod yyyblockprod zzzblockprod tstblockprod"

# Create wallet
./cleos.sh wallet create --to-console > wallet.txt

# import private key
./cleos.sh wallet import --private-key=$EOSIO_PRIV


# set bios
echo "SET BIOS ################################"
./cleos.sh set contract eosio /contracts/eosio.bios

# Create system accounts
for account in  $SYSTEM_ACCOUNTS;do
    ./cleos.sh create account eosio $account $EOSIO_PUB
done

# Set contracts
echo "SET CONTRACTS ###################"
./cleos.sh set contract eosio.token /contracts/eosio.token
./cleos.sh set contract eosio.msig  /contracts/eosio.msig
./cleos.sh set contract eosio.sudo  /contracts/eosio.sudo

# Create BP accounts
echo "CREATE BP ACCOUNTS ##########################"
for BP in  $BPS ;do
    ./cleos.sh create account eosio $BP $EOSIO_PUB $EOSIO_PUB
 #   ./cleos.sh system newaccount eosio $BP $EOSIO_PUB $EOSIO_PUB  --stake-net "100000.0000 EOS" --stake-cpu "1000000.0000 EOS" --buy-ram "10000.0000 EOS"
done

for BP in  $EXTRA ;do
    ./cleos.sh create account eosio $BP $EOSIO_PUB $EOSIO_PUB
 #   ./cleos.sh system newaccount eosio $BP $EOSIO_PUB $EOSIO_PUB  --stake-net "100000.0000 EOS" --stake-cpu "1000000.0000 EOS" --buy-ram "10000.0000 EOS"
done


# SET PRODUCERS
echo "SET PRODUCERS ##################"
echo '{schedule : [' > bp.json
for bp in $BPS; do
        echo '{"producer_name":"'$bp'","block_signing_key":"'$SIGN_PUB'"}' >> bp.json
        done
        echo ']}' >> bp.json

        ./cleos.sh push action eosio setprods "$(cat bp.json)"  -p eosio

# Issue eosio
echo "ISSUING EOSIO ##################"
./cleos.sh push action eosio.token create '[ "eosio","1000000000.0000 EOS"]' -p eosio.token
./cleos.sh push action eosio.token issue '["eosio","1000000000.0000 EOS", "issue EOS"]' -p eosio



# set system
echo "SET SYSTEM ##################"
./cleos.sh set contract  eosio /contracts/eosio.system 
 # Privilegios
echo "PRIVILEGIOS ###############"
./cleos.sh push action eosio setpriv  '["eosio.msig", 1]' -p eosio@active



#RESIGN ACCOUNTS
echo "RESIGN ACCOUNTS #####################"
echo  '{"account": "eosio", "permission": "active", "parent": "owner", "auth":{"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio.prods", "permission": active}}]}}' > tmp
./cleos.sh push action eosio updateauth "$(cat tmp)" -p eosio@active
echo '{"account": "eosio", "permission": "owner", "parent": "", "auth":{"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio.prods", "permission": active}}]}}' > tmp
./cleos.sh push action eosio updateauth "$(cat tmp)" -p eosio@owner

for account in  $SYSTEM_ACCOUNTS;do
  echo  '{"account": "'$account'", "permission": "active", "parent": "owner", "auth":{"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": active}}]}}' > tmp
 ./cleos.sh push action eosio updateauth "$(cat tmp)" -p $account@active
  echo '{"account": "'$account'", "permission": "owner", "parent": "", "auth":{"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": active}}]}}' > tmp
 ./cleos.sh push action eosio updateauth "$(cat tmp)" -p $account@owner
done


# Transfer Tokens to devdevdevdev
echo "Transfer tokens to dev account"
./cleos.sh system buyram -k eosio devdevdevdev 1000
./cleos.sh transfer eosio devdevdevdev "500000000.0000 EOS" "it's xmas"
# delegatebw
echo "Delegatebw dev"
./cleos.sh system delegatebw devdevdevdev devdevdevdev "100000000.0000 EOS" "100000000.0000 EOS"

# reg prod
echo "regprod dev"
./cleos.sh system regproducer devdevdevdev EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV  https://www.eosargentina.io 32

for bp in $BPS;do
    ./cleos.sh system regproducer $bp EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV  https://www.$bp.io 32;done
# Vote for producers
echo "voteproducers"
./cleos.sh system voteproducer prods devdevdevdev $BPS

