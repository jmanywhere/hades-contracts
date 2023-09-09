// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {MockHades} from "../src/mocks/MockHades.sol";
import {HadesFountain} from "../src/HadesFountain.sol";

contract FountainTest is Test {
    MockHades public hades;
    MockHades public cpt;

    HadesFountain public fountain;

    address vault = makeAddr("vault");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    function setUp() public {
        hades = new MockHades();
        cpt = new MockHades();
        fountain = new HadesFountain(
            address(hades),
            address(cpt),
            address(hades),
            vault,
            block.timestamp
        );

        vm.startPrank(vault);
        hades.mint();
        hades.approve(address(fountain), type(uint256).max);
        vm.stopPrank();
        vm.prank(user1);
        hades.mint();
    }

    function test_deposit() public {
        uint vaultBalance = hades.balanceOf(vault);
        vm.prank(user1);
        hades.approve(address(fountain), 1000 ether);
        vm.prank(user1);
        fountain.deposit(1000 ether, address(this));

        assertEq(hades.balanceOf(vault), vaultBalance + 1000 ether);
        (, , uint nfv, , , , ) = fountain.getNerdData(user1);

        assertEq(nfv, 900 ether);
    }

    function test_claim() public {
        vm.prank(user1);
        hades.approve(address(fountain), 1000 ether);
        vm.prank(user1);
        fountain.deposit(1000 ether, address(this));

        skip(1 days);

        vm.prank(user1);
        fountain.claim();

        assertEq(
            hades.balanceOf(user1),
            ((9 ether + (((4.5 ether) * 47) / 48)) * 9) / 10
        );
    }
}
