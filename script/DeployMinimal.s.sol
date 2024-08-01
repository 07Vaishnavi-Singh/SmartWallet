// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol" ; // has vm methods to interact with the ethereum network on chain 
import {MinimalAccount} from "../src/ethereum/MinimalAccount..sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployMinimal is Script {

    // this is the entry point function of the script 
    function run() public {
        deployMinimalContract();
    }

    function deployMinimalContract() internal returns(HelperConfigs, MinimalAccount) {
        HelperConfig helperConfig = new HelperConfig();
        helperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(block.chainId);

        vm.startBroadcast();();
        MinimalAccount minimalAccount = new MinimalAccount(config.entryPoint);

        vm.stopBroadcast();
    }
}