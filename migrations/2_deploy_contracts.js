// Declare the artifacts to be deployed
const Authentication = artifacts.require('./Authentication.sol')
const Marketplace = artifacts.require('./Marketplace.sol')
const Ownable = artifacts.require('../installed_contracts/zeppelin/contracts/ownership/Ownable.sol')

// Deploy them
module.exports = deployer => {
	deployer
		.deploy(Ownable)
		.then(() => deployer.deploy(Authentication))
		.then(() => deployer.deploy(Marketplace, Authentication.address))
}
