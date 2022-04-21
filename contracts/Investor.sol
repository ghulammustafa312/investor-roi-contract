//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract invest {
    struct User {
        uint256 amount;
        uint256 profit;
        uint256 profitWitdrawn;
        uint256 startTime;
        address referredBy;
        uint256 expTime;
        bool timeStarted;
        bool referral;
    }
    address public owner;
    mapping(address => User) public investor;

    constructor() {
        owner = msg.sender;
    }

    function investMoney(address referralAddress) public payable {
        require(msg.value > 0, "Please Invest more then 0 ether ");
        uint256 priceCut = (msg.value * 10) / 100;
        payable(owner).transfer(priceCut);
        uint256 afterTax = msg.value - priceCut;
        if (!investor[msg.sender].timeStarted) {
            investor[msg.sender].startTime = block.timestamp;
            investor[msg.sender].expTime = block.timestamp + 30 days;
            investor[msg.sender].timeStarted = true;
            if (referralAddress != address(0)) {
                investor[msg.sender].referredBy = referralAddress;
                investor[msg.sender].referral = true;
                uint256 level1Profit = (afterTax * 5) / (100);
                payable(referralAddress).transfer(level1Profit);
                if (investor[referralAddress].referral) {
                    address level2Referral = investor[referralAddress]
                        .referredBy;
                    uint256 level2Profit = (afterTax * 3) / (100);
                    payable(level2Referral).transfer(level2Profit);
                    if (investor[level2Referral].referral) {
                        uint256 level3Profit = (afterTax * 2) / (100);
                        payable(investor[level2Referral].referredBy).transfer(
                            level3Profit
                        );
                    }
                }
            } else {
                investor[msg.sender].referredBy = address(0);
                investor[msg.sender].referral = false;
            }
        } else {
            if (investor[msg.sender].referral) {
                address level1Referral = investor[msg.sender].referredBy;
                uint256 level1Profit = (afterTax * 5) / (100);
                payable(level1Referral).transfer(level1Profit);
                if (investor[level1Referral].referral) {
                    address level2Referral = investor[level1Referral]
                        .referredBy;
                    uint256 level2Profit = (afterTax * 3) / (100);
                    payable(level2Referral).transfer(level2Profit);
                    if (investor[level2Referral].referral) {
                        uint256 level3Profit = (afterTax * 2) / (100);
                        payable(investor[level2Referral].referredBy).transfer(
                            level3Profit
                        );
                    }
                }
            }
        }
        investor[msg.sender].amount += afterTax;
        investor[msg.sender].profit += ((afterTax * 7 * 30) / (100));
    }

    function currentProfit() public view returns (uint256) {
        uint256 current_profit;
        if (block.timestamp <= investor[msg.sender].expTime) {
            if (
                (((investor[msg.sender].profit +
                    investor[msg.sender].profitWitdrawn) *
                    ((block.timestamp - investor[msg.sender].startTime) /
                        (1 days))) / (30)) > investor[msg.sender].profitWitdrawn
            ) {
                current_profit =
                    (((investor[msg.sender].profit +
                        investor[msg.sender].profitWitdrawn) *
                        ((block.timestamp - investor[msg.sender].startTime) /
                            (1 days))) / (30)) -
                    investor[msg.sender].profitWitdrawn;
                return current_profit;
            } else {
                return 0;
            }
        }
        if (block.timestamp > investor[msg.sender].expTime) {
            return investor[msg.sender].profit;
        }
    }

    function withdraw() public payable returns (bool) {
        uint256 current_profit = currentProfit();
        investor[msg.sender].profitWitdrawn += current_profit;
        investor[msg.sender].profit -= current_profit;
        payable(msg.sender).transfer(current_profit);
        return true;
    }
}
