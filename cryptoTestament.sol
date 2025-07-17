// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CryptoTestament {
    address public owner;
    address public beneficiary;
    uint256 public lastCheckIn;
    uint256 public inactivityPeriod;

    constructor(address _beneficiary, uint256 _inactivityPeriod) payable {
        owner = msg.sender;
        beneficiary = _beneficiary;
        inactivityPeriod = _inactivityPeriod; // e.g., 20 for demo
        lastCheckIn = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Not beneficiary");
        _;
    }

    function checkIn() public onlyOwner {
        lastCheckIn = block.timestamp;
    }

    function claim() public onlyBeneficiary {
        require(block.timestamp >= lastCheckIn + inactivityPeriod, "Owner is still active");
        payable(beneficiary).transfer(address(this).balance);
    }

    function emergencyWithdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}
// constructor sets beneficiary, inactivity period and initializes check-in time
// modifier restricts functions to owner or beneficiary
// claim() allows fund transfer after inactivity
