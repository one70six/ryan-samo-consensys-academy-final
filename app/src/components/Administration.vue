<template>
  <div id="administration">

    <!-- Cannot remove self modal component -->
    <b-modal 
      id="modal-cannot-remove-self" 
      centered 
      title="Illegal Operation" 
      header-bg-variant="danger" 
      header-text-variant="light"
      ok-only>
      <p class="my-4">You cannot remove yourself.</p>
    </b-modal>

    <!-- Information alert component -->
    <b-alert 
      :show="dismissCountDown" 
      :variant="alertVariant" 
      class="alert-fixed" 
      dismissible 
      fade 
      @dismissed="dismissCountDown=0" 
      @dismiss-count-down="countDownChanged">
      {{ alertText }}
      <br> This alert will dismiss after {{ dismissCountDown }} seconds...
    </b-alert>

    <b-container fluid>
      <b-card no-body>
        <b-tabs card>
          <b-tab 
            title="Add/Remove Admins" 
            active>

            <!-- Admin Interface controls -->
            <div>
              <b-form 
                v-if="show" 
                class="addAccountForm" 
                inline 
                @submit="addAdminRow">
                <label 
                  class="sr-only" 
                  for="inlineFormInputName2">Name</label>
                <b-input 
                  id="inlineFormInputName2" 
                  v-model="form.admin_address" 
                  class="mb-2 mr-sm-2 mb-sm-0" 
                  placeholder="0xfaab7e217411ba61ce4a8776811c3fdee8687bed"
                  style="width:350px;" 
                  size="sm" 
                  required/>
                <b-button 
                  variant="primary" 
                  size="sm" 
                  type="submit">Add</b-button>
              </b-form>

              <!-- Admin table element -->
              <b-table 
                :items="admins" 
                :fields="fields" 
                :filter="filter" 
                :sort-by.sync="sortBy" 
                :sort-desc.sync="sortDesc" 
                :sort-direction="sortDirection" 
                show-empty
                stacked="md" 
                class="table" 
                size="sm">
                <template 
                  slot="actions" 
                  slot-scope="row">

                  <b-button 
                    size="sm" 
                    variant="danger" 
                    @click.stop="removeAdminRow(row)">
                    Remove
                  </b-button>
                </template>
                <template 
                  slot="row-details" 
                  slot-scope="row">
                  <b-card>
                    <ul>
                      <li 
                        v-for="(value, key) in row.item" 
                        :key="key">{{ key }}: {{ value }}</li>
                    </ul>
                  </b-card>
                </template>
              </b-table>
            </div>

          </b-tab>
          <b-tab title="Add/Remove Store Owners">

            <!-- Store Owner Interface controls -->
            <div>
              <b-form 
                v-if="show" 
                class="addAccountForm" 
                inline 
                @submit="addStoreOwnerRow">
                <label 
                  class="sr-only" 
                  for="inlineFormInputName2">Name</label>
                <b-input 
                  id="inlineFormInputName2" 
                  v-model="form.store_owner_address" 
                  class="mb-2 mr-sm-2 mb-sm-0" 
                  placeholder="0xfaab7e217411ba61ce4a8776811c3fdee8687bed"
                  style="width:350px;" 
                  size="sm" 
                  required/>
                <b-button 
                  variant="primary" 
                  size="sm" 
                  type="submit">Add</b-button>
              </b-form>
              <!-- Store Owner table element -->
              <b-table 
                :items="storeOwners" 
                :fields="fields" 
                :filter="filter" 
                :sort-by.sync="sortBy" 
                :sort-desc.sync="sortDesc" 
                :sort-direction="sortDirection" 
                show-empty
                stacked="md" 
                class="table" 
                size="sm">
                <template 
                  slot="actions" 
                  slot-scope="row">

                  <b-button 
                    size="sm" 
                    variant="danger" 
                    @click.stop="removeStoreOwnerRow(row)">
                    Remove
                  </b-button>
                </template>
                <template 
                  slot="row-details" 
                  slot-scope="row">
                  <b-card>
                    <ul>
                      <li 
                        v-for="(value, key) in row.item" 
                        :key="key">{{ key }}: {{ value }}</li>
                    </ul>
                  </b-card>
                </template>
              </b-table>
            </div>

          </b-tab>
          <!-- Emergency Stop Interface controls -->
          <b-tab title="Emergency Stop">
            <b-form 
              v-if="show" 
              class="emergencyStopForm" 
              inline 
              @submit="emergencyStop">
              <p>To stop the Marketplace contract indefinitely, press the button below.</p>
              <br>
              <b-button 
                size="lg" 
                variant="danger" 
                type="submit">Emergency Stop</b-button>
            </b-form>
          </b-tab>

        </b-tabs>
      </b-card>

    </b-container>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import { Authentication } from "../contracts";
