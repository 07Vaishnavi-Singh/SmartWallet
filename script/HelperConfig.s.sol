// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import  {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

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
address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
address constant BURNER_WALLET = 0x643315C9Be056cDEA171F4e7b2222a4ddaB9F88D;

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
            entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
            usdc: 0x53844F9577C2334e541Aec7Df7174ECe5dF1fCf0,
            account: BURNER_WALLET
        });
    }

    // gives netork configs of zksepolia 
    function getZKSyncSeploia() internal view returns(NetworkConfigs memory){
        return NetworkConfigs({
            entryPoint :  0x0576a174D229E3cFA37253523E645A78A0C91B57 ,
            usdc : 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238 ,
            account : ""
        });
    }

     function getConfig() public returns (NetworkConfigs memory) {
        return getConfigByChainId(block.chainid);
    }

    // gets network configs by chain Id 
    function getConfigByChainId(uint256 chainId) public view returns (NetworkConfigs memory) {
        if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else if (chainIdToNetworkConfigs[chainId].account != address(0)) {
            return chainIdToNetworkConfigs[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

     function getOrCreateAnvilEthConfig() public returns (NetworkConfigs memory) {
           if (localNetworkConfig.account != address(0)) {
            return localNetworkConfig;
        }

        // deploy mocks
        console2.log("Deploying mocks...");
        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);
        EntryPoint entryPoint = new EntryPoint();
        ERC20Mock erc20Mock = new ERC20Mock();
        vm.stopBroadcast();
        console2.log("Mocks deployed!");

        localNetworkConfig =
            NetworkConfigs({entryPoint: address(entryPoint), usdc: address(erc20Mock), account: ANVIL_DEFAULT_ACCOUNT});
        return localNetworkConfig;
    }

}
 