pragma solidity ^0.4.22;

import "../installed_contracts/zeppelin/contracts/ownership/Ownable.sol";

/**
 * @title Authentication
 * @dev The Authentication contract provides basic authorization control
 * to the Marketplace.
 */
contract Authentication is Ownable {
    
    // Map addresses to admins
    mapping (address => bool) public admins;

    // Map addresses to store owners
    mapping (address => bool) storeOwners;

    // Keep track of all admins that have ever existed
    address[] public adminAudit;

    // Keep track of all account readers that have ever existed
    address[] public storeOwnerAudit;

    // Events
    event AdminAdded(address addedBy, address admin);
    event AdminRemoved(address removedBy, address admin);
    event StoreOwnerAdded(address addedBy, address account);
    event StoreOwnerRemoved(address removedBy, address account);

    // Construct the contract
    constructor() public {
	
        // Set the first admin to be the person creating the contract
        admins[msg.sender] = true;
        emit AdminAdded(0, msg.sender);
        adminAudit.length++;
        adminAudit[adminAudit.length - 1] = msg.sender;
    }

    /** @dev Function to make sure the specified address is currently an admin.
      * @param _address Address of an Ethereum account.
      * @return bool Is the address a current admin.
      */
    function isCurrentAdmin(address _address) view public returns (bool) {
        return admins[_address];
    }

    /** @dev Function to make sure the specified address has ever been an admin.
      * @param _address Address of an Ethereum account.
      * @return bool Is the address a current or past admin.
      */
    function isCurrentOrPastAdmin(address _address) view public returns (bool) {
        for (uint256 i = 0; i < adminAudit.length; i++) {
            if (adminAudit[i] == _address) {
                return true;
            }          
        }           
        return false;
    }

    /** @dev Function to make sure the the specified address is currently a store owner.
      * @param _address Address of an Ethereum account.
      * @return bool Is the address a current store owner.
      */
    function isCurrentStoreOwner(address _address) view public returns (bool) {
        return storeOwners[_address];
    }

    /** @dev Function to make sure the specified address has ever been an admin.
      * @param _address Address of an Ethereum account.
      * @return bool Is the address a current or past store owner.
      */
    function isCurrentOrPastStoreOwner(address _address) view public returns (bool) {
        for (uint256 i = 0; i < storeOwnerAudit.length; i++) {
            if (storeOwnerAudit[i] == _address) {
                return true;
            }
        }    
        return false;
    }

    /** @dev Function to return an array of admins.
      * @return adminAddresses An array of Admin addresses.
      */
    function getAdmins() public view returns(address[] adminAddresses) {
        return adminAudit;
    }
    
    /** @dev Function to return an array of store owners.
      * @return storeOwnerAddresses An array of Store Owner addresses.
      */
    function getStoreOwners() public view returns(address[] storeOwnerAddresses) {
        return storeOwnerAudit;
    }

    /** @dev Funtion to add a user to the list of admins.
      * @param _address Address of an Ethereum account.
      */
    function addAdmin(address _address) public {
        
        // Ensure we're an admin
        require(isCurrentAdmin(msg.sender));

        // Fail if this account is already admin
        require(!admins[_address]);
        
        // Add the user
        admins[_address] = true;
        emit AdminAdded(msg.sender, _address);
        
        bool exists = false;
        for (uint i = 0; i < adminAudit.length; i++) {
            if(adminAudit[i] == _address) {
                exists = true;
                break;
            }
        }
        
        if(!exists) {
            adminAudit.length++;
            adminAudit[adminAudit.length - 1] = _address;
        }
    }

    /** @dev Funtion to remove a user from the list of admins but keeps them in the history audit.
      * @param _address Address of an Ethereum account.
      */
    function removeAdmin(address _address) public {
        
        // Ensure we're an admin
        require(isCurrentAdmin(msg.sender));

        // Don't allow removal of self
        require(_address != msg.sender);

        // Fail if this account is already non-admin
        require(admins[_address]);

        // Remove this admin user
        admins[_address] = false;
        emit AdminRemoved(msg.sender, _address);
    }

    /** @dev Funtion to add a user or contract to the list of store owners.
      * @param _address Address of an Ethereum account.
      */
    function addStoreOwner(address _address) public {
        
        // Ensure we're an admin
        require(isCurrentAdmin(msg.sender));

        // Fail if this account is already in the list
        require(!storeOwners[_address]);
        
        // Add the user
        storeOwners[_address] = true;
        emit StoreOwnerAdded(msg.sender, _address);
        
        bool exists = false;
        for (uint i = 0; i < storeOwnerAudit.length; i++) {
            if(storeOwnerAudit[i] == _address) {
                exists = true;
                break;
            }
        }
        
        if(!exists) {
            storeOwnerAudit.length++;
            storeOwnerAudit[storeOwnerAudit.length - 1] = _address;
        }
    }

    /** @dev Function to remove a user or contract from the list of store owners but keeps them in the history audit.
      * @param _address Address of an Ethereum account.
      */
    function removeStoreOwner(address _address) public {
        
        // Ensure we're an admin
        require(isCurrentAdmin(msg.sender));

        // Fail if this account is already not in the list
        require(storeOwners[_address]);

        // Remove this admin user
        storeOwners[_address] = false;
        emit StoreOwnerRemoved(msg.sender, _address);
    }
}