#!/bin/sh

curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.8 1.5.3

export PATH=$PATH:./fabric-samples/bin/
# Generate MSP dir

echo "Generating MSP"
cryptogen generate --config=./crypto-config.yaml --output=./crypto-config



# Generate genesis Tx
export FABRIC_CFG_PATH=$PWD

# Generate genesis block




