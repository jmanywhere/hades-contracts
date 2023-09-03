// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

contract HadesToken is ERC20, Ownable {
    mapping(address => bool) public isLP;
    mapping(address => bool) public isExcludedFromFee;

    uint private constant MAX_SUPPLY = 1_000_000_000 ether;
    uint public threshold = MAX_SUPPLY / 1000; // 0.1% of total supply
    uint public buyBBV = 50;
    uint public buyLiq = 25;
    uint public buyMkt = 25;
    uint public sellBBV = 50;
    uint public sellLiq = 25;
    uint public sellMkt = 25;
    uint public txBBV = 50;
    uint public txLiq = 25;
    uint public txMkt = 25;

    uint private totalMarketingFunds;
    uint private totalLiquidityFunds;

    uint private buyFee = 100;
    uint private sellFee = 100;
    uint private txFee = 100;
    uint private constant PERCENTAGE = 1000;

    address public vault;
    address public marketing;

    uint8 private swapping = 1;

    //-----------------------------------------------------------
    // EVENTS
    //-----------------------------------------------------------
    event SetFeeExclusionStatus(address indexed _address, bool _status);
    event SetLPStatus(address indexed _address, bool _status);
    event SetVault(address indexed _vault, address indexed prevVault);

    //-----------------------------------------------------------
    // CONSTRUCTOR
    //-----------------------------------------------------------
    constructor() ERC20("Hades Token", "HADES") {
        _mint(msg.sender, MAX_SUPPLY);
    }

    //-----------------------------------------------------------
    // EXTERNAL FUNCTIONS
    //-----------------------------------------------------------
    function setExclusionStatus(
        address _address,
        bool _status
    ) external onlyOwner {
        isExcludedFromFee[_address] = _status;
        emit SetFeeExclusionStatus(_address, _status);
    }

    function setLPStatus(address _address, bool _status) external onlyOwner {
        isLP[_address] = _status;
        emit SetLPStatus(_address, _status);
    }

    function setVault(address _vault) external onlyOwner {
        emit SetVault(_vault, vault);
        vault = _vault;
    }

    //-----------------------------------------------------------
    // INTERNAL FUNCTIONS
    //-----------------------------------------------------------
    function _transfer(
        address from,
        address to,
        uint amount
    ) internal override {
        bool isEitherExcluded = isExcludedFromFee[from] ||
            isExcludedFromFee[to];
        bool canSwap = balanceOf(address(this)) >= threshold;

        if (!isEitherExcluded && canSwap && swapping == 1 && !isLP[from]) {
            swapping = 2;
            _swapFees();
            swapping = 1;
        }

        if (isEitherExcluded) {
            super._transfer(from, to, amount);
        } else {
            bool transferWithLP = isLP[from];
            uint fee;
            uint bbv;
            uint liq;
            uint mkt;
            if (transferWithLP) {
                //BUY
                fee = (buyFee * amount) / PERCENTAGE;
                amount -= fee;
                bbv = (buyBBV * fee) / buyFee;
                liq = (buyLiq * fee) / buyFee;
                mkt = fee - bbv - liq; //This adjusts for rounding errors
                distributeFee(from, bbv, liq, mkt);
                super._transfer(from, to, amount);
            } else {
                transferWithLP = isLP[to];
                if (transferWithLP) {
                    // SELL
                    fee = (sellFee * amount) / PERCENTAGE;
                    amount -= fee;
                    bbv = (sellBBV * fee) / sellFee;
                    liq = (sellLiq * fee) / sellFee;
                    mkt = fee - bbv - liq; //This adjusts for rounding errors
                    distributeFee(from, bbv, liq, mkt);
                    super._transfer(from, to, amount);
                } else {
                    // TRANSFER
                    fee = (txFee * amount) / PERCENTAGE;
                    amount -= fee;
                    bbv = (txBBV * fee) / txFee;
                    liq = (txLiq * fee) / txFee;
                    mkt = fee - bbv - liq; //This adjusts for rounding errors
                    distributeFee(from, bbv, liq, mkt);
                    super._transfer(from, to, amount);
                }
            }
        }
    }

    //-----------------------------------------------------------
    // PRIVATE FUNCTIONS
    //-----------------------------------------------------------
    function distributeFee(
        address from,
        uint _vault,
        uint liq,
        uint mkt
    ) private {
        super._transfer(from, vault, _vault);
        super._transfer(from, address(this), liq + mkt);
        totalLiquidityFunds += liq;
        totalMarketingFunds += mkt;
    }

    function _swapFees() private {}
}
