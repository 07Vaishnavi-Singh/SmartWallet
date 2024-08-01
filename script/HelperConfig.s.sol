// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script{


struct NetworkConfigs{
    address entryPoint;
    address usdc;
    address account;
}

uint256 internal constant ETHEREUM_SEPOLIA_CHAINID = 11155111 ;
uint256 internal constant ZKSYNC_SEPOLIA_CHAINID = 300 ;
uint256 constant LOCAL_CHAIN_ID = 31337;
NetworkConfigs public localNetworkConfig ;

error HelperConfig__InvalidChainId();

mapping(uint => NetworkConfigs) public chainIdToNetworkConfigs;

    // sets the maping for chainI to network configs 
    constructor(){
    chainIdToNetworkConfigs[ETHEREUM_SEPOLIA_CHAINID] = getEthereumSepolia();
    chainIdToNetworkConfigs[ZKSYNC_SEPOLIA_CHAINID] = getEthereumSepolia();
    }

    // gives network configs of ethereum sepolia
    function getEthereumSepolia() internal view returns(NetworkConfigs memory){
        return NetworkConfigs({
            entryPoint :  0x0576a174D229E3cFA37253523E645A78A0C91B57 ;
            usdc : 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238 ;
            account : ;
        })
    }

    // gives netork configs of zksepolia 
    function getZKSyncSeploia() internal view returns(NetworkConfigs memory){
        return NetworkConfigs({
            entryPoint : ;
            usdc : ;
            account ;
        })
    }

    // gets network configs by chain Id 
      function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else if (networkConfigs[chainId].account != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getOrCreateAnvilEthConfig() public view returns(NetworkConfigs memory){
        // returns the network config of local chain of anvil 
        if (localNetworkConfig.account != address(0)) {
            return localNetworkConfig;
        }
    }

}