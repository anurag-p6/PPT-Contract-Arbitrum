// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import "forge-std/Script.sol";
import "../src/PPTToken.sol";

contract DeployPPTToken is Script {
    uint256 internal constant INITIAL_SUPPLY = 200_000;

    function run() external {
        vm.startBroadcast();

        PPTToken token = new PPTToken(INITIAL_SUPPLY);

        vm.stopBroadcast();

        console.log("PPTToken deployed at:", address(token));
        console.log("Initial supply (whole tokens):", INITIAL_SUPPLY);
        console.log("Owner:", token.owner());
    }
}
