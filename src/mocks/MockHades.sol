//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";

contract MockHades is ERC20 {
    constructor() ERC20("Hades Token", "HADES") {}

    function mint() external {
        _mint(msg.sender, 1_000 ether);
    }
}
