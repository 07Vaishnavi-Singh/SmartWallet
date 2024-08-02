// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol" ; // has vm methods to interact with the ethereum network on chain 
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployMinimal is Script {

    function run() public {
        // caling the deployment function 
        deployMinimalContract();
    }

    function deployMinimalContract() internal returns(HelperConfig memory, MinimalAccount) {
        // creates a new config instance 
        HelperConfig helperConfig = new HelperConfig();
        // fetches configs from HelperConfigs 
        HelperConfig.NetworkConfigs memory config = helperConfig.getConfig();
        vm.startBroadcast();
        // deploys the contract with above configs 
        MinimalAccount minimalAccount = new MinimalAccount(config.entryPoint);
        minimalAccount.transferOwnership(config.account);
        vm.stopBroadcast();
    }
}
