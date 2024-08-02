// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {PackedUserOperation} from "../lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {IEntryPoint} from "../lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

    contract SendUserOperation is Script {

        function run() public{
            generateUserOperation();
        }

        function generateUserOperation(bytes memory callData, HelperConfig.NetworkConfigs memory config) public returns(PackedUserOperation memory){

            // genarte unsigned data
            uint256 nonce = vm.getNonce(config.account);
            PackedUserOperation unsignedUserOps = _generateUnsignedUserOperation(callData, config.account, nonce );
            // get userOphash 
            bytes32 userOpHash = IEntryPoint(config.account).getUserOpHash(unsignedUserOps);
            bytes32 digest = userOpHash.toEthSignedMessageHash(); 
            // sign it 
            uint8 v;
            bytes32 r;
            bytes32 s;
            uint256 ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
            if (block.chainid == 31337) {
                (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, digest);
            } else {
                (v, r, s) = vm.sign(config.account, digest);
            }
            unsignedUserOps.signature = abi.encodePacked(r,s,v);
            // return it 
            return unsignedUserOps;
        }
    
        function _generateUnsignedUserOperation(bytes memory callData, address sender, uint256 nonce ) internal pure returns(PackedUserOperation memory){
            uint128 verificationGasLimit = 16777216;
            uint128 callGasLimit = verificationGaLimit;
            uint128 maxPriorityFeePerGas = 256;
            uint128 maxFeePerGas = maxPriorityFeePerGas;
             
            return PackedUserOperation({
                sender : sender,
                nonce: nonce, 
                initCode : hex"",
                callData: callData ,
                accountGasLimits : bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
                preVerificationGas: verificationGasLimit,
                gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
                paymasterAndData: hex"",
                signature: hex""
            });
        }
    
    }