import { Marketplace } from "../contracts";
import * as types from "../store/mutation-types";

var items = [];
export default {
  name: "Administration",
  data() {
    return {
      form: {
        admin_address: "",
        store_owner_address: ""
      },
      show: true,
      items: items,
      fields: [
        {
          key: "address",
          label: "Address",
          sortable: true,
          sortDirection: "desc"
        },
        { key: "actions", label: "Actions" }
      ],
      sortBy: null,
      sortDesc: false,
      sortDirection: "asc",
      filter: null,
      alertVariant: "",
      alertText: "",
      dismissSecs: 5,
      dismissCountDown: 0
    };
  },
  computed: {
    ...mapGetters([
      "account",
      "admins",
      "storeOwners",
      "isCurrentAdmin",
      "currentBlockNumber"
    ]),
    sortOptions() {
      // Create an options list from our fields
      return this.fields.filter(f => f.sortable).map(f => {
        return { text: f.label, value: f.key };
      });
    }
  },
  async mounted() {
    await this.$store.dispatch("getAuthenticationAdminArrayData");
    await this.$store.dispatch("getAuthenticationStoreOwnerArrayData");
    await this.$store.dispatch("getCurrentBlockNumber");

    Authentication.deployed().then(instance => {
      const adminAdded = instance.AdminAdded({
        fromBlock: this.currentBlockNumber,
        toBlock: "latest"
      });
      const storeOwnerAdded = instance.StoreOwnerAdded({
        fromBlock: this.currentBlockNumber,
        toBlock: "latest"
      });
      const adminRemoved = instance.AdminRemoved({
        fromBlock: this.currentBlockNumber,
        toBlock: "latest"
      });
      const storeOwnerRemoved = instance.StoreOwnerRemoved({
        fromBlock: this.currentBlockNumber,
        toBlock: "latest"
      });

      adminAdded.watch((error, result) => {
        if (error !== null) {
          this.$store.commit(types.UPDATE_STATUS, "Error watching events!");
          return;
        }

        // Call store to update the admin array from the blockchain
        this.$store.dispatch("getAuthenticationAdminArrayData");

        this.$store.dispatch("getCurrentBlockNumber");

        // Alert the user
        this.alertVariant = "success";
        this.alertText = "Admin added!";
        this.showAlert();
      });

      storeOwnerAdded.watch((error, result) => {
        // console.log(result)
        if (error !== null) {
          this.$store.commit(types.UPDATE_STATUS, "Error watching events!");
          return;
        }

        // Call store to update the admin array from the blockchain
        this.$store.dispatch("getAuthenticationStoreOwnerArrayData");
        this.$store.dispatch("getCurrentBlockNumber");

        // Alert the user
        this.alertVariant = "success";
        this.alertText = "Store Owner added!";
        this.showAlert();
      });

      adminRemoved.watch((error, result) => {
        if (error !== null) {
          this.$store.commit(types.UPDATE_STATUS, "Error watching events!");
          return;
        }

        // Call the store to update the state via mutation
        this.$store.commit(
          types.AUTHENTICATION_ADMIN_REMOVED_EVENT,
          result.args.admin
        );

        this.$store.dispatch("getCurrentBlockNumber");

        // Alert the user
        this.alertVariant = "success";
        this.alertText = "Admin removed!";
        this.showAlert();
      });

      storeOwnerRemoved.watch((error, result) => {
        if (error !== null) {
          this.$store.commit(types.UPDATE_STATUS, "Error watching events!");
          return;
        }

        // Call the store to update the state via mutation
        console.log(result.args.account);
        this.$store.commit(
          types.AUTHENTICATION_STORE_OWNER_REMOVED_EVENT,
          result.args.account
        );

        this.$store.dispatch("getCurrentBlockNumber");

        // Alert the user
        this.alertVariant = "success";
        this.alertText = "Store Owner removed!";
        this.showAlert();
      });
    });
  },
  methods: {
    addStoreOwnerRow: async function(evt) {
      evt.preventDefault();

      let authentication = await Authentication.deployed();
      await authentication.addStoreOwner(this.form.store_owner_address, {
        from: this.account,
        gas: 300000
      });

      // Alert the user
      this.alertVariant = "primary";
      this.alertText = "Adding account to blockchain...";
      this.showAlert();

      // Clear the form
      this.form.store_owner_address = "";

      /* Trick to reset/clear native browser form validation state */
      this.show = false;
      this.$nextTick(() => {
        this.show = true;
      });
    },
    removeStoreOwnerRow: async function(row) {
      if (row.item.address === this.account) {
        this.$root.$emit("bv::show::modal", "modal-cannot-remove-self");
        return;
      }

      // Call the blockchain
      let authentication = await Authentication.deployed();
      await authentication.removeStoreOwner(row.item.address, {
        from: this.account,
        gas: 300000
      });

      // Alert the user
      this.alertVariant = "primary";
      this.alertText = "Removing Store Owner...";
      this.showAlert();
    },
    addAdminRow: async function(evt) {
      evt.preventDefault();

      let authentication = await Authentication.deployed();
      await authentication.addAdmin(this.form.admin_address, {
        from: this.account,
        gas: 300000
      });

      // Alert the user
      this.alertVariant = "primary";
      this.alertText = "Adding account to blockchain...";
      this.showAlert();

      // Clear the form
      this.form.admin_address = "";

      /* Trick to reset/clear native browser form validation state */
      this.show = false;
      this.$nextTick(() => {
        this.show = true;
      });
    },
    removeAdminRow: async function(row) {
      if (row.item.address === this.account) {
        this.$root.$emit("bv::show::modal", "modal-cannot-remove-self");
        return;
      }

      // Call the blockchain
      let authentication = await Authentication.deployed();
      await authentication.removeAdmin(row.item.address, {
        from: this.account,
        gas: 300000
      });

      // Alert the user
      this.alertVariant = "primary";
      this.alertText = "Removing Admin...";
      this.showAlert();
    },
    emergencyStop: async function() {
      // evt.preventDefault();

      let marketPlace = await Marketplace.deployed();
      await marketPlace.emergencyStop({
        from: this.account,
        gas: 300000
      });

      // Alert the user
      this.alertVariant = "dark";
      this.alertText = "Marketplace contract stopped!";
      this.showAlert();
    },
    countDownChanged: function(dismissCountDown) {
      this.dismissCountDown = dismissCountDown;
    },
    showAlert: function() {
      this.dismissCountDown = this.dismissSecs;
    }
  }
};
</script>

<style scoped>
.table {
  box-shadow: 0 2px 2px #aaa;
}

.addAccountForm {
  padding-bottom: 8px;
}

.emergencyStopForm {
  display: flex;
  flex-flow: column;
  justify-content: center;
  align-items: center;
}

.alert-fixed {
  position: fixed;
  top: 0px;
  left: 0px;
  width: 100%;
  height: 3.5rem;
  z-index: 9999;
  border-radius: 0px;
  margin-top: 3.5rem;
}
</style>
