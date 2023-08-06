#!/bin/bash

set -e

### How to run:
# bash generate-wallets.sh (node_count=2 and validator_per_node=2)
# NODE_COUNT=1 bash generate-wallets.sh (node_count=1 and validator_per_node=2)
# VALIDATOR_PER_NODE=10 bash generate-wallets.sh (node_count=2 and validator_per_node=10)
# NODE_COUNT=10 VALIDATOR_PER_NODE=1000 bash generate-wallets.sh (node_count=10 and validator_per_node=1000)
# NODE_COUNT=10 VALIDATOR_PER_NODE=1000 bash generate-wallets.sh (node_count=10 and validator_per_node=1000)
###

PRYSM_VERSION=4.0.3
SECRET_LENGTH=32
START_INDEX=${START_INDEX:-0}
VALIDATOR_PER_NODE=${VALIDATOR_PER_NODE:-2}
NODE_COUNT=${NODE_COUNT:-2}
NODE_PREFIX_NAME=${NODE_PREFIX_NAME:-"leequid"}
NETWORK=${NETWORK:-"mainnet"}
BUCKET=${BUCKET:-"leequid-prod-staking"}
ENV=${ENV:-"prod"}
WITHDRAWAL_ADDRESS=${WITHDRAWAL_ADDRESS:-"0xAED7cD8d3105F4d6B4dDF99f619dCB2a26D0a900"}
GSM_PROJECT=${GSM_PROJECT:-"leequid-secret"}
ONLINE=${ONLINE:-false}

fmt="%-25s%-25s\n"
printf "$fmt" VARIABLE VALUE
printf "$fmt" -------- -----
printf "$fmt" "START_INDEX" "$START_INDEX"
printf "$fmt" "NODE_COUNT" "$NODE_COUNT"
printf "$fmt" "VALIDATOR_PER_NODE" "$VALIDATOR_PER_NODE"
printf "$fmt" "TOTAL_VALIDATOR (*)" "$(($NODE_COUNT*$VALIDATOR_PER_NODE))"
printf "$fmt" "NETWORK" "$NETWORK"
printf "$fmt" "WITHDRAWAL_ADDRESS" "$WITHDRAWAL_ADDRESS"
printf "$fmt" "ENV" "$ENV"
printf "$fmt" "BUCKET" "$BUCKET"
printf "$fmt" "GSM_PROJECT" "$GSM_PROJECT"
printf "$fmt" "SECRET_LENGTH" "$SECRET_LENGTH"
printf "$fmt" "PRYSM_VERSION" "$PRYSM_VERSION"
printf "$fmt" "ONLINE" "$ONLINE"
echo "--------"
echo -e "(*) Non-existent variable only informative.\n"

read -r -p "Do you want to continue? [y/N] " response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo "Wallet generation aborted."
  exit 0
fi

echo -e ">> Create directory [leequid] and download tools [prysm + lukso-key-gen]"
dir=$NODE_PREFIX_NAME
mkdir -p $dir
if [ "$ONLINE" = true ]; then
  curl -Ls https://github.com/prysmaticlabs/prysm/releases/download/v$PRYSM_VERSION/validator-v$PRYSM_VERSION-linux-amd64 \
      --output prysm-validator && chmod +x prysm-validator
  curl -LOs https://github.com/percenuage/tools-key-gen-cli/releases/download/lukso-network-pr30/lukso-key-gen-cli \
      && chmod +x lukso-key-gen-cli
fi

echo -e "\n>> Generate random wallet secret [$dir/wallet-password.txt]"
WALLET_PASSWORD=$(openssl rand -base64 $SECRET_LENGTH)
echo $WALLET_PASSWORD > $dir/wallet-password.txt

if [ "$ONLINE" = true ]; then
  echo -e "\n>> Save wallet password to Google Secret [${ENV}-${NETWORK}-${NODE_PREFIX_NAME}-wallet-password]"
  gcloud secrets create ${ENV}-${NETWORK}-${NODE_PREFIX_NAME}-wallet-password \
      --data-file=$dir/wallet-password.txt --project $GSM_PROJECT
fi

echo -e "\n>> Iterate over [node_count=$NODE_COUNT]"
for (( i=$START_INDEX; i<$(($NODE_COUNT+$START_INDEX)); i++ )); do
  node_name=${NODE_PREFIX_NAME}-${i}
  mnemonic_file=${dir}/${node_name}-mnemonic
  wallet_file=${dir}/${node_name}-wallet.json
  deposit_file=${dir}/${node_name}-deposit.json
  deposit_all_file=${dir}/${NODE_PREFIX_NAME}-deposit.json

  echo -e "\n>>> [$node_name] Generate keystore and mnemonic [num_validators=$VALIDATOR_PER_NODE] using lukso-key-gen-cli"
  ./lukso-key-gen-cli --language English new-mnemonic --mnemonic_language English --chain lukso \
      --num_validators $VALIDATOR_PER_NODE \
      --keystore_password $WALLET_PASSWORD \
      --folder $dir \
      --mnemonic_file $mnemonic_file \
      --eth1_withdrawal_address $WITHDRAWAL_ADDRESS

  echo -e "\n>>> [$node_name] Copy deposit to [$deposit_file]"
  chmod +w $dir/validator_keys/deposit*.json
  cp $dir/validator_keys/deposit*.json $deposit_file

  echo -e "\n>>> [$node_name] Generate wallet [$dir/wallet] using prysm-validator"
  ./prysm-validator accounts import \
    --keys-dir=$dir/validator_keys \
    --wallet-dir=$dir/wallet \
    --wallet-password-file=$dir/wallet-password.txt \
    --account-password-file=$dir/wallet-password.txt \
    --accept-terms-of-use

  echo -e "\n>>> [$node_name] Copy wallet json file to [$wallet_file]"
  cp $dir/wallet/direct/accounts/all-accounts.keystore.json $wallet_file

  if [ "$ONLINE" = true ]; then
    echo -e "\n>>> [$node_name] Save wallet json file to Google Secret [${ENV}-${NETWORK}-${node_name}-wallet-file]"
    gcloud secrets create ${ENV}-${NETWORK}-${node_name}-wallet-file \
        --data-file=$wallet_file --project $GSM_PROJECT
  fi

  rm -rf $dir/validator_keys $dir/wallet
done

echo -e "\n>> Merge all deposit wallet to [${NODE_PREFIX_NAME}-deposit.json]"
jq -s 'add' $dir/*deposit.json > $deposit_all_file

if [ "$ONLINE" = true ]; then
  echo -e "\n>> Save all deposits to [gs://$BUCKET/$NETWORK/]"
  gsutil -m cp ${dir}/*deposit.json gs://$BUCKET/$NETWORK/

  echo -e "\n>> Clean all except mnemonic files"
  rm -rf $dir/*deposit* $dir/*wallet*
else
  echo -e "\n>> [Manual] How to save secrets and deposits [Replace \$INDEX by 0,1,2,3,...]"
  echo "$ ls -l $dir"
  echo "-------------------------------"
  ls -l $dir
  echo "-------------------------------"
  echo "$ gcloud secrets create ${ENV}-${NETWORK}-${NODE_PREFIX_NAME}-wallet-password --data-file=$dir/wallet-password.txt --project $GSM_PROJECT"
  echo "$ gcloud secrets create ${ENV}-${NETWORK}-${NODE_PREFIX_NAME}-\$INDEX-wallet-file --data-file=$dir/${NODE_PREFIX_NAME}-\$INDEX-wallet.json --project $GSM_PROJECT"
  echo "$ gsutil -m cp $dir/*deposit.json gs://$BUCKET/$NETWORK/"
fi
