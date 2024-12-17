// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/EtherVault.sol";

contract EtherVaultTest is Test {
    EtherVault private vault;
    address private owner;
    address private user1;
    address private user2;

    function setUp() public {
        owner = address(this); // The test contract acts as the owner
        user1 = vm.addr(1); // Mock user1
        user2 = vm.addr(2); // Mock user2

        // Deploy the EtherVault contract with the owner
        vault = new EtherVault(owner);

        // Fund user1 and user2 with some Ether
        vm.deal(user1, 10 ether);
        vm.deal(user2, 5 ether);
    }

    function testInitialSetup() public view {
        // Ensure the contract is deployed with zero balance initially
        assertEq(address(vault).balance, 0);
    }

    function testDeposit() public {
        vm.startPrank(user1); // Start acting as user1

        // Deposit 1 ether
        vault.deposit{value: 1 ether}();

        // Check balances
        assertEq(vault.getBalance(), 1 ether);
        assertEq(address(vault).balance, 1 ether);

        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.startPrank(user1);

        // Deposit 2 ether
        vault.deposit{value: 2 ether}();
        assertEq(vault.getBalance(), 2 ether);

        // Withdraw 1 ether
        vault.withdraw(1 ether);
        assertEq(vault.getBalance(), 1 ether);
        assertEq(user1.balance, 9 ether); // User1 starts with 10 ether

        vm.stopPrank();
    }

    function testWithdrawExcess() public {
        vm.startPrank(user1);

        // Deposit 1 ether
        vault.deposit{value: 1 ether}();

        // Try withdrawing more than balance
        vm.expectRevert("Insufficient balance");
        vault.withdraw(2 ether);

        vm.stopPrank();
    }

    function testOwnerWithdrawAll() public {
        vm.startPrank(user1);

        // User1 deposits 3 ether
        vault.deposit{value: 5 ether}();

        vm.stopPrank();
        vm.startPrank(owner);

        // Owner withdraws all funds
        uint256 contractBalance = address(vault).balance;
        console.log("contract balance:", contractBalance);
        vault.withdrawAll();
        assertEq(owner.balance, contractBalance); // Owner should now have all funds
        assertEq(address(vault).balance, 0);

        vm.stopPrank();
    }

    function testWithdrawAllNonOwner() public {
        vm.startPrank(user1);

        // User1 deposits 1 ether
        vault.deposit{value: 1 ether}();

        vm.stopPrank();
        vm.startPrank(user2);

        // Non-owner tries to withdraw all funds
        vm.expectRevert("Access denied: Caller is not the contract owner");
        vault.withdrawAll();

        vm.stopPrank();
    }

    function testZeroDeposit() public {
        vm.startPrank(user1);

        // Try depositing 0 ether
        vm.expectRevert("Must deposit more than 0 ETH.");
        vault.deposit{value: 0 ether}();

        vm.stopPrank();
    }

    function testGetContractBalance() public {
        vm.startPrank(user1);

        // User1 deposits 2 ether
        vault.deposit{value: 2 ether}();

        vm.stopPrank();
        vm.startPrank(owner);

        // Check contract balance
        assertEq(vault.getContractBalance(), 2 ether);

        vm.stopPrank();
    }
}
