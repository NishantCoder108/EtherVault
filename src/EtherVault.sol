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

        payable(owner).transfer(contractBalance); //receive contract address balance to the owner
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function getContractBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }
}