// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPFarmingContract is Ownable {
    IERC20 public dvdEthLPToken;
    IERC20 public hardToken;

    uint256 public startTimestamp;
    uint256 public rewardRate; // 69420% per day
    uint256 public rateDecreaseFactor; // 0.1010011010011110100011001010100%

    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public stakedTimestamps;

    constructor(address _dvdEthLPToken, address _hardToken) {
        dvdEthLPToken = IERC20(_dvdEthLPToken);
        hardToken = IERC20(_hardToken);
        startTimestamp = block.timestamp;
        rewardRate = 69420;
        rateDecreaseFactor = 1010011010011110100011001010100;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        dvdEthLPToken.transferFrom(msg.sender, address(this), amount);
        stakedBalances[msg.sender] += amount;
        stakedTimestamps[msg.sender] = block.timestamp;
    }

    function unstake() external {
        uint256 stakedAmount = stakedBalances[msg.sender];
        require(stakedAmount > 0, "No staked amount");
        
        uint256 earnedTokens = calculateEarnedTokens(msg.sender);
        
        stakedBalances[msg.sender] = 0;
        stakedTimestamps[msg.sender] = 0;
        
        dvdEthLPToken.transfer(msg.sender, stakedAmount);
        hardToken.transfer(msg.sender, earnedTokens);
    }

    function calculateEarnedTokens(address user) internal view returns (uint256) {
        uint256 stakedAmount = stakedBalances[user];
        uint256 stakingDuration = block.timestamp - stakedTimestamps[user];
        uint256 dailyRate = rewardRate * stakedAmount / 10000;
        uint256 adjustedRate = dailyRate * (10000 - stakingDuration * rateDecreaseFactor / 10000000000) / 10000;
        return adjustedRate * stakingDuration / 1 days;
    }
}
