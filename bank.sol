// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Bank
 * @dev A simple bank contract that records deposits and maintains a leaderboard
 */
contract bank {
    // ============ State Variables ============
    
    address public admin;                          // 管理员
    mapping(address => uint256) public balances;   // 每一个地址所对应的存款金额
    
    address[3] public topAddresses;                // 前三的地址数组
    uint256[3] public topAmounts;                  // 其所对应的金额
    
    // ============ Events ============
    
    event Deposited(address indexed depositor, uint256 amount, uint256 newBalance);
    event Withdrawn(address indexed admin, uint256 totalAmount);
    event LeaderboardUpdated(address[3] addresses, uint256[3] amounts);
    
    // ============ Modifiers ============
    
    // modifier onlyAdmin() {
    //     require(msg.sender == admin, "Error: Only admin can perform this operation");
    //     _;
    // }
    
    // ============ Constructor ============
    
    constructor() {
        admin = msg.sender;  // The deployer becomes admin
    }
    
    // ============ Deposit Function ============
    
    /**
     * @dev 用户存款
     */
    function deposit() public payable virtual {
       // require(msg.value > 0, "Error: Deposit amount must be greater than 0");
        
        // 更新地址所对应的存款金额
        balances[msg.sender] += msg.value;
        
        // 更新排行榜
        _updateLeaderboard(msg.sender, balances[msg.sender]);
        // 触发存款事件，记录日志
        emit Deposited(msg.sender, msg.value, balances[msg.sender]);
    }
    
    // ============ Withdraw Function (Admin Only) ============
    
    /**
     * @dev 只有管理员才可以取款
     */
    function withdraw() external  {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "Error: Contract balance is 0");
        
        // Transfer to admin
        (bool success, ) = admin.call{value: contractBalance}("");
        require(success, "Error: Withdrawal failed");
        
        emit Withdrawn(admin, contractBalance);
    }
    
    // ============ Internal Functions: Leaderboard Maintenance ============
    
    /**
     * @dev Update the deposit leaderboard
     * @param user The address making the deposit
     * @param newAmount User's new total deposit amount
     */
    function _updateLeaderboard(address user, uint256 newAmount) private {
        // 检查是否在榜
        int256 currentRank = _getRank(user);
        
        if (currentRank >= 0) {
            // Already on leaderboard, update amount
            topAmounts[uint256(currentRank)] = newAmount;
            // Re-sort (amount may have changed, affecting rank)
            _sortLeaderboard();
            return;
        }
        
        // 不在榜，看是否进前三
        for (uint256 i = 0; i < 3; i++) {
            // If this position is empty (address is 0)
            if (topAddresses[i] == address(0)) {
                topAddresses[i] = user;
                topAmounts[i] = newAmount;
                emit LeaderboardUpdated(topAddresses, topAmounts);
                return;
            }
            
            // If new amount is greater than current amount at position i
            if (newAmount > topAmounts[i]) {
                // Shift elements from the back to make room
                for (uint256 j = 2; j > i; j--) {
                    topAddresses[j] = topAddresses[j-1];
                    topAmounts[j] = topAmounts[j-1];
                }
                // Insert new user
                topAddresses[i] = user;
                topAmounts[i] = newAmount;
                emit LeaderboardUpdated(topAddresses, topAmounts);
                return;
            }
        }
    }
    
    /**
     * @dev 获取排名索引
     * @return Rank, -1 if not on leaderboard
     */
    function _getRank(address user) private view returns (int256) {
        for (uint256 i = 0; i < 3; i++) {
            if (topAddresses[i] == user) {
                return int256(i);
            }
        }
        return -1;
    }
    
    /**
     * @dev 冒泡重新排序
     */
    function _sortLeaderboard() private {
        for (uint256 i = 0; i < 2; i++) {
            for (uint256 j = i + 1; j < 3; j++) {
                if (topAmounts[j] > topAmounts[i]) {
                    // Swap amounts
                    (topAmounts[i], topAmounts[j]) = (topAmounts[j], topAmounts[i]);
                    // Swap addresses
                    (topAddresses[i], topAddresses[j]) = (topAddresses[j], topAddresses[i]);
                }
            }
        }
        emit LeaderboardUpdated(topAddresses, topAmounts);
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get the top 3 depositors
     */
    function getTopThree() external view returns (address[3] memory, uint256[3] memory) {
        return (topAddresses, topAmounts);
    }
    
    /**
     * @dev Query a user's balance
     */
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
    
    /**
     * @dev Get contract's total balance
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}