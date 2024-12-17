//SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

contract EtherVault {
    address private owner;
    mapping(address => uint256) private balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    constructor(address _owner) {
        require(_owner != address(0), "Owner can not be zero address");
        owner = _owner;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Access denied: Caller is not the contract owner"
        );
        _;
    }
    function deposit() external payable {
        require(msg.value > 0, "Must deposit more than 0 ETH");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    function withdrawAll() external onlyOwner {
        uint256 contractBalance = address(this).balance; //current contract bal

        require(contractBalance > 0, "No ETH in contract");

        // payable(owner).transfer(contractBalance); //receive contract address balance to the owner
        /**
         * *Transfer method have fixed gas fees
         * 
        -----Key Differences Between transfer, send, and call:----

        Method	  Gas    Limit	 Reverts on Failure	Return Value	Usage
        transfer  2300  	Yes	    None	Simple and safe transfers.
        send	  2300  	No  	bool (success/failure)	Use if you want to handle failures manually.
        call	  All gas  No	(bool, bytes)	Flexible and preferred for modern contracts.

         */

        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Transfer Failed");
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function getContractBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }
}
