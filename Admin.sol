pragma solidity ^0.4.18;

/**
* @title Admin parameters
* @dev Define administration parameters for this contract
*/
contract Admin {
    //This token contract is administered
    address public admin; //Admin address is public
    bool public lockSupply; //Mint and Burn Lock flag
    bool public lockTransfer; //Transfer Lock flag
    address public allowedAddress; //an address that can override lock condition
    bool public lockTokenSupply;

    /**
    * @dev Contract constructor
    * define initial administrator
    */
    function admined() internal {
        admin = msg.sender; //Set initial admin to contract creator
        Admined(admin);
    }

   /**
    * @dev Function to set an allowed address
    * @param _to The address to give privileges.
    */
    function setAllowedAddress(address _to) public {
        allowedAddress = _to;
        AllowedSet(_to);
    }

    modifier onlyAdmin() { //A modifier to define admin-only functions
        require(msg.sender == admin);
        _;
    }

    modifier supplyLock() { //A modifier to lock mint and burn transactions
        require(lockSupply == false);
        _;
    }

    modifier transferLock() { //A modifier to lock transactions
        require(lockTransfer == false || allowedAddress == msg.sender);
        _;
    }

   /**
    * @dev Function to set new admin address
    * @param _newAdmin The address to transfer administration to
    */
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered
        admin = _newAdmin;
        TransferAdminship(admin);
    }

   /**
    * @dev Function to set mint and burn locks
    * @param _set boolean flag (true | false)
    */
    function setSupplyLock(bool _set) onlyAdmin public { //Only the admin can set a lock on supply
        lockSupply = _set;
        SetSupplyLock(_set);
    }

   /**
    * @dev Function to set transfer lock
    * @param _set boolean flag (true | false)
    */
    function setTransferLock(bool _set) onlyAdmin public { //Only the admin can set a lock on transfers
        lockTransfer = _set;
        SetTransferLock(_set);
    }

    function setLockTokenSupply(bool _set) onlyAdmin public {
        lockTokenSupply = _set;
        SetLockTokenSupply(_set);
    }

    function getLockTokenSupply() returns (bool) {
        return lockTokenSupply;
    }

    //All admin actions have a log for public review
    event AllowedSet(address _to);
    event SetSupplyLock(bool _set);
    event SetTransferLock(bool _set);
    event TransferAdminship(address newAdminister);
    event Admined(address administer);
    event SetLockTokenSupply(bool _set);

}