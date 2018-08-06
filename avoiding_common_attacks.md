# Integer Over / Underflow
There are a few methods that deal with price and qty in my contracts. I have setup require statements to check for valid qtys or prices before the core logic executes in order to keep an over/underflow situation from happening.

# Reentrancy
In the Marketplace contract, I have a reference to the Authorization contract. External calls are made to the Authorization contract from the Marketplace contract to check the msg.sender status. Are they and admin, store owner, etc. These checks come at the head of the functions via require and modifiers to keep reentrancy from occuring.

# Pitfalls in Race Condition Solutions
I have multiple methods that rely on the enums for state changes. To keep race conditions to a minimum, I tried to carefully change the state of stores and items only when necessary. One example is that items only belong to a store so many users have to be buying from the same store at the same time to have an issue. Then, items are tied to a buyer so that they cannot be repurchased. Just for example. 