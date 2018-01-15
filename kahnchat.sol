pragma solidity ^0.4.18;
/**
* KahnChat
* ERC-20 Token Standard Compliant
* @author Oyewole A. Samuel oyewoleabayomi@gmail.com
*/

import "./SafeMath.sol";
import "./StandardToken.sol";


/** @title KahnChat
*   @dev Initial Token Creation
*/

contract KahnChat is StandardToken {
    string public name = "KahnChat";
    string public symbol = "KCH";
    uint8 public decimals = 18;
    string public version = "1.0.0";

    uint256 public constant RATE = 500;
    address public owner;

    /**
     * @title Lists of allowed members
     * @description Under the KYC and AML, only buyer who passed the KYC and AML 
     * checked are allows to buy the tokens
     */
    mapping(address => bool) whiteListAllowedMember;

    struct ICOPhase {
        uint fromTimestamp; //ico starting timestamp
        uint toTimestamp; // ico end timestamp
        uint256 minimum; // Minimum purchase for each phase in wei
        uint256 weiRaised;
        uint bonus; // In percent, ie 10 is a 10% for bonus
        uint totalNumberOfTokenPurchase; //number of token allowed for each phase
    }

    mapping(uint => ICOPhase) phases;
    uint icoPhaseCounter = 0;

    enum IcoStatus{Pending, Active, Inactive}
    IcoStatus status;

    uint256 public weiTotalRaised;

    modifier statusMustBeActive() { //A modifier to lock mint and burn transactions
        require(status == IcoStatus.Active);
        _;
    }     

    function KahnChat() public {
        totalSupply = 80000000 * (10**uint256(decimals)); //80 million initial token creation
        balances[msg.sender] = totalSupply; 
        status = IcoStatus.Inactive; //Set ICO status to Inactive, use setStatus function to change status
        owner = msg.sender;
    }

    //Set ICOPhase
    function setICOPhase(uint _fromTimestamp, uint _toTimestamp, uint256 _min, uint _bonus, uint _numOfToken) onlyAdmin public returns (uint ICOPhaseId) {
        uint icoPhaseId = icoPhaseCounter++;
        ICOPhase storage ico = phases[icoPhaseId];
        ico.fromTimestamp = _fromTimestamp;
        ico.toTimestamp = _toTimestamp;
        ico.minimum = _min;
        ico.bonus = _bonus;
        ico.totalNumberOfTokenPurchase = _numOfToken;

        phases[icoPhaseId] = ico;

        return icoPhaseCounter;
    }   

    //Get current ICO Phase
    function getCurrentICOPhase() public view returns (uint _bonus) {
        require(icoPhaseCounter > 0);
        uint currentTimestamp = block.timestamp; //Get the current block timestamp

        for (uint i = 0; i < icoPhaseCounter; i++) {
            
            ICOPhase storage ico = phases[i];

            if (currentTimestamp >= ico.fromTimestamp && currentTimestamp <= ico.toTimestamp) {
                return ico.bonus;
            }
        }

    }

    //Add member whiteList Token
    function addMemberToWhiteList(address _allowableMember, bool _status) public {
        whiteListAllowedMember[_allowableMember] = _status;
    }

    //Set ICO Status
    function activateICOStatus() public {
        status = IcoStatus.Active;
    }
    
    event TokenTransfer(address _member, uint256 _value);

    //Method to transfer token manually
    function transferTokenToMember(address _member, uint256 _value) onlyAdmin public {
        require(status == IcoStatus.Active);

        var bonus = getCurrentICOPhase();       //get current ICO phase inform
        uint256 numTokens = _value.safeMul(RATE);       //get number of number of tokens
        uint256 bonusToken = (bonus / 100) * numTokens;
        uint totalToken = numTokens.safeAdd(bonusToken);               //Total tokens to transfer
        balances[msg.sender] = balances[msg.sender].safeSub(totalToken); //subtract from total tokens
        transfer(_member, totalToken);

        TokenTransfer(_member, _value);
    }

    function () public payable {
        require(msg.value > 0 );//check if it contain value and ICO is active
        uint amount = msg.value; //assign value
        uint256 tokens = msg.value.safeMul(RATE);

        balances[msg.sender] = balances[msg.sender].safeAdd(amount);
        weiTotalRaised += amount;
        owner.transfer(msg.value);
        TokenTransfer(msg.sender, amount);
    }

}