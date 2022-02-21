// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract Government {
    // Global Variables
    uint32 public lastCreditorPayedOut;
    uint256 public lastTimeOfNewCredit;
    uint256 public profitFromCrash;
    address payable[] public creditorAddresses;
    uint256[] public creditorAmounts;
    address payable public corruptElite;
    mapping(address => uint256) buddies;
    uint256 constant TWELVE_HOURS = 43200;
    uint8 public round;

    constructor() payable {
        //setup of elites promise by amount
        profitFromCrash = msg.value;
        //sets the initiator as a corruptElite
        corruptElite = payable(msg.sender);
        //sets lastTimeOfNewCredit
        lastTimeOfNewCredit = block.timestamp;
    }

    function lendGovernmentMoney(address payable buddy)
        public
        payable
        returns (bool)
    {
        uint256 amount = msg.value;
        /* 
        check if the system already broke down. If for 12h no 
        new creditor gives new credit to the system it will brake down
        */
        if (lastTimeOfNewCredit + TWELVE_HOURS < block.timestamp) {
            // Return money to sender
            payable(msg.sender).transfer(amount);
            creditorAddresses[creditorAddresses.length - 1].transfer(
                profitFromCrash
            );
            corruptElite.transfer(address(this).balance);

            //Reset contract state
            lastCreditorPayedOut = 0;
            lastTimeOfNewCredit = block.timestamp;
            profitFromCrash = 0;
            creditorAddresses = new address payable[](0);
            creditorAmounts = new uint256[](0);
            round += 1;
            return false;
        } else {
            /* 
             the system needs to collect at least 1% of the profit // from a crash to stay alive 
            */
            if (amount >= 10**18) {
                // the System has received fresh money, it will survive at least 12h more
                lastTimeOfNewCredit = block.timestamp;
                // register the new creditor and his amount with 10% interest rate
                creditorAddresses.push(payable(msg.sender));
                creditorAmounts.push((amount * 11) / 10);
                // now the money is distributed first the corrupt elite grabs 5% - thieves!
                corruptElite.transfer((amount * 5) / 100);
                // 5% are going into the economy (they will increase the value for the person seeing the crash coming)
                //check weather profitfromCrash < 10000 ether
                if (profitFromCrash < 10000 * 10**18) {
                    profitFromCrash += (amount * 5) / 100;
                }
                // if you have a buddy in the government (and he is in the creditor list) he can get 5% of your credits.
                // Make a deal with him.
                if (buddies[buddy] >= amount) {
                    buddy.transfer((amount * 5) / 100);
                }
                buddies[msg.sender] += (amount * 110) / 100;
                // 90% of the money will be used to pay out old creditors
                if (
                    creditorAmounts[lastCreditorPayedOut] <=
                    address(this).balance - profitFromCrash
                ) {
                    creditorAddresses[lastCreditorPayedOut].transfer(
                        creditorAmounts[lastCreditorPayedOut]
                    );
                    buddies[
                        creditorAddresses[lastCreditorPayedOut]
                    ] -= creditorAmounts[lastCreditorPayedOut];
                    lastCreditorPayedOut += 1;
                }
                return true;
            } else {
                payable(msg.sender).transfer(amount);
                return false;
            }
        }
    }

    receive() external payable {
        lendGovernmentMoney(payable(address(0)));
    }

    function totalDebt() public view returns (uint256 debt) {
        for (
            uint256 i = lastCreditorPayedOut;
            i < creditorAmounts.length;
            i++
        ) {
            debt += creditorAmounts[i];
        }
    }

    function totalPayedOut() public view returns (uint256 payout) {
        for (uint256 i = 0; i < lastCreditorPayedOut; i++) {
            payout += creditorAmounts[i];
        }
    }

    function investInTheSystem() public payable {
        profitFromCrash += msg.value;
    }

    //corruptElite transfers to next address
    function inheritToNextGeneration(address payable nextGeneration) public {
        if (msg.sender == corruptElite) {
            corruptElite = nextGeneration;
        }
    }

    function getCreditorAddresses()
        public
        pure
        returns (address[] memory creditorAddresses)
    {
        return creditorAddresses;
    }

    function getCreditorAmounts()
        public
        pure
        returns (uint256[] memory creditorAmounts)
    {
        return creditorAmounts;
    }
}
