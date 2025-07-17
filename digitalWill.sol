// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Digital Will Contract
/// @notice This contract enables fund transfer to a beneficiary after owner's inactivity

contract DigitalWill {
    address public owner;
    address public beneficiary;
    uint public timeout;        // Inactivity timeout in seconds
    uint public lastActive;     // Last time owner interacted

    /// @notice Event to log a beneficiary claim attempt
    event ClaimAttempt(address indexed claimant, uint time, uint balance);
    event Deposited(address indexed sender, uint amount);
    
    /// @dev Contract is deployed by the owner; initializes last activity time
    constructor() {
        owner = msg.sender;
        lastActive = block.timestamp;
    }

    /// @dev Restricts certain functions to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }

    /// @dev Restricts certain functions to only the beneficiary
    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Only beneficiary allowed");
        _;
    }

    /// @notice Set beneficiary address (must be done before a claim can be made)
    /// @param _beneficiary The address designated to receive funds
    function setBeneficiary(address _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
        lastActive = block.timestamp;
    }

    /// @notice Set inactivity timeout before funds can be claimed
    /// @param _timeout Duration in seconds before the claim is allowed
    function setTimeout(uint _timeout) public onlyOwner {
        timeout = _timeout;
        lastActive = block.timestamp;
    }

    /// @notice Owner deposits ETH into the contract
    function deposit() public payable onlyOwner {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        lastActive = block.timestamp;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Owner keeps the contract active (refreshes inactivity timer)
    function keepAlive() public onlyOwner {
        lastActive = block.timestamp;
    }

    /// @notice Beneficiary claims the funds if the timeout has passed
    function claim() public onlyBeneficiary {
        emit ClaimAttempt(msg.sender, block.timestamp, address(this).balance);
        require(block.timestamp >= lastActive + timeout, "Timeout not reached");
        require(address(this).balance > 0, "No funds available");
        
        payable(beneficiary).transfer(address(this).balance);
    }

    /// @notice Get the contract's balance
    /// @return The balance stored in the contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}