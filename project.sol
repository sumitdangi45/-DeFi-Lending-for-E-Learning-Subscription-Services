
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DeFiLendingForELearning {
    struct Subscription {
        address borrower;
        uint256 amount;
        uint256 startTime;
        uint256 duration;
        uint256 interestRate;
        bool isActive;
    }

    address public owner;
    uint256 public totalSubscriptions;
    mapping(uint256 => Subscription) public subscriptions;
    mapping(address => uint256[]) public userSubscriptions;

    event SubscriptionCreated(
        uint256 subscriptionId,
        address indexed borrower,
        uint256 amount,
        uint256 duration,
        uint256 interestRate
    );
    event SubscriptionRepaid(uint256 subscriptionId, uint256 repaymentAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier validSubscription(uint256 subscriptionId) {
        require(subscriptionId < totalSubscriptions, "Invalid subscription ID");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createSubscription(
        uint256 amount,
        uint256 duration,
        uint256 interestRate
    ) external payable {
        require(msg.value == amount, "Incorrect deposit amount");
        require(amount > 0, "Amount must be greater than zero");
        require(duration > 0, "Duration must be greater than zero");

        Subscription memory newSubscription = Subscription({
            borrower: msg.sender,
            amount: amount,
            startTime: block.timestamp,
            duration: duration,
            interestRate: interestRate,
            isActive: true
        });

        subscriptions[totalSubscriptions] = newSubscription;
        userSubscriptions[msg.sender].push(totalSubscriptions);
        emit SubscriptionCreated(totalSubscriptions, msg.sender, amount, duration, interestRate);
        totalSubscriptions++;
    }

    function repaySubscription(uint256 subscriptionId) external payable validSubscription(subscriptionId) {
        Subscription storage subscription = subscriptions[subscriptionId];
        require(subscription.isActive, "Subscription is not active");
        require(msg.sender == subscription.borrower, "Only borrower can repay");

        uint256 repaymentAmount = calculateRepaymentAmount(subscription.amount, subscription.interestRate);
        require(msg.value == repaymentAmount, "Incorrect repayment amount");

        subscription.isActive = false;
        payable(owner).transfer(repaymentAmount);
        emit SubscriptionRepaid(subscriptionId, repaymentAmount);
    }

    function calculateRepaymentAmount(uint256 principal, uint256 interestRate) public pure returns (uint256) {
        return principal + (principal * interestRate / 100);
    }

    function getUserSubscriptions(address user) external view returns (uint256[] memory) {
        return userSubscriptions[user];
    }
}

