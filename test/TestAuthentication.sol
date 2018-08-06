pragma solidity ^0.4.22;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Authentication.sol";

contract TestAuthentication {

    function testThisAccountIsFirstAdminUsingDeployedContract() public {
        Authentication auth = Authentication(DeployedAddresses.Authentication());
        Assert.equal(auth.adminAudit(0), msg.sender, "Is first admin / contract creator");
    }

    function testIsCurrentAdminUsingDeployedContract() public {
        Authentication auth = Authentication(DeployedAddresses.Authentication());
        Assert.equal(auth.isCurrentAdmin(msg.sender), true, "Is current admin");
    }

    function testIsCurrentOrPastAdminUsingDeployedContract() public {
        Authentication auth = Authentication(DeployedAddresses.Authentication());
        Assert.equal(auth.isCurrentOrPastAdmin(msg.sender), true, "Is current or past admin");
    }

    function testIsCurrentStoreOwnerUsingDeployedContract() public {
        Authentication auth = Authentication(DeployedAddresses.Authentication());
        Assert.equal(auth.isCurrentStoreOwner(msg.sender), false, "Is current store owner");
    }

    function testIsCurrentOrPastStoreOwnerUsingDeployedContract() public {
        Authentication auth = Authentication(DeployedAddresses.Authentication());
        Assert.equal(auth.isCurrentOrPastStoreOwner(msg.sender), false, "Is current or past store owner");
    }

}