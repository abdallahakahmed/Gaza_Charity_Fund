// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {Donate} from "../src/Donate.sol";

contract DonateTest is Test {
    error DonateTest__TransferFailed();

    Donate public donate;
    address public donor = makeAddr("donor");
    address public receiver = makeAddr("receiver");
    address[] public owners;

    event DonateSuccess(address indexed donor, uint256 amount);
    event NewOwnerInserted(address indexed owner, address[] owners);
    event WithdrawalSuccess(address indexed to, uint256 amount, uint256 totalBalance);

    function setUp() external {
        donate = new Donate();
    }

    function _send() private {
        (bool success,) = address(donate).call{value: 100000000000000000}(""); // This line will call the Receive function
        if (!success) {
            revert DonateTest__TransferFailed();
        }
    }

    function _sendWithoutData() private {
        (bool success,) = address(donate).call{value: 100000000000000000}("Some Data"); // This line will call the Fallback function
        if (!success) {
            revert DonateTest__TransferFailed();
        }
    }

    function testDonateProcess() public {
        // Arrange
        hoax(donor, 2000000000000000000);
        // Act
        donate.donate{value: 100000000000000000}();
        // Assert
        assertEq(donate.getTotalBalance(), 100000000000000000);
    }

    function testEmitDonateEvent() public {
        // Whick data to check // Arrange
        vm.expectEmit(true, false, false, true);
        // Emit the expected event // Act / Assert
        emit DonateSuccess(donor, 100000000000000000);
        // Call the function that should emit the event
        hoax(donor, 2000000000000000000);
        donate.donate{value: 100000000000000000}();
    }

    function testDonateIfNotEnoughBalance() public {
        // Arrange
        vm.expectRevert(Donate.Donate__NoEnoughBalance.selector);
        // Act / Arrange
        hoax(donor, 2000000000000000000);
        donate.donate{value: 10000000000000000}();
    }

    function testDonateIfHaventAddress() public {
        // Arrange
        vm.expectRevert(Donate.Donate__Unauthorized.selector);
        // Act / Arrange
        hoax(address(0), 2000000000000000000);
        donate.donate{value: 100000000000000000}();
    }

    function testReceiveFunction() public {
        // Arrange
        hoax(donor, 2000000000000000000);
        // Act / Assert
        _send();
    }

    function testFallbackFunction() public {
        // Arrange
        hoax(donor, 2000000000000000000);
        // Act / Assert
        _sendWithoutData();
    }

    function testSetOwnerIsSuccess() public {
        // Arrange
        vm.prank(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        // Act
        donate.setOwner(donor);
        owners.push(donor);
        // Assert
        assertEq(donate.getOwners(), owners);
    }

    function testRevertIfSetOwnerFunctionAddressIsNotTheAllower() public {
        // Arrange
        vm.expectRevert(Donate.Donate__YouAreNotTheOwner.selector);
        // Act
        vm.prank(address(1));
        donate.setOwner(donor);
    }

    function testRevertIfTheNewOwnerHavntAddress() public {
        // Arrange
        vm.expectRevert(Donate.Donate__Unauthorized.selector);
        // Act / Assert
        vm.prank(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        donate.setOwner(address(0));
    }

    function testRevertIfTheOwnerIsExisted() public {
        // Act Before Arrange because I'm testing if the owner is exsit or not
        vm.prank(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        donate.setOwner(donor);
        // Arrange
        vm.expectRevert(Donate.Donate__OwnerAlreadyExist.selector);
        // Act / Assert
        vm.prank(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        donate.setOwner(donor);
    }

    function testEmitSetOwnerEvent() public {
        // Arrange
        vm.expectEmit(true, false, false, false);
        // Act
        emit NewOwnerInserted(donor, owners);
        // Assert
        vm.prank(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        donate.setOwner(donor);
    }

    function testRevertIfWithdrawalIsntPassAnyOwner() public {
        // Arrange
        vm.prank(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        donate.setOwner(donor);

        vm.expectRevert(Donate.Donate__YouAreNotTheOwner.selector);
        // Act / Assert
        vm.prank(address(1));
        donate.withdrawal(donor, 50000000000000000);
    }

    function testRevertIfTheWithdrawalReceiverHavntAddress() public {
        // Arrange
        vm.expectRevert(Donate.Donate__Unauthorized.selector);
        // Act / Assert
        vm.prank(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        donate.withdrawal(address(0), 50000000000000000);
    }

    function testRevertIfTheWithdrawalReceiverIsNotExistedInOwnersList() public {
        // Act Before Arrange because I'm testing if the owner is exsit or not
        // Why I need this blew link in this funciton is I'm checking if the owner Isn't exist.
        // Because I need data in owners list. If there are no data. Will get a differet Revert.
        vm.prank(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        donate.setOwner(donor);
        // Arrange
        vm.expectRevert(Donate.Donate__OwnerIsNotExist.selector);
        // Act / Assert
        vm.prank(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        donate.withdrawal(address(1), 50000000000000000);
    }

    function testWithdrawalProcess() public {
        // I should call donate function before all of this.
        // Arrange
        hoax(donor, 2000000000000000000);
        _send();

        // SetOwner function
        vm.prank(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        donate.setOwner(receiver);
        owners.push(receiver);
        // Withdrawal funciton
        // Arrange / Act
        vm.prank(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        donate.withdrawal(receiver, 50000000000000000);
        // Assert
        assertEq(donate.getTotalBalance(), 50000000000000000);
        assertEq(address(receiver).balance, 50000000000000000);
    }

    function testEmitWithdrawalEvent() public {
        hoax(donor, 2000000000000000000);
        _send();

        vm.prank(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        donate.setOwner(receiver);
        owners.push(receiver);
        // Arrange
        vm.expectEmit(true, false, false, false);
        // Act -
        emit WithdrawalSuccess(receiver, 50000000000000000, donate.getTotalBalance());
        // Assert
        vm.prank(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        donate.withdrawal(receiver, 50000000000000000);
    }
}
