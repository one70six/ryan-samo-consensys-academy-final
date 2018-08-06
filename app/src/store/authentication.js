import Vue from "vue";
import createLogger from "vuex/dist/logger";
import * as types from "./mutation-types";
import { Authentication } from "../contracts";

/* global web3:true */

const debug = process.env.NODE_ENV !== "production";

const authentication = {
  state: {
    accountBalance: 0,
    isCurrentAdmin: false,
    isCurrentOrPastAdmin: false,
    isCurrentStoreOwner: false,
    isCurrentOrPastStoreOwner: false,
    admins: [],
    storeOwners: []
  },
  getters: {
    isCurrentAdmin: state => state.isCurrentAdmin,
    isCurrentOrPastAdmin: state => state.isCurrentOrPastAdmin,
    isCurrentStoreOwner: state => state.isCurrentStoreOwner,
    isCurrentOrPastStoreOwner: state => state.isCurrentOrPastStoreOwner,
    admins: state => state.admins,
    storeOwners: state => state.storeOwners
  },
  actions: {
    getAuthenticationContractData({ commit, state, rootState }) {
      Authentication.deployed()
        .then(instance =>
          Promise.all([
            instance.isCurrentAdmin.call(rootState.common.account, {
              from: rootState.common.account
            }),
            instance.isCurrentOrPastAdmin.call(rootState.common.account, {
              from: rootState.common.account
            }),
            instance.isCurrentStoreOwner.call(rootState.common.account, {
              from: rootState.common.account
            }),
            instance.isCurrentOrPastStoreOwner.call(rootState.common.account, {
              from: rootState.common.account
            })
          ])
        )
        .then(constants => {
          //console.log(constants)
          commit(types.AUTHENTICATION, constants);
        })
        .catch(err => {
          console.error(err);
          //alert(err)
          commit(
            types.UPDATE_STATUS,
            "Error getAuthenticationContractData; see log."
          );
        });
    },
    async getAuthenticationAdminArrayData({ commit, rootState }) {
      try {
        let authentication = await Authentication.deployed();
        var addresses = await authentication.getAdmins.call({
          from: rootState.common.account
        });

        var i = addresses.length;
        while (i--) {
          var isAdmin = await authentication.isCurrentAdmin.call(addresses[i], {
            from: rootState.common.account
          });

          if (!isAdmin) addresses.splice(i, 1);
        }

        commit(types.AUTHENTICATION_ADMINS, addresses);
      } catch (err) {
        console.error(err);
        commit(
          types.UPDATE_STATUS,
          "Error getAuthenticationAdminArrayData; see log."
        );
      }
    },
    async getAuthenticationStoreOwnerArrayData({ commit, rootState }) {
      try {
        let authentication = await Authentication.deployed();
        var addresses = await authentication.getStoreOwners.call({
          from: rootState.common.account
        });

        var i = addresses.length;
        while (i--) {
          var isStoreOwner = await authentication.isCurrentStoreOwner.call(
            addresses[i],
            { from: rootState.common.account }
          );

          if (!isStoreOwner) addresses.splice(i, 1);
        }

        commit(types.AUTHENTICATION_STORE_OWNERS, addresses);
      } catch (err) {
        console.error(err);
        commit(
          types.UPDATE_STATUS,
          "Error getAuthenticationStoreOwnerArrayData; see log."
        );
      }
    }
  },
  mutations: {
    [types.AUTHENTICATION](state, constants) {
      state.isCurrentAdmin = constants[0];
      state.isCurrentOrPastAdmin = constants[1];
      state.isCurrentStoreOwner = constants[2];
      state.isCurrentOrPastStoreOwner = constants[3];
    },
    [types.AUTHENTICATION_ADMINS](state, admins) {
      for (let index = 0; index < admins.length; index++) {
        const element = admins[index];
        Vue.set(state.admins, index, { address: element });
      }
    },
    [types.AUTHENTICATION_STORE_OWNERS](state, storeOwners) {
      for (let index = 0; index < storeOwners.length; index++) {
        const element = storeOwners[index];
        Vue.set(state.storeOwners, index, { address: element });
      }
    },
    [types.AUTHENTICATION_ADMIN_REMOVED_EVENT](state, admin) {
      for (let index = 0; index < state.admins.length; index++) {
        const element = state.admins[index];
        if (element.address === admin) {
          state.admins.splice(index, 1);
          return;
        }
      }
    },
    [types.AUTHENTICATION_STORE_OWNER_REMOVED_EVENT](state, storeOwner) {
      for (let index = 0; index < state.storeOwners.length; index++) {
        const element = state.storeOwners[index];
        console.log(storeOwner);
        if (element.address === storeOwner) {
          state.storeOwners.splice(index, 1);
          return;
        }
      }
    }
  },
  strict: debug,
  plugins: debug ? [createLogger()] : []
};

export default authentication;
