// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {IAccount} from "../../lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "../../lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol" ;
import {MessageHashUtils} from  "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "../../lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "../../lib/account-abstraction/contracts/interfaces/IEntryPoint.sol" ;

// enrtypoint -> this contract 
// nonce managemnegt is not required as it is done automatically by entry point 
contract MinimalAccount is IAccount, Ownable{

error Call_Not_From_EntryPoint();
error CALL_NOT_FROM_ENTRYPOINT_OR_OWNER();
error FUNCTION_CALL_FAILED(bytes  );

    IEntryPoint internal immutable entryPoint ;

    constructor (address _entryPoint) Ownable(msg.sender){
        entryPoint = IEntryPoint(_entryPoint);
    }

    modifier onlyEntryPoint(){
        if( msg.sender != address(entryPoint)){
            revert Call_Not_From_EntryPoint(); 
           }
        _;
    }

    modifier onlyEntryPointOrOwner(){
        if(msg.sender != owner() || msg.sender != address(entryPoint)){
            revert CALL_NOT_FROM_ENTRYPOINT_OR_OWNER();
        }
        _;
    }
// first thing is to validate if the user opertaion receive din valud or not 
// the function for this is in the IAccount contract
// so inheriting the contract to make use of the function 
function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds // how much the txn costs and that needs to be sent back to entry point
    )external onlyEntryPoint  returns (uint256 validationData){
        _validateSignature(userOp,userOpHash);
        _prefund(missingAccountFunds);
    }

// EIP-191 of the signed hash is the userOphash 
// we need to change its format 
// logic for checkng the sinature the way u want 
 function _validateSignature( 
        PackedUserOperation calldata userOp,
        bytes32 userOpHash ) 
        internal view returns(uint256 validateData){
            // comverts the signed hash to athe right format 
            bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
            address  signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);
            if(signer != owner()){
                return SIG_VALIDATION_FAILED ;
            }
            else{
                return SIG_VALIDATION_SUCCESS ;
            }
        }   

    function _prefund(uint256 missingAccountFunds) internal  returns(bool ){
        // gas limit to execute this txn is kep tas infinite as we want this call to execute no matter what 
        // uint value represents the value of ethers that needs to be sent to the address
        // can be hardcoded 
        (bool success, ) = payable(msg.sender).call{value: missingAccountFunds, gas : type(uint256).max}("");
        return success ;
     }

    function getEntryPoint() external view returns(IEntryPoint){
        return entryPoint ;
     }

    function execute(address dest, uint _value ,bytes memory functionData) external onlyEntryPointOrOwner  returns(bool){
        (bool success,bytes memory result ) = dest.call{value: _value}(functionData);
        if(success != true){
            revert FUNCTION_CALL_FAILED(result); 
        }
    }

}





