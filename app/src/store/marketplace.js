import Vue from "vue";
import createLogger from "vuex/dist/logger";
import * as types from "./mutation-types";
import { Marketplace } from "../contracts";
import _ from "underscore";

/* global web3:true */

const debug = process.env.NODE_ENV !== "production";

const marketplace = {
  state: {
    stores: [],
    items: [],
    itemsToShip: [],
    itemsToReceive: [],
    currentStore: null
  },
  getters: {
    stores: state => state.stores,
    items: state => state.items,
    itemsToShip: state => state.itemsToShip,
    itemsToReceive: state => state.itemsToReceive,
    currentStore: state => state.currentStore
  },
  actions: {
    async getMarketplaceStoreArrayData({ commit, rootState }) {
      var stores = [];
      try {
        let marketplace = await Marketplace.deployed();
        var indexes = await marketplace.getStoreIndexes.call({
          from: rootState.common.account
        });
        for (let index = 0; index < indexes.length; index++) {
          const element = indexes[index].toNumber();
          var store = await marketplace.getStore.call(element, {
            from: rootState.common.account
          });
          var convertedStore = {
            id: store[0].toNumber(),
            name: store[1],
            state: store[2].toNumber(),
            itemCount: store[3].toNumber(),
            value: store[0].toNumber(),
            text: store[1]
          };

          stores.push(convertedStore);
        }

        commit(types.MARKETPLACE_STORES, stores);
      } catch (err) {
        console.error(err);
        commit(
          types.UPDATE_STATUS,
          "Error getMarketplaceStoreArrayData; see log."
        );
      }
    },
    async getMarketplaceStoreData({ commit, rootState }, payload) {
      try {
        let marketplace = await Marketplace.deployed();

        var store = await marketplace.getStore.call(payload.storeId, {
          from: rootState.common.account
        });

        var convertedStore = {
          id: store[0].toNumber(),
          name: store[1],
          state: store[2].toNumber(),
          itemCount: store[3].toNumber(),
          value: store[0].toNumber(),
          text: store[1]
        };

        commit(types.MARKETPLACE_CURRENT_STORE, convertedStore);
      } catch (err) {
        console.error(err);
        commit(
          types.UPDATE_STATUS,
          "Error getMarketplaceStoreArrayData; see log."
        );
      }
    },
    async getMarketplaceItemsForSaleData({ commit, rootState }, payload) {
      var items = [];
      try {
        let marketplace = await Marketplace.deployed();
        var indexes = await marketplace.getItemIndexesByState.call(
          payload.storeId,
          1,
          { from: rootState.common.account }
        );
        for (let index = 0; index < indexes.length; index++) {
          const element = indexes[index].toNumber();
          var item = await marketplace.getItem.call(payload.storeId, element, {
            from: rootState.common.account
          });
          var convertedItem = {
            storeId: payload.storeId,
            storeName: item[0],
            index: item[1].toNumber(),
            name: item[2],
            sku: item[3].toNumber(),
            price: item[4].toNumber(),
            qty: item[5].toNumber(),
            state: item[6].toNumber(),
            seller: item[7],
            buyer: item[8]
          };

          items.push(convertedItem);
        }

        // Rollup to unique items
        var uniqueItems = _.uniq(items, _.iteratee("sku"));

        commit(types.MARKETPLACE_ITEMS, uniqueItems);
      } catch (err) {
        console.error(err);
        commit(
          types.UPDATE_STATUS,
          "Error getMarketplaceItemsForSaleData; see log."
        );
      }
    },
    async getMarketplaceItemsToShipData({ commit, rootState }, payload) {
      var items = [];
      try {
        let marketplace = await Marketplace.deployed();
        var indexes = await marketplace.getItemIndexesByState.call(
          payload.storeId,
          2,
          { from: rootState.common.account }
        );
        for (let index = 0; index < indexes.length; index++) {
          const element = indexes[index].toNumber();
          var item = await marketplace.getItem.call(payload.storeId, element, {
            from: rootState.common.account
          });
          var convertedItem = {
            storeId: payload.storeId,
            storeName: item[0],
            index: item[1].toNumber(),
            name: item[2],
            sku: item[3].toNumber(),
            price: item[4].toNumber(),
            qty: 1,
            state: item[6].toNumber(),
            seller: item[7],
            buyer: item[8]
          };

          items.push(convertedItem);
        }

        commit(types.MARKETPLACE_ITEMS_TO_SHIP, items);
      } catch (err) {
        console.error(err);
        commit(
          types.UPDATE_STATUS,
          "Error getMarketplaceItemsToShipData; see log."
        );
      }
    },
    async getMarketplaceItemsToReceiveData({ commit, rootState }, payload) {
      var items = [];
      try {
        let marketplace = await Marketplace.deployed();
        var indexes = await marketplace.getItemIndexesByState.call(
          payload.storeId,
          3,
          { from: rootState.common.account }
        );
        for (let index = 0; index < indexes.length; index++) {
          const element = indexes[index].toNumber();
          var item = await marketplace.getItem.call(payload.storeId, element, {
            from: rootState.common.account
          });
          var convertedItem = {
            storeId: payload.storeId,
            storeName: item[0],
            index: item[1].toNumber(),
            name: item[2],
            sku: item[3].toNumber(),
            price: item[4].toNumber(),
            qty: 1,
            state: item[6].toNumber(),
            seller: item[7],
            buyer: item[8]
          };

          items.push(convertedItem);
          console.log(convertedItem);
        }

        // Filter the results for the buyer
        var filtered = _.filter(items, function(item) {
          return item.buyer >= payload.buyer;
        });

        commit(types.MARKETPLACE_ITEMS_TO_RECEIVE, filtered);
      } catch (err) {
        console.error(err);
        commit(
          types.UPDATE_STATUS,
          "Error getMarketplaceItemsToReceiveData; see log."
        );
      }
    }
  },
  mutations: {
    [types.MARKETPLACE_STORES](state, stores) {
      for (let index = 0; index < stores.length; index++) {
        const store = stores[index];
        Vue.set(state.stores, index, store);
      }
    },
    [types.MARKETPLACE_CURRENT_STORE](state, currentStore) {
      state.currentStore = currentStore;
    },
    [types.MARKETPLACE_ITEMS](state, items) {
      if (items.length == 0) {
        state.items.splice(0, state.items.length);
      }
      for (let index = 0; index < items.length; index++) {
        const item = items[index];
        Vue.set(state.items, index, item);
      }
    },
    [types.MARKETPLACE_ITEM_REMOVED_EVENT](state, sku) {
      for (let index = 0; index < state.items.length; index++) {
        const element = state.items[index];
        if (element.sku === sku.toNumber()) {
          state.items.splice(index, 1);
          return;
        }
      }
    },
    [types.MARKETPLACE_ITEMS_TO_SHIP](state, items) {
      state.itemsToShip.splice(0, state.itemsToShip.length);
      for (let index = 0; index < items.length; index++) {
        const item = items[index];
        Vue.set(state.itemsToShip, index, item);
      }
    },
    [types.MARKETPLACE_ITEMS_TO_RECEIVE](state, items) {
      state.itemsToReceive.splice(0, state.itemsToReceive.length);
      for (let index = 0; index < items.length; index++) {
        const item = items[index];
        Vue.set(state.itemsToReceive, index, item);
      }
    }
  },
  strict: debug,
  plugins: debug ? [createLogger()] : []
};

export default marketplace;
