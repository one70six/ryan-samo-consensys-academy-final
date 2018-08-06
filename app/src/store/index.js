import Vue from "vue";
import Vuex from "vuex";
import common from "./common";
import authentication from "./authentication";
import marketplace from "./marketplace";

Vue.use(Vuex);

export default new Vuex.Store({
  modules: {
    common: common,
    authentication: authentication,
    marketplace: marketplace
  }
});
