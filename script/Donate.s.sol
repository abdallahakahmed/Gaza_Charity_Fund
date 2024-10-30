// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {Donate} from "../src/Donate.sol";

contract CounterScript is Script {
    Donate public donate;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        donate = new Donate();

        vm.stopBroadcast();
    }
}
