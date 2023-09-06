// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";

contract Scepter is ERC20 {
    uint constant MAX_SUPPLY = 100_000 ether;

    constructor() ERC20("Scepter", "CPT") {
        _mint(msg.sender, MAX_SUPPLY);
    }

    /*
    Reflective Token
      Taxes: 10% total (buy/sells/transfers)
        5% to reflections
        5% to liquidity
    In order to get reflections, user must have a working deposit on the Fountain.
  */
}
