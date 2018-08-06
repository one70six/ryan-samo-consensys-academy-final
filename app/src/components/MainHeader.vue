<template>
  <div id="my-account">
    <header class="main-header">
      <nav class="main-nav">
        <ul class="nav-links">
          <router-link 
            to="/" 
            tag="li" 
            class="nav-link">
            <a>Home</a>
          </router-link>
          <router-link 
            to="/about" 
            tag="li" 
            class="nav-link">
            <a>About</a>
          </router-link>
          <p 
            v-if="account && isCurrentAdmin" 
            class="nav-info"> 
            <HeaderInfo 
              :account="account"
              :account-balance="accountBalance"  
              :current-block-number="currentBlockNumber"
              account-label="Admin" />
          </p><p 
            v-else-if="account && isCurrentStoreOwner" 
            class="nav-info">
            <HeaderInfo 
              :account="account"
              :account-balance="accountBalance"  
              :current-block-number="currentBlockNumber"
              account-label="Store Owner" />
          </p><p 
            v-else-if="account" 
            class="nav-info">
            <HeaderInfo 
              :account="account"
              :account-balance="accountBalance"  
              :current-block-number="currentBlockNumber"
              account-label="Shopper" />
          </p><p 
            v-else 
            class="nav-info">Not connected to Ethereum!!!</p>
        </ul>
      </nav>
    </header>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import HeaderInfo from "./HeaderInfo";

export default {
  name: "MyAccount",
  components: {
    HeaderInfo
  },
  computed: {
    ...mapGetters([
      "account",
      "accountBalance",
      "isCurrentAdmin",
      "isCurrentStoreOwner",
      "currentBlockNumber"
    ])
  }
};
</script>


<style scoped>
.main-header {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  background: #022d30;
  height: 3.5rem;
  z-index: 9999;
}

.main-nav {
  height: 100%;
}

.nav-links {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: row;
  justify-content: flex-start;
  flex: 2 0 0;
  align-items: center;
  height: 100%;
}

.nav-link {
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 0 1rem;
  padding: 0.3rem;
}

.nav-info {
  height: 100%;
  display: flex;
  flex: 1 0 0;
  justify-content: flex-end;
  align-items: center;
  margin: 0 1rem;
  padding: 0.3rem;
  color: white;
  font-size: 12px;
}

.nav-info p {
  text-align: left;
}

.nav-info b {
  color: #06c4d1;
}

.nav-link.nuxt-link-exact-active {
  border-bottom: 3px solid #06c4d1;
}

.nav-link a {
  display: block;
  text-decoration: none;
  color: white;
}

.nav-link a:hover,
.nav-link a:active,
.nav-link.nuxt-link-exact-active a {
  color: #06c4d1;
}

p {
  text-align: left;
}
</style>
