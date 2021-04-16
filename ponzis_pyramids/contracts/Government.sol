pragma solidity ^0.6.1;

contract Government{
    // Global Variables
    uint32 public lastCreditorPayedOut;
    uint  public lastTimeOfNewCredit;
    uint public profitFromCrash;
    address payable [] public creditorAddresses;
    uint[] public creditorAmounts;
    address payable public corruptElite;
    mapping ( address => uint) buddies;
    uint constant TWELVE_HOURS = 43200;
    uint8 public round;

    constructor() public payable {
        //setup of elites promise by amount
        profitFromCrash = msg.value;
        //sets the initiator as a corruptElite
        corruptElite = msg.sender;
        //sets lastTimeOfNewCredit
        lastTimeOfNewCredit = block.timestamp;
    }

    function lendGovernmentMoney(address payable buddy) public  payable returns(bool)  {
        uint amount = msg.value;
        /* 
        check if the system already broke down. If for 12h no 
        new creditor gives new credit to the system it will brake down
        */
        if(lastTimeOfNewCredit + TWELVE_HOURS < block.timestamp){
            // Return money to sender
            msg.sender.send(amount);
            creditorAddresses[creditorAddresses.length - 1].send(profitFromCrash);
            corruptElite.send(address(this).balance);

            //Reset contract state
            lastCreditorPayedOut =0;
            lastTimeOfNewCredit = block.timestamp;
            profitFromCrash =0;
            creditorAddresses = new address payable[](0);
            creditorAmounts = new uint[](0);
            round +=1;
            return false;
        }else{
            /* 
             the system needs to collect at least 1% of the profit // from a crash to stay alive 
            */
            if(amount >= 10**18){
                // the System has received fresh money, it will survive at least 12h more
                lastTimeOfNewCredit = block.timestamp;
                // register the new creditor and his amount with 10% interest rate
                creditorAddresses.push(msg.sender);
                creditorAmounts.push(amount * 11/10);
                // now the money is distributed first the corrupt elite grabs 5% - thieves!
                corruptElite.send(amount * 5/100);
                // 5% are going into the economy (they will increase the value for the person seeing the crash coming)
                //check weather profitfromCrash < 10000 ether 
                if (profitFromCrash < 10000 * 10**18) {
                    profitFromCrash += amount * 5/100;
                }
                // if you have a buddy in the government (and he is in the creditor list) he can get 5% of your credits.
                // Make a deal with him.
                if(buddies[buddy] >= amount) {
                    
                    buddy.send(amount * 5/100);
                }
                buddies[msg.sender] += amount * 110 / 100;
                // 90% of the money will be used to pay out old creditors
                if (creditorAmounts[lastCreditorPayedOut] <=address(this).balance - profitFromCrash){
                    creditorAddresses[lastCreditorPayedOut].send( creditorAmounts[lastCreditorPayedOut]);
                    buddies[creditorAddresses[lastCreditorPayedOut]] -= creditorAmounts[lastCreditorPayedOut];
                    lastCreditorPayedOut += 1;
                }
                return true;
            }else {
                msg.sender.send(amount);
                return false;
            }
        }

    }

    receive() external payable {
        lendGovernmentMoney(address(0));
    }
    
    function totalDebt() public view returns( uint debt){
        for (uint256 i = lastCreditorPayedOut; i < creditorAmounts.length; i++) {
            debt += creditorAmounts[i];
        }
    }

    function totalPayedOut() public view returns (uint payout) {
        for(uint i=0; i<lastCreditorPayedOut; i++){
            payout += creditorAmounts[i];
        }
    }

    function investInTheSystem() public payable{
        profitFromCrash += msg.value;
    }


    //corruptElite transfers to next address 
    function inheritToNextGeneration(address payable nextGeneration) public{
        if (msg.sender == corruptElite) {
            corruptElite = nextGeneration;
        } 
    }

    function getCreditorAddresses() public pure returns ( address[] memory creditorAddresses ) {
        return creditorAddresses;
    }

    function getCreditorAmounts() public pure returns ( uint[] memory creditorAmounts ) {
        return creditorAmounts;
    }

}