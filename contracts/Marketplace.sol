pragma solidity ^0.4.22;

import "./Authentication.sol";
import "../installed_contracts/zeppelin/contracts/ownership/Ownable.sol";

/**
 * @title Marketplace
 * @dev The Marketplace contract provides an online marketplace
 * service of stores and items.
 */
contract Marketplace is Ownable {
    
    // Keep track of the storeId
    uint private storeId;
    
    // For circuit breaker
    bool public stopped = false;
    
    // Marketplace admins
    mapping (address => bool) private admins;
    
    // Mapping to keep track of 1:N Store Structs
    uint[] private storeList;
    mapping (uint => Store) private storeStructs;
    
    // Keep track of state via enums
    enum StoreState { NotSet, Opened, Closed }
    enum ItemState { NotSet, ForSale, Sold, Shipped , Received, NotForSale }
    
    // Defines the authentication contract we use for credentials
    Authentication private authenticationContract;
    
    // Structs
    struct Store {
        uint index;
        uint id;
        string name;
        StoreState state;
        uint skuCount;
        address owner;
        uint[] itemList;
        mapping (uint => Item) itemStructs;
    }
    
    struct Item {
        uint index;
        string name;
        uint sku;
        uint price;
        ItemState state;
        address seller;
        address buyer;
    }
    
    // Store Events
    event StoreOpened (uint _id);
    event StoreClosed (uint _id);
    
    // Item Events
    event ItemForSale (uint _storeId, uint _sku, uint _quantity);
    event ItemSold (uint _storeId, uint _sku, uint _quantity);
    event ItemShipped (uint _storeId, uint _sku, uint _quantity);
    event ItemReceived (uint _storeId, uint _sku, uint _quantity);
    event ItemNotForSale (uint _storeId, uint _sku, uint _quantity);
    
    // Modifiers
    modifier stopInEmergency {require(!stopped); _;}
    modifier adminOnly {require(authenticationContract.isCurrentAdmin(msg.sender)); _;}
    modifier anyStoreOwnerOnly {require(authenticationContract.isCurrentStoreOwner(msg.sender)); _;}
    modifier thisStoreOwnerOnly(uint _storeId) {require(storeStructs[_storeId].owner == msg.sender); _;}
    modifier isValidState(uint8 _state) {require(uint(ItemState.NotForSale) >= _state); _;}
    
    /** @dev Constructor with references to our other contracts.
      * @param _authenticationContractAddress Address of the Authentication contract.
      */
    constructor(address _authenticationContractAddress) public {
        authenticationContract = Authentication(_authenticationContractAddress);
        storeId = 0;
    }

    /** @dev Function to allow an admin to perform and emergency stop on the contract.
      */
    function emergencyStop() public adminOnly {
        stopped = true;
    }
     
    /** @dev Function to allow a store owner to add a new Store.
      * @param _name Name of the store.
      * @return opened Is the store opened.
      */   
    function openStore(string _name) 
        public 
        anyStoreOwnerOnly 
        stopInEmergency
        returns (bool opened) {
        
        // Fill in a new Store struct
        storeStructs[storeId].index = storeId;
        storeStructs[storeId].id = storeId;
        storeStructs[storeId].name = _name;
        storeStructs[storeId].state = StoreState.Opened;
        storeStructs[storeId].skuCount = 0;
        storeStructs[storeId].owner = msg.sender;
        
        // Add the storeId to the index
        storeList.push(storeId);
        
        // Log the event
        emit StoreOpened(storeId);
        
        storeId++;
        return true;
    }
     
    /** @dev Function to allow a store owner to close a Store.
      * @param _storeId The ID of the store.
      * @return closed Is the store closed.
      */   
    function closeStore(uint _storeId) 
        public 
        thisStoreOwnerOnly(_storeId)
        stopInEmergency
        returns (bool closed) {

        // Mark the store as closed
        storeStructs[_storeId].state = StoreState.Closed;
        
        // Log the event
        emit StoreClosed(_storeId);
        
        return true;
    }
     
    /** @dev Function to allow a store owner to reopen a closed Store.
      * @param _storeId The ID of the store.
      * @return reopened Is the store reopened.
      */
    function reopenStore(uint _storeId) 
        public 
        thisStoreOwnerOnly(_storeId)
        stopInEmergency
        returns (bool reopened) {

        // Mark the store as closed
        storeStructs[_storeId].state = StoreState.Opened;
        
        // Log the event
        emit StoreOpened(_storeId);
        
        return true;
    }
    
    /** @dev Function to return a Store.
      * @param _storeId The ID of the store.
      * @return id The store id.
      * @return name The store name.
      * @return state The store state. Open or Closed.
      * @return itemList The store item list. An array of items.
      */
    function getStore(uint _storeId)
        public
        view
        returns(uint id, string name, StoreState state, uint itemCount)
    {
        return(storeStructs[_storeId].id, storeStructs[_storeId].name, storeStructs[_storeId].state, storeStructs[_storeId].itemList.length);
    }
    
    /** @dev Function to return an array of store indexes.
      * @return storeList an array of store indexes.
      */
    function getStoreIndexes() 
        public 
        view 
        returns(uint[] indexes) {
        return storeList;
    }
  
    /** @dev Function to allow a store owner to add a new Item for sale.
      * @param _storeId The ID of the store where the item will be sold.
      * @param _sku The sku of the item.
      * @param _name The name fo the item.
      * @param _price The price fo the item.
      * @param _quantity The quantity fo the item.
      * @return added Was the item added.
      */
    function addItem(uint _storeId, uint _sku, string _name, uint _price, uint _quantity) 
        public 
        thisStoreOwnerOnly(_storeId) 
        stopInEmergency
        returns(bool added) {
        
        // Add 1:N items to the store based on quantity
        for (uint i = 0; i < _quantity; i++) {
            
            // Push a new index value for the item
            uint itemIndex = storeStructs[_storeId].itemList.push(_sku) - 1;
            storeStructs[_storeId].itemStructs[itemIndex].index = itemIndex;
            storeStructs[_storeId].itemStructs[itemIndex].name = _name;
            storeStructs[_storeId].itemStructs[itemIndex].sku = _sku;
            storeStructs[_storeId].itemStructs[itemIndex].price = _price;
            storeStructs[_storeId].itemStructs[itemIndex].state = ItemState.ForSale;
            storeStructs[_storeId].itemStructs[itemIndex].seller = msg.sender;
            storeStructs[_storeId].itemStructs[itemIndex].buyer = 0;

        }
        
        // Log the event
        emit ItemForSale(_storeId, _sku, _quantity);
        return true;
    }
    
    /** @dev Function to allow the store owner to remove an Item for sale. 
      * @dev Logical delete as it changes the state to ItemState.NotForSale.
      * @param _storeId The ID of the store where the item will be sold.
      * @param _sku The sku of the item.
      * @param _quantity The quantity fo the item.
      * @return removed Was the item removed.
      */
    function removeItem(uint _storeId, uint _sku, uint _quantity) 
        public 
        thisStoreOwnerOnly(_storeId)
        stopInEmergency
        returns(bool removed) {
        
        uint removableCount;
        uint[] memory indexes = getItemIndexesBySkuAndState(_storeId, _sku, uint8(ItemState.ForSale));
        
        // Make sure they specify a valid quantity
        require(_quantity > 0 && _quantity <= indexes.length);
        
        // Remove 1:N items from the store based on quantity
        for (uint i = 0; i < indexes.length; i++) {
            removableCount++;
            storeStructs[_storeId].itemStructs[indexes[i]].state = ItemState.NotForSale;
            if(removableCount == _quantity) {break;}
        }
        
        // Log the event
        emit ItemNotForSale(_storeId, _sku, _quantity);
        
        return true;
    }

    /** @dev Function to allow the purchasing of an Item. 
      * @param _storeId The ID of the store where the item will be sold.
      * @param _sku The sku of the item.
      * @param _quantity The quantity fo the item.
      * @return purchased Was the item purchased.
      */
    function buyItem(uint _storeId, uint _sku, uint _quantity)
      public
      payable
      stopInEmergency
      returns(bool purchased)
    {
        uint sellableCount;
        uint totalPrice;
        
        // Get the indexes of all items that match the store, sku, and state
        uint[] memory indexes = getItemIndexesBySkuAndState(_storeId, _sku, uint8(ItemState.ForSale));
        
        // Make sure they specify a valid quantity
        require(_quantity > 0 && _quantity <= indexes.length);
        
        // Track the sellable items
        uint[] memory sellableIndexes = new uint[](_quantity);
        
        // Pick the sellable items based on quantity requested and total the sale price
        for (uint i = 0; i < indexes.length; i++) {
            if(msg.value >= storeStructs[_storeId].itemStructs[i].price)
            {
                sellableCount++;
                sellableIndexes[i] = indexes[i];
                totalPrice += storeStructs[_storeId].itemStructs[i].price;
                if(sellableCount == _quantity) {break;}
            }
        }
        
        // Make sure they paid enough and we have sellable inventory
        require(msg.value >= totalPrice && totalPrice != 0);
        require(sellableIndexes.length >= _quantity);
        
        // Log the sale
        emit ItemSold(_storeId, _sku, _quantity);
        
        // Loop through the sellable items
        for (i = 0; i < sellableIndexes.length; i++) {
            
            // Mark the items as Sold
            uint itemIndex = sellableIndexes[i];
            storeStructs[_storeId].itemStructs[itemIndex].buyer = msg.sender;
            storeStructs[_storeId].itemStructs[itemIndex].state = ItemState.Sold;
            
            // Send the value of all goods to the seller from the buyer once
            if(i == 0) {storeStructs[_storeId].itemStructs[itemIndex].seller.transfer(totalPrice);}
        }
        
        // Refund the buyer any excess funds if they overpaid
        if (msg.value > totalPrice) {
            msg.sender.transfer(msg.value - totalPrice);
        }
        
        return true;
    }

    /** @dev Function to ship the Store Item only if it is sold. 
      * @param _storeId The ID of the store where the item will be sold.
      * @param _sku The sku of the item.
      * @param _quantity The quantity fo the item.
      * @param _buyer The buyer fo the item.
      * @return shipped Was the item shipped.
      */
    function shipItem(uint _storeId, uint _sku, uint _quantity, address _buyer)
      public
      thisStoreOwnerOnly(_storeId)
      stopInEmergency
      returns(bool shipped)
    {
        uint shippableCount;
        
        // Get the indexes of all items that match the store, sku, and state
        uint[] memory indexes = getItemIndexesBySkuAndState(_storeId, _sku, uint8(ItemState.Sold));
        
        // Ship to the buyer only
        for (uint i = 0; i < indexes.length; i++) {
            uint itemIndex = indexes[i];
            if(storeStructs[_storeId].itemStructs[itemIndex].buyer == _buyer) {
                shippableCount++;
                storeStructs[_storeId].itemStructs[itemIndex].state = ItemState.Shipped;
                if(shippableCount == _quantity) {break;}
            }
        }
        
        // Log the event
        emit ItemShipped(_storeId, _sku, _quantity);
        return true;
    }

    /** @dev Function that allows the buyer to mark the Store Item as received. 
      * @param _storeId The ID of the store where the item will be sold.
      * @param _sku The sku of the item.
      * @param _quantity The quantity fo the item.
      * @return received Was the item received.
      */
    function receiveItem(uint _storeId, uint _sku, uint _quantity)
      public
      stopInEmergency
      returns(bool received)
    {
        uint receivableCount;
        
        // Get the indexes of all items that match the store, sku, and state
        uint[] memory indexes = getItemIndexesBySkuAndState(_storeId, _sku, uint8(ItemState.Shipped));
        
        //Make sure they are not trying to receive more than was shipped but they can short.
        require(_quantity > 0 && _quantity <= indexes.length);
        
        // Allow buyer only to receive.
        for (uint i = 0; i < indexes.length; i++) {
            uint itemIndex = indexes[i];
            if(storeStructs[_storeId].itemStructs[itemIndex].buyer == msg.sender) {
                receivableCount++;
                storeStructs[_storeId].itemStructs[itemIndex].state = ItemState.Received;
                if(receivableCount == _quantity) {break;}
            }
        }
        
        // Log the event
        emit ItemReceived(_storeId, _sku, _quantity);
        return true;
    }
    
    /** @dev Function that returns an Item struct. 
      * @param _storeId The ID of the store where the item will be sold.
      * @param _index The index of the item.
      * @return storeName The name of the store where the item resides.
      * @return index The index of the item in the store.
      * @return name The name of the item.
      * @return sku The sku of the item.
      * @return price The price of the item.
      * @return quantity The quantity of the item.
      * @return state The state of the item. ForSale, Sold, etc.
      * @return seller The seller of the item.
      * @return buyer The buyer of the item.
      */
    function getItem(uint _storeId, uint _index) 
        public 
        view 
        returns (string storeName, uint index, string name, uint sku, uint price, uint quantity, uint state, address seller, address buyer) {
        storeName = storeStructs[_storeId].name;
        index = storeStructs[_storeId].itemStructs[_index].index;
        name = storeStructs[_storeId].itemStructs[_index].name;
        sku = storeStructs[_storeId].itemStructs[_index].sku;
        price = storeStructs[_storeId].itemStructs[_index].price;
        quantity = getItemCountOnHand(_storeId, storeStructs[_storeId].itemStructs[_index].sku);
        state = uint(storeStructs[_storeId].itemStructs[_index].state);
        seller = storeStructs[_storeId].itemStructs[_index].seller;
        buyer = storeStructs[_storeId].itemStructs[_index].buyer;
        return (storeName, index, name, sku, price, quantity, state, seller, buyer);
    }
    
    /** @dev For a given store and sku, get the item count in stock, i.e. ItemState.ForSale. 
      * @param _storeId The ID of the store where the item will be sold.
      * @param _sku The _sku of the item.
      * @return quantity The quantity of the item.
      */
    function getItemCountOnHand(uint _storeId, uint _sku) public view returns(uint quantity) {
        return getItemIndexesBySkuAndState(_storeId, _sku, uint8(ItemState.ForSale)).length;
    }
    
    /** @dev For a given store, return the indexes of items by a given state. 
      * @param _storeId The ID of the store where the item will be sold.
      * @param _state The state of the item. ForSale, Sold, etc.
      * @return indexes The indexes of the items by the state.
      */
    function getItemIndexesByState(uint _storeId, uint8 _state) public view returns(uint[] indexes) {
        return getItemIndexesBySkuAndState(_storeId, 0, _state);
    }
    
    /** @dev Get the indexes of all items for a store given a sku and optionally a state. 
      * @dev Not a fan of the double looping but it works without having to use storage arrays. 
      * @param _storeId The ID of the store where the item will be sold.
      * @param _sku The _sku of the item.
      * @param _state The state of the item. ForSale, Sold, etc.
      * @return indexes The indexes of the items by the sku and state.
      */
    function getItemIndexesBySkuAndState(uint _storeId, uint _sku, uint8 _state) 
        public 
        view 
        isValidState(_state)
        returns(uint[] indexes) {
    
        uint matchedIndexCount;
        
        // Cast the passed in state from int to the enum
        ItemState itemState = ItemState(_state);

        // Grab the index values stored in the struct
        for (uint i = 0; i < storeStructs[_storeId].itemList.length; i++) {

            // Match only on state OR match on sku and state
            if(_sku == 0 && 
               storeStructs[_storeId].itemStructs[i].state == itemState) {
                matchedIndexCount++;
            } else if(storeStructs[_storeId].itemList[i] == _sku && 
               storeStructs[_storeId].itemStructs[i].state == itemState) {
                matchedIndexCount++;
            }
        }
        
        // Our return array
        indexes = new uint[](matchedIndexCount);
        uint j;
        
        // Grab the index values stored in the struct
        for (i = 0; i < storeStructs[_storeId].itemList.length; i++) {

            // Match only on state OR match on sku and state
            if(_sku == 0 && 
               storeStructs[_storeId].itemStructs[i].state == itemState) {
                indexes[j] = i;
                j++;
            } else if(storeStructs[_storeId].itemList[i] == _sku && 
               storeStructs[_storeId].itemStructs[i].state == itemState) {
                indexes[j] = i;
                j++;
            }
        }
    
        return indexes;
    }
    
}