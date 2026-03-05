// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./bigbank.sol";  

contract Admin {
    address public owner;
    
    event WithdrawTriggered(address indexed caller, address indexed bigBank);
    
    constructor() {
        owner = msg.sender;  // 部署者成为 owner
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    // 调用 BigBank 的提款函数
    function withdrawFromBigBank(address bigBankAddress) external  onlyOwner {
        bigbank(bigBankAddress).withdraw();
        emit WithdrawTriggered(msg.sender, bigBankAddress);
    }
    

}