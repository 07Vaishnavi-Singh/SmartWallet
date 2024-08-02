// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";
import {DeployMinimal} from "../script/DeployMinimal.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {SendUserOperation} from "../script/SendUserOperation.s.sol";

contract MinimalAccountTest is Test {

HelperConfig public  helperConfigs;
MinimalAccount public  minimalAccount;
ERC20Mock public usdc;
uint256 constant AMOUNT = 1e18 ;


function setup() public {
    DeployMinimal deploy = new Deploy();
   ( helperConfigs,  minimalAccount ) = deploy.deployMinimalContract();
   usdc  = new ERC20Mock();
}

function shouldExecuteByOwner() public {
    //arrange 
    assertEq(usdc.balanceOf(address(minimalAccount)),0);
    address dest = address(usdc);
    uint256 vlaue = 0 ;
    bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount),AMOUNT );

    // act 
    vm.prank(MinimalAccount.owner());
    MinimalAccount.execute(dest, vlaue, functionData);

    // test 
    assertEq(usdc.balanceOf(address(MinimalAccount)),1);

}


        function testSignedUserOperation() public view{

        // arrange 
        assertEq(usdc.balanceOf(address(minimalAccount)),0);
        address dest = address(usdc);
        uint256 vlaue = 0 ;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount),AMOUNT );

        bytes memory executeCallData = abi.encodeWithSelector(MinimalAccount.execute.selector, dest, value, functionData);

        PackedUserOperation memory packedUserOp = sendPackedUserOp.generateSignedUserOperation(
            executeCallData, helperConfig.getConfig(), address(minimalAccount)
        );
        bytes32 userOperationHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);

        // Act
        address actualSigner = ECDSA.recover(userOperationHash.toEthSignedMessageHash(), packedUserOp.signature);

        // Assert
        assertEq(actualSigner, minimalAccount.owner());

            }

        function testValidationOfUserOps() public{
             // Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        bytes memory executeCallData =
            abi.encodeWithSelector(MinimalAccount.execute.selector, dest, value, functionData);
        PackedUserOperation memory packedUserOp = sendPackedUserOp.generateSignedUserOperation(
            executeCallData, helperConfig.getConfig(), address(minimalAccount)
        );
        bytes32 userOperationHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);
        uint256 missingAccountFunds = 1e18;

        // Act
        vm.prank(helperConfig.getConfig().entryPoint);
        uint256 validationData = minimalAccount.validateUserOp(packedUserOp, userOperationHash, missingAccountFunds);

        assertEq(validationData, 0);

        }



  function testEntryPointCanExecuteCommands() public skipZkSync {
        // Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        bytes memory executeCallData =
            abi.encodeWithSelector(MinimalAccount.execute.selector, dest, value, functionData);
        PackedUserOperation memory packedUserOp = sendPackedUserOp.generateSignedUserOperation(
            executeCallData, helperConfig.getConfig(), address(minimalAccount)
        );
        // bytes32 userOperationHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);

        vm.deal(address(minimalAccount), 1e18);

        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = packedUserOp;

        // Act
        vm.prank(randomuser);
        IEntryPoint(helperConfig.getConfig().entryPoint).handleOps(ops, payable(randomuser));

        // Assert
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }
}
