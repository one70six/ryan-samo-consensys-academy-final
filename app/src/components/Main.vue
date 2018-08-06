<template>
  <div id="mainVue">
    <section class="container">
      <h1 class="title">
        Online Marketplace
      </h1>
      <h2 class="subtitle">
        ConsenSysAcademy: 2018DP 2018 Developer Program Final Project
      </h2>
      <div class="work-area">
        <Administration v-if="isCurrentAdmin" />
        <StoreOwner v-else-if="isCurrentStoreOwner" />
        <Shopper v-else/>
      </div>
    </section>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import Administration from "./Administration";
import StoreOwner from "./StoreOwner";
import Shopper from "./Shopper";

export default {
  name: "MainVue",
  components: {
    Administration,
    StoreOwner,
    Shopper
  },
  data() {
    return {
      authenticationCheckInterval: null
    };
  },
  computed: {
    ...mapGetters(["status", "isCurrentAdmin", "isCurrentStoreOwner"])
  },
  mounted() {
    this.$store.dispatch("getAuthenticationContractData");

    this.authenticationCheckInterval = setInterval(() => {
      console.log("Dispatching getAuthenticationContractData");
      this.$store.dispatch("getAuthenticationContractData");
    }, 1000);
  },
  beforeDestroy() {
    clearInterval(this.authenticationCheckInterval);
  }
};
</script>

<style>
.title {
  display: block;
  font-weight: 300;
  font-size: 75px;
  color: #35495e;
  letter-spacing: 1px;
  margin-top: 7rem;
}

.subtitle {
  font-weight: 300;
  font-size: 30px;
  color: #526488;
  word-spacing: 5px;
  padding-bottom: 15px;
}

.paragraph-title {
  font-weight: 300;
  font-size: 20px;
  color: #35495e;
  word-spacing: 5px;
  padding: 15px 0;
}

.receipt-box {
  padding-top: 15px;
  width: 900px;
  word-break: break-all;
}

.row {
  padding: 10px;
}

.links {
  padding-top: 15px;
}

.work-area {
  display: block;
  width: 100%;
  padding: 8px;
}
</style>
