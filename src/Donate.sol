// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @author  . Abdallah Ahmed
 * @title   . Gaza Charity Fund
 * @notice  . This Contract will allow donors to donate to gaza people through this dapp. The donate just in Ethereum cryptocurrency.
 */

contract Donate {
    error Donate__AmountIsLessThanMinimum();
    error Donate__Unauthorized();
    error Donate__NotAnAddress();
    error Donate__NoEnoughBalance();
    error Donate__DonateFailed();
    error Donate__TotalRequiredAmountIsLessThenTarget();
    error Donate__OwnerAlreadyExist();
    error Donate__YouAreNotTheOwner();
    error Donate__OwnerIsNotExist();

    uint256 private constant MINIMUM_DONATE = 20000000000000000;
    uint256 private constant TOTAL_REQUIRED_AMOUNT = 5000000000000000000;
    address private immutable i_owner =
        0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
    uint256 private totalBalance;

    address[] private s_donors;
    address[] private s_owners;
    mapping(address => uint) private _balances;
    mapping(address => uint) private _owners;

    /* Events */
    event DonateSuccess(address indexed donor, uint256 amount);
    event WithdrawalSuccess(
        address indexed to,
        uint256 amount,
        uint256 totalBalance
    );
    event NewOwnerInserted(address indexed owner, address[] owners);

    modifier OnlyOwner() {
        if (msg.sender != i_owner) {
            revert Donate__YouAreNotTheOwner();
        }
        _;
    }

    receive() external payable {
        donate();
    }

    fallback() external payable {
        donate();
    }

    /**
     * @notice  . This function allow the donors to dondate & to the GCF. Depands on some conditions
     */
    function donate() public payable {
        // Check
        if (msg.sender == address(0)) {
            revert Donate__Unauthorized();
        }
        if (msg.value <= MINIMUM_DONATE) {
            revert Donate__NoEnoughBalance();
        }
        // Effects
        _balances[msg.sender] += msg.value;
        s_donors.push(msg.sender);
        totalBalance += msg.value;
        // Interactions
        emit DonateSuccess(msg.sender, msg.value);
    }

    function withdrawal(address owner, uint256 amount) public OnlyOwner {
        // check
        if (owner == address(0)) {
            revert Donate__Unauthorized();
        }
        // Check if the new owner already exists in the s_owners array
        for (uint256 i = 0; i < s_owners.length; i++) {
            if (owner != s_owners[i]) {
                revert Donate__OwnerIsNotExist();
            }
        }
        // Effects
        totalBalance -= amount;
        payable(owner).transfer(amount);
        // Interactions
        emit WithdrawalSuccess(owner, amount, totalBalance);
    }

    function getTotalBalance() public view returns (uint256) {
        return totalBalance;
    }

    function getOwners() public view returns (address[] memory) {
        return s_owners;
    }

    function setOwner(address newOwner) public {
        // Checks
        // Just one address has an access on this function.
        if (msg.sender != i_owner) {
            revert Donate__YouAreNotTheOwner();
        }
        // Check if the new owner address is valid
        if (newOwner == address(0)) {
            revert Donate__Unauthorized();
        }

        // Check if the new owner already exists in the s_owners array
        for (uint256 i = 0; i < s_owners.length; i++) {
            if (newOwner == s_owners[i]) {
                revert Donate__OwnerAlreadyExist();
            }
        }

        // Effects
        s_owners.push(newOwner);
        _owners[newOwner] = 0;

        // Interactions
        emit NewOwnerInserted(newOwner, s_owners);
    }
}
