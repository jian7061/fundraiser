//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Fundraising  {
    address public owner;
    uint256 public targetAmount;
    mapping(address => uint256) public donatorToAmount;

    uint256 public accumulatedAmount = 0;
    uint256 public deadline = block.timestamp + 2 weeks;

     constructor(uint256 _targetAmount) {
        owner = msg.sender;
        targetAmount = _targetAmount;
    }

    receive() external payable {
        require(block.timestamp < deadline, "This campaign is over");
        donatorToAmount[msg.sender] += msg.value;
        accumulatedAmount += msg.value;
    }

    //if time meet deadline or acculumatedAmount is equal to or more than targetAmount => money whould be sent to owner
    function withdrawDonation () external {
        require(msg.sender == owner, "Only owner can withdraw donation");
        require(accumulatedAmount >= targetAmount, "The project did not reach the goal yet");
        require(block.timestamp > deadline, "The project is not over yet");
        payable(owner).transfer(accumulatedAmount);
    }

    //if accumulatedAmount is less than targetAmount until deadline => money should be refunded to each one of donators
    function refund() external {
        require(donatorToAmount[msg.sender] > 0, "You have no money to get refund");
        require(block.timestamp > deadline, "The project is not over yet");
        require(accumulatedAmount < targetAmount, "Your money is donated successfully");
        //To prevent donator from requesting refund twice
        donatorToAmount[msg.sender] = 0;
        payable(msg.sender).transfer(donatorToAmount[msg.sender]);
    }
}
