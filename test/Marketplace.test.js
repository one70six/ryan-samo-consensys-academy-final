/*
+-------------------------------------------------------------+
| Name:     Marketplace.test.js                               |
| Created:  20180709                                          |
| Author:   Ryan Samo                                         |
| Purpose:  Unit testing for the Marketplace smart            |
|           contract on Ethereum blockchain                   |
+-------------------------------------------------------------+
*/

const Authentication = artifacts.require("Authentication");
const Marketplace = artifacts.require("Marketplace");

contract('Marketplace', async (accounts) => {

    let authentication;
    let marketplace;

    const adminAccount = accounts[0];
    const storeOwnerAccount = accounts[1];
    const buyerAccount = accounts[2];

    beforeEach('setup contract communication for each test', async function () {
        authentication = await Authentication.deployed();
        marketplace = await Marketplace.deployed();
    });

    it("should communicate with the Authentication contract", async () => {
        assert.ok(authentication.address);
    });

    it("should communicate with the Marketplace contract", async () => {
        assert.ok(marketplace.address);
    });

    it("should add a store owner correctly", async () => {
        await authentication.addStoreOwner(storeOwnerAccount);
        await authentication.StoreOwnerAdded();
    });

    it("should open a new store correctly", async () => {
        await marketplace.openStore("Test Store", {
            from: storeOwnerAccount
        });
        await marketplace.StoreOpened();
    });

    it("should add a store item correctly", async () => {
        await marketplace.addItem(0, 200123, "Hat", 1, 2, {
            from: storeOwnerAccount
        });
        await marketplace.ItemForSale();
    });

    it("should buy a store item correctly", async () => {
        await marketplace.buyItem(0, 200123 ,1 , {
            from: buyerAccount,
            value: 3
        });
        await marketplace.ItemSold();
    });

    it("should ship a store item correctly", async () => {
        await marketplace.shipItem(0, 200123, 1, buyerAccount, {
            from: storeOwnerAccount
        });
        await marketplace.ItemShipped();
    });

    it("should receive a store item correctly", async () => {
        await marketplace.receiveItem(0, 200123, 1, {
            from: buyerAccount
        });
        await marketplace.ItemReceived();
    });
});