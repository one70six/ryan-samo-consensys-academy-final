# Fail early, fail loud!
I decided to use "require" statements at the beginning of almost every method in my smart contracts to make sure that the user inputs were valid before continuing the execution. If a failure occurs, the contract function exits immediately and can be caught on the UI if required.

# Restricting Access
I also used the "require" statements to check the msg.sender and verify that they are indeed allowed to execute certain portions of the code. If they are not, fail early, fail loud!

# Circuit Breaker
I created and emergency stop procedure that can be called by an admin, just in case the marketplace goes haywire and business needs to stop. Important methods have a "stopped" modifier to carry this out.

# State Machine
I used enums to track the state of both stores and items. This is how you know when stores are open or closed or items can be shipped, etc.

# EthPM
I added the OpenZeppelin Ownable contract so that if/when the Marketplace becomes too much to handle or gets purchased, I can transfer the ownership of the underlying contracts to another address.