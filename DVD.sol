// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DVDToken is ERC20 {
    address public reflectionPool;
    uint256 public reflectionFeeRate;  // The fee rate in basis points (1 basis point = 0.01%)
    
    mapping(address => uint256) private _reflectedBalances;
    uint256 private _totalReflectedTokens;

    constructor(address initialHolder) ERC20("Dick Vs Dick", "DVD") {
        reflectionPool = msg.sender;
        reflectionFeeRate = 100; // 1% reflection fee
        
        uint256 initialSupply = 10001000101011001000100 * 10 ** decimals();
        
        _mint(initialHolder, initialSupply);
        _reflectedBalances[initialHolder] = initialSupply;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (reflectionFeeRate > 0 && sender != reflectionPool) {
            uint256 reflectionFee = amount * reflectionFeeRate / 10000;
            uint256 reflectedAmount = amount - reflectionFee;
            
            super._transfer(sender, reflectionPool, reflectionFee);
            super._transfer(sender, recipient, reflectedAmount);
            
            _reflectedBalances[sender] -= reflectionFee;
            _reflectedBalances[recipient] += reflectedAmount;
        } else {
            super._transfer(sender, recipient, amount);
        }
    }

    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account) + _reflectedBalances[account];
    }
}
