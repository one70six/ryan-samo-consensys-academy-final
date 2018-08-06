import createLogger from "vuex/dist/logger";
import * as types from "./mutation-types";

const debug = process.env.NODE_ENV !== "production";

const common = {
  state: {
    account: "",
    accountBalance: 0,
    status: "",
    currentBlockNumber: null
  },
  getters: {
    account: state => state.account,
    accountBalance: state =>
      Number(web3.fromWei(state.accountBalance, "ether")),
    status: state => state.status,
    currentBlockNumber: state => state.currentBlockNumber
  },
  actions: {
    // action is dispatched when account is first set
    // this is where you can put your initialization calls
    setAccount({ commit, dispatch, state }, account) {
      commit(types.UPDATE_ACCOUNT, account);
    },
    // action is dispatched when/if the account is updated
    // use this action to refresh the app with the new account's data
    updateAccount({ commit, dispatch, state }, account) {
      commit(types.UPDATE_ACCOUNT, account);
    },
    getCurrentBlockNumber({ commit }) {
      return new Promise(function(resolve, reject) {
        web3.eth.getBlockNumber(function(error, result) {
          if (error) {
            reject(error);
          } else {
            resolve(result);
          }
        });
      })
        .then(result => {
          commit(types.UPDATE_CURRENT_BLOCK_NUMBER, result);
        })
        .catch(err => {
          console.error(err);
          //alert(err)
          commit(types.UPDATE_STATUS, "Error getCurrentBlockNumber; see log.");
        });
    },
    getCurrentAccountBalance({ commit }) {
      return new Promise(function(resolve, reject) {
        web3.eth.getBalance(web3.eth.coinbase, function(error, result) {
          if (error) {
            reject(error);
          } else {
            resolve(result);
          }
        });
      })
        .then(result => {
          commit(types.UPDATE_ACCOUNT_BALANCE, result);
        })
        .catch(err => {
          console.error(err);
          //alert(err)
          commit(
            types.UPDATE_STATUS,
            "Error getCurrentAccountBalance; see log."
          );
        });
    }
  },
  mutations: {
    [types.UPDATE_ACCOUNT](state, account) {
      state.account = account;
    },
    [types.UPDATE_STATUS](state, status) {
      state.status = status;
    },
    [types.UPDATE_CURRENT_BLOCK_NUMBER](state, currentBlockNumber) {
      state.currentBlockNumber = currentBlockNumber;
    },
    [types.UPDATE_ACCOUNT_BALANCE](state, accountBalance) {
      state.accountBalance = accountBalance;
    }
  },
  strict: debug,
  plugins: debug ? [createLogger()] : []
};

export default common;
