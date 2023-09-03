//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";

import {MockHades} from "../src/mocks/MockHades.sol";
import {HadesFountain} from "../src/HadesFountain.sol";

contract DeployTestnetFountain is Script {
    function run() public {
        uint256 deployerPrivate = vm.envUint("PRIVATE_KEY");
        address vault = 0x7Ff20b4E1Ad27C5266a929FC87b00F5cCB456374;
        vm.startBroadcast(deployerPrivate);
        MockHades hades = new MockHades();
        MockHades cpt = new MockHades();
        hades.mint();
        cpt.mint();
        HadesFountain fountain = new HadesFountain(
            address(hades),
            address(cpt),
            address(hades),
            vault,
            block.timestamp
        );
        vm.stopBroadcast();
    }
}
