/*
+-------------------------------------------------------------+
| Name:     Authentication.test.js                            |
| Created:  20180709                                          |
| Author:   Ryan Samo                                         |
| Purpose:  Unit testing for the Authentication smart         |
|           contract on Ethereum blockchain                   |
+-------------------------------------------------------------+
*/

const Authentication = artifacts.require("Authentication");

contract('Authentication', async (accounts) => {

    let authentication;

    const adminAccount = accounts[1];
    const storeOwnerAccount = accounts[2];

    beforeEach('setup contract communication for each test', async function () {
        authentication = await Authentication.deployed();
    });

    it("should communicate with the Authentication contract", async () => {
        assert.ok(authentication.address);
    });

    it("should add an admin correctly", async () => {
        await authentication.addAdmin(adminAccount);
    });

    it("should remove an admin correctly", async () => {
        await authentication.removeAdmin(adminAccount);
    });

    it("should add a store owner correctly", async () => {
        await authentication.addStoreOwner(storeOwnerAccount);
    });

    it("should remove a store owner correctly", async () => {
        await authentication.removeStoreOwner(storeOwnerAccount);
    });

});