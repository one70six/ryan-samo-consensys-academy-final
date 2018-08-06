<template>
  <div id="app">

    <!-- No Web3/Metamask Modal Component -->
    <b-modal 
      id="modal-center-no-metamask" 
      centered 
      title="Could not locate Web3" 
      header-bg-variant="danger" 
      header-text-variant="light" 
      ok-only
      @ok="handleOk">
      <p class="my-4">This site requires a Web3 provider to be active.
        <br>Please login to the Metamask browser extension or visit
      <a href="https://metamask.io/">https://metamask.io/</a> to install and then refresh or revisit this page.</p>
    </b-modal>

    <!-- No Smart Contract Modal Component -->
    <b-modal 
      id="modal-center-no-contract" 
      centered 
      title="Could not locate Smart Contract" 
      header-bg-variant="danger" 
      header-text-variant="light" 
      ok-only
      @ok="handleOk">
      <p class="my-4">The selected Ethereum network does not have the required smart contracts deployed that interface with this app.
      <br>Please switch networks.</p>
    </b-modal>

    <MainHeader />
    <router-view/>
  </div>
</template>

<script>
/* global web3:true */

import Web3 from "web3";
import { mapGetters } from "vuex";
import MainHeader from "@/components/MainHeader";

export default {
  name: "App",
  components: {
    MainHeader
  },
  data() {
    return {
      accountInterval: null
    };
  },
  computed: {
    ...mapGetters([])
  },
  created() {
    var localRoot = this.$root;
    // Checking if Web3 has been injected by the browser (Mist/MetaMask)
    if (typeof web3 === "undefined") {
      console.error("No web3 detected...");
      this.$root.$emit("bv::show::modal", "modal-center-no-metamask");
      return;
    }

    if (web3) {
      // Make sure web3 is usable
      web3.eth.getAccounts(function(err, accounts) {
        if (err != null) {
          console.error("An error occurred: ", err);
        } else if (accounts.length == 0) {
          localRoot.$emit("bv::show::modal", "modal-center-no-metamask");
        } else {
          console.log("User is logged in to MetaMask");
        }
      });

      // Use Mist/MetaMask's provider
      window.web3 = new Web3(web3.currentProvider);

      // keep account updated if user decides to switch
      this.$store.dispatch("setAccount", web3.eth.accounts[0]);
      this.accountInterval = setInterval(() => {
        const account = web3.eth.accounts[0];
        if (account !== this.account) {
          this.$store.dispatch("updateAccount", account);
          this.$store.dispatch("getCurrentAccountBalance");
          this.$store.dispatch("getCurrentBlockNumber");
        }
      }, 1000);
    }
  },
  beforeDestroy() {
    clearInterval(this.accountInterval);
  },
  methods: {
    handleOk() {
      location.reload();
    }
  }
};
</script>

<style>
@import url("https://fonts.googleapis.com/css?family=Montserrat:400,700");

#app {
  font-family: "Montserrat", Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
