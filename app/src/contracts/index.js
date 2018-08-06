/* global web3:true */

import contract from "truffle-contract";

// Import artifacts
import authenticationArtifacts from "../../../build/contracts/Authentication.json";
import marketplaceArtifacts from "../../../build/contracts/Marketplace.json";

// Create contracts
const Authentication = contract(authenticationArtifacts);
Authentication.setProvider(web3.currentProvider);

const Marketplace = contract(marketplaceArtifacts);
Marketplace.setProvider(web3.currentProvider);

export { Authentication, Marketplace };
