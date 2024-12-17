// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EtherVault} from "../src/EtherVault.sol";

contract DeployEtherVault is Script {
    function run() public payable {
        vm.startBroadcast();

        EtherVault etherVault = new EtherVault(msg.sender);

        vm.stopBroadcast();

        console.log("Contract deployed at : ", address(etherVault));
    }
}
