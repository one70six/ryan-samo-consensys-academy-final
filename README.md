# ryan-samo-consensys-academy-final

## ConsenSysAcademy: 2018DP 2018 Developer Program Final Project

> A Vue.js / Truffle / Ethereum project

## What does this project do?

This is an Ethereum Blockchain dApp for running an online marketplace. You can...

- Add/Remove Admins
- Add/Remove Store Owners
- Open/Close Stores
- Add/Remove Items
- Purchase Items
- Ship Items
- Receive Items
- etc.

## How do I set it up?

To interact with this dApp, you will need the following tools...

- npm
- Ganache
- Truffle
- All npm dependencies for the dApp
- Metamask

## Installing NPM

Please visit the following site to download and install: [Node.js](https://nodejs.org/en/)

## Installing Ganache

```bash
npm install -g ganache-cli
```

## Installing Truffle

```bash
npm install -g truffle
```

## Installing Metamask

Please visit the following site to download and install: [MetaMask](https://metamask.io/)

## Smart Contract Migration

```bash
# Make sure you are in the ryan-samo-consensys-academy-final directory
cd ~/ryan-samo-consensys-academy-final

# Run this:
truffle migrate --network ganache_cli --reset
```

## Smart Contract Testing

```bash
# Move to the test directory
cd ~/ryan-samo-consensys-academy-final/test

# Launch the tests
truffle test --network ganache_cli
```

## Running the dApp

```bash
# Start Ganache CLI on a separate terminal
ganache-cli

# In a new terminal, move to the app directory
cd ~/ryan-samo-consensys-academy-final/app

# Install dependencies
npm install

# Serve with hot reload at localhost:8080
npm run dev
```

## Interacting with the dApp

1.  When the dApp first loads, web3 will not be connected. Try refreshing the page and you should get an error.
2.  Copy the seed phrase from the ganache-cli terminal
3.  Open Metamask in your browser and make sure the localhost:8545 network is selected
4.  Click the "Restore from seed phrase" link, paste in the seed phrase, enter a random 8 char password, and click OK.
5.  You can now ether refresh the page manually or click the OK button on the error pop up.
6.  If you are connected you should see "Admin" with an address, balance, and block number in the top right corner.
7.  From here you are an admin. go to the "Add/Remove Store Owners" tab. Copy an account address from the ganache terminal, paste it into the text box, and click "Add". Metamask should prompt you for the transaction, hit "Submit".
8.  You should see the UI update with a new Store Owner. Copy the private key for this store owner from the ganache terminal, open Metamask, and import the account using the private key.
9.  You should see the UI change from an Admin view to a Store Owner view. Open 2 or 3 new stores and name them whatever you wish.
10. Switch to the "Add/Remove Items" tab and add some new items to the stores. Be careful with qty as you can run out of gas!
11. Copy another private key for an unused account from the ganache terminal and import the account into Metamask. You should see the UI switch to a Shopper view with all of the stores.
12. Click on a store that you have added items to so that we can shop. Find and item and purchase it.
13. In Metamask, switch to the previous Store Owner account to bring up the Store owner UI. Navigate to the "Ship Items" tab and ship the item(s) that were just purchased.
14. In Metamask, switch back to the Shopper account to bring up the Shopper UI. Navigate to the "Receive Items" tab and receive the item(s) that were just purchased.

### Congrats, you have used the Marketplace!

## A Few Lessons Learned

1.  Some of the events rely on the block time. When using Ganache, it has a bug when attempting to change the block time so getting a feel for a real test or mainnet can be tough. You might see alerts in my app pop up when they shouldn't because there is no block time in vanilla ganache.
2.  Need to think harder in the future about user experience because of the delay in block time.
3.  Need to consider placing less storage and heavy logic on the blockchain if going to mainnet due to $$$!
4.  IPFS only deals with static content for now so deploying dynamic websites can be a problem. I need to find alternative approaches to UI creation. We can flatten a site with tools like Jekyll but some of the dynamics are lost.

## Rinkeby Testnet

The contracts were also deployed to the Rinkeby Testnet to be sure that they operate in the public space. You can reach the contracts at the following addresses:

- Ownable: 0x3c6ae7d9b2fcf8d3be23699913c621a92a12b4f0
- Authentication: 0x85d2350b1e7115b0c6654f9d0ca9cd5d2b7e6244
- Marketplace: 0x582239dd16f222ffd97e91b644567bee602c4c44
