//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Auction.sol";

contract DeployAuction is Script {
    function run() public {
        vm.startBroadcast();
        new Auction(address(this), 1683989291, 100000);
        vm.stopBroadcast();
    }
}
