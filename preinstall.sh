#!/bin/sh

export CHANNEL_NAME="mychannel"
export BLOCKFILE="${CHANNEL_NAME}.block"
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

. ./scripts/utils.sh 

if [ ! -d ./fabric-samples ]; then
  curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.8 1.4.9
fi

# Generate MSP dir
export PATH=$PATH:./fabric-samples/bin
export FABRIC_CFG_PATH=${PWD}/configtx

# This shell file based on fabric-test-network
echo "Removing Previous Directories"
rm -rf ./organizations/ordererOrganizations
rm -rf ./organizations/peerOrganizations
rm -rf ./system-genesis-block
rm -rf ./fabric-ca-shared

echo "Creating ./fabric-ca-shared"
mkdir -p ./fabric-ca-shared

# createOrgs()
echo "Generating MSP"
cryptogen generate --config=./crypto-config.yaml --output=./organizations

# createConsortium()
echo "Generate Consortium"
echo "Create Channel Tx (Genesis Tx)"
configtxgen -profile TwoOrgsOrdererGenesis \
            -channelID  $CHANNEL_NAME \
            -outputBlock ./system-genesis-block/genesis.block
            
kubectl apply -f ./kubernetes/fabric-ca.yaml


# createChannelTx() 
# . organizations/fabric-ca/registerEnroll.sh
# createOrderer

# while :
# do
# if [ ! -f "organizations/fabric-ca/org1/tls-cert.pem" ]; then
# sleep 1
# else
# break
# fi
# done


mkdir -p organizations/ordererOrganizations/example.com
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

# set -x
# fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
# { set +x; } 2>/dev/null

echo 'NodeOUs:
Enable: true
ClientOUIdentifier:
  Certificate: cacerts/localhost-9054-ca-orderer.pem
  OrganizationalUnitIdentifier: client
PeerOUIdentifier:
  Certificate: cacerts/localhost-9054-ca-orderer.pem
  OrganizationalUnitIdentifier: peer
AdminOUIdentifier:
  Certificate: cacerts/localhost-9054-ca-orderer.pem
  OrganizationalUnitIdentifier: admin
OrdererOUIdentifier:
  Certificate: cacerts/localhost-9054-ca-orderer.pem
  OrganizationalUnitIdentifier: orderer' >"${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

# export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

# set -x
# fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
# { set +x; } 2>/dev/null

# createChannel()
# echo "Creating Consortium (Genesis Block)"
# echo $FABRIC_CFG_PATH
# peer channel create -o localhost:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock $BLOCKFILE --tls --cafiyle $ORDERER_CA

# docker-compose up (apply kuberntes yaml files)
kubectl apply -f ./kubernetes/orderer.yaml &&
  kubectl apply -f ./kubernetes/pv.yaml && \
  kubectl apply -f ./kubernetes/pvc.yaml && \
  kubectl apply -f ./kubernetes/org1-peer1.yaml && \
  kubectl apply -f ./kubernetes/org1-peer2.yaml
