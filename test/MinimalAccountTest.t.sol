// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";
import {DeployMinimal} from "../script/Deploy.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract MinimalAccountTest is Test {

HelperConfig public  helperConfigs;
MinimalAccount public  minimalAccount;

function setup() public {
    DeployMinimal deploy = new Deploy();
   ( helperConfigs,  minimalAccount ) = deploy.deployMinimalContract();
}





}