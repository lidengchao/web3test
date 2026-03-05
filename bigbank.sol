// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./bank.sol";  
/**
 * @title BigBank
 * @dev 继承自 Bank，添加最低存款限制，管理员改为 Admin 合约
 */
contract bigbank is bank {

     modifier minimumAmount(){
         require(msg.value > 0.001 ether, "Error: Deposit amount must be > 0.001 ETH");
         _;
    }
    
    // ============ Constructor ============
    
    /**
     * @param _admin Admin 合约的地址
     */
    constructor(address _admin) {
        // 将管理员设置为 Admin 合约地址
        admin = _admin;
    }
    
    // ============ Override Functions ============
    
    /**
     * @dev 重写 deposit 函数，添加 minimumAmount 修饰器
     */
    function deposit() public payable override  minimumAmount {
       super.deposit();  // 调用父合约的存款逻辑
    }
   
}