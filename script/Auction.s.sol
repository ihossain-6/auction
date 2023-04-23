//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Auction.sol";

contract DeployAuction is Script {
    function run() public {
        vm.startBroadcast();
        new Auction();
        vm.stopBroadcast();
    }
}