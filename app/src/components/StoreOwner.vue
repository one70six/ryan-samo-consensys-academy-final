<template>
  <div id="store-owner">
    <b-container fluid>

      <!-- Error modal -->
      <b-modal 
        id="modal-error" 
        centered 
        title="Illegal Operation" 
        header-bg-variant="danger" 
        header-text-variant="light"
        ok-only>
        <p class="my-4">{{ errorMessage }}</p>
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

      <b-card no-body>
        <b-tabs 
          card 
          @input="onTabChange">
          <b-tab 
            title="Open/Close Stores" 
            active>

            <div>
              <!-- Store form element -->
              <b-form 
                v-if="show" 
                class="addForm" 
                inline 
                @submit="openStore">
                <label 
                  class="sr-only" 
                  for="inlineFormInputName2">Name</label>
                <b-input 
                  id="inlineFormInputName2" 
                  v-model="form.store_name" 
                  class="mb-2 mr-sm-2 mb-sm-0" 
                  placeholder="Fleabay" 
                  style="width:350px;"
                  size="sm" 
                  required/>
                <b-button 
                  variant="primary" 
                  size="sm" 
                  type="submit">Open New</b-button>
              </b-form>

              <!-- Store table element -->
              <b-table 
                :items="stores" 
                :fields="store_fields" 
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
                    v-if="row.item.state==1" 
                    size="sm" 
                    variant="danger" 
                    @click.stop="closeStore(row)">Close</b-button>
                  <b-button 
                    v-else-if="row.item.state==2" 
                    size="sm" 
                    variant="success" 
                    @click.stop="reOpenStore(row)">Open</b-button>

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
          <b-tab title="Add/Remove Items">

            <div class="addForm">

              <!-- Item form element -->
              <b-form 
                v-if="show" 
                @submit="addItem" 
                @reset="onReset">
                <b-form-group 
                  id="exampleInputGroup0" 
                  label="Store:" 
                  label-for="exampleInput0" 
                  size="sm" 
                  horizontal>
                  <b-form-select 
                    id="exampleInput0" 
                    :options="stores" 
                    v-model="form.item_store_id" 
                    required 
                    @change="onStoreChange"/>
                </b-form-group>
                <b-form-group 
                  id="exampleInputGroup1" 
                  label="SKU:" 
                  label-for="exampleInput1" 
                  size="sm" 
                  horizontal>
                  <b-form-input 
                    id="exampleInput1" 
                    v-model="form.item_sku" 
                    type="number" 
                    required 
                    placeholder="Enter SKU"/>
                </b-form-group>
                <b-form-group 
                  id="exampleInputGroup2" 
                  label="Name:" 
                  label-for="exampleInput2" 
                  size="sm" 
                  horizontal>
                  <b-form-input 
                    id="exampleInput2" 
                    v-model="form.item_name" 
                    type="text" 
                    required 
                    placeholder="Enter name"/>
                </b-form-group>
                <b-form-group 
                  id="exampleInputGroup3" 
                  label="Price (wei):" 
                  label-for="exampleInput3" 
                  size="sm" 
                  horizontal>
                  <b-form-input 
                    id="exampleInput3" 
                    v-model="form.item_price" 
                    type="number" 
                    required 
                    placeholder="Enter price"/>
                </b-form-group>
                <b-form-group 
                  id="exampleInputGroup4" 
                  label="Qty:" 
                  label-for="exampleInput4" 
                  size="sm" 
                  horizontal>
                  <b-form-input 
                    id="exampleInput4" 
                    v-model="form.item_qty" 
                    type="number" 
                    required 
                    placeholder="Enter qty"/>
                </b-form-group>
                <div style="text-align:right">
                  <b-button 
                    type="submit" 
                    variant="primary">Add</b-button>
                  <b-button 
                    type="reset" 
                    variant="danger">Reset</b-button>
                </div>
              </b-form>

            </div>
            <div>
              <!-- Item table element -->
              <b-table 
                :items="items" 
                :fields="item_fields" 
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
                    @click.stop="removeItem(row)">Remove</b-button>

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
          <b-tab title="Ship Items">

            <b-form>
              <b-form-group 
                id="exampleInputGroup10" 
                label="Store:" 
                label-for="exampleInput10" 
                size="sm" 
                horizontal>
                <b-form-select 
                  id="exampleInput10" 
                  :options="stores" 
                  v-model="form.item_store_id" 
                  required 
                  @change="onStoreChangeItemsToShip"/>
              </b-form-group>
            </b-form>
            <div>
              <!-- Ship Item table element -->
              <b-table 
                :items="itemsToShip" 
                :fields="items_to_ship_fields" 
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
                    variant="success" 
                    @click.stop="shipItem(row)">Ship</b-button>

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
        </b-tabs>
      </b-card>
    </b-container>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import { Marketplace } from "../contracts";
import * as types from "../store/mutation-types";

export default {
  name: "StoreOwner",
  data() {
    return {
      form: {
        store_name: "",
        item_store_id: 0,
        item_sku: null,
        item_name: null,
        item_price: null,
        item_qty: null
      },
      show: true,
      store_fields: [
        {
          key: "name",
          label: "Store Name",
          sortable: true,
          sortDirection: "desc"
        },
        {
          key: "actions",
          label: "Actions"
        }
      ],
      item_fields: [
        {
          key: "sku",
          label: "SKU",
          sortable: true,
          sortDirection: "desc"
        },
        {
          key: "name",
          label: "Name",
          sortable: true,
          sortDirection: "desc"
        },
        {
          key: "price",
          label: "Price (wei)",
          sortable: true,
          sortDirection: "desc"
        },
        {
          key: "qty",
          label: "Qty",
          sortable: true,
          sortDirection: "desc"
        },
        {
          key: "actions",
          label: "Actions"
        }
      ],
      items_to_ship_fields: [
        {
          key: "sku",
          label: "SKU",
          sortable: true,
          sortDirection: "desc"
        },
        {
          key: "name",
          label: "Name",
          sortable: true,
          sortDirection: "desc"
        },
        {
          key: "qty",
          label: "Qty",
          sortable: true,
          sortDirection: "desc"
        },
        {
          key: "buyer",
          label: "Buyer",
          sortable: true,
          sortDirection: "desc"
        },
        {
          key: "actions",
          label: "Actions"
        }
      ],
      sortBy: null,
      sortDesc: false,
      sortDirection: "asc",
      filter: null,
      alertVariant: "",
      alertText: "",
      dismissSecs: 5,
      dismissCountDown: 0,
      selected: null,
      errorMessage: ""
    };
  },
  computed: {
    ...mapGetters([
      "account",
      "currentBlockNumber",
      "stores",
      "items",
      "itemsToShip"
    ]),
    sortOptions() {
      // Create an options list from our fields
      return this.fields.filter(f => f.sortable).map(f => {
        return {
          text: f.label,
          value: f.key
        };
      });
    }
  },
  async mounted() {
    await this.$store.dispatch("getCurrentBlockNumber");

    Marketplace.deployed().then(instance => {
      const storeOpened = instance.StoreOpened({
        fromBlock: this.currentBlockNumber,
        toBlock: "latest"
      });
      const storeClosed = instance.StoreClosed({
        fromBlock: this.currentBlockNumber,
        toBlock: "latest"
      });
      const itemForSale = instance.ItemForSale({
        fromBlock: this.currentBlockNumber,
        toBlock: "latest"
      });
      const itemNotForSale = instance.ItemNotForSale({
        fromBlock: this.currentBlockNumber,
        toBlock: "latest"
      });
      const itemSold = instance.ItemSold({
        fromBlock: this.currentBlockNumber,
        toBlock: "latest"
      });
      const itemShipped = instance.ItemShipped({
        fromBlock: this.currentBlockNumber,
        toBlock: "latest"
      });

      storeOpened.watch((error, result) => {
        if (error !== null) {
          this.$store.commit(types.UPDATE_STATUS, "Error watching events!");
          return;
        }

        // Call store to update the store array from the blockchain
        this.$store.dispatch("getMarketplaceStoreArrayData");

        this.$store.dispatch("getCurrentBlockNumber");

        // Alert the user
        this.alertVariant = "success";
        this.alertText = "Store opened!";
        this.showAlert();
      }),
        storeClosed.watch((error, result) => {
          if (error !== null) {
            this.$store.commit(types.UPDATE_STATUS, "Error watching events!");
            return;
          }

          // Call store to update the store array from the blockchain
          this.$store.dispatch("getMarketplaceStoreArrayData");

          this.$store.dispatch("getCurrentBlockNumber");

          // Alert the user
          this.alertVariant = "success";
          this.alertText = "Store closed!";
          this.showAlert();
        }),
        itemForSale.watch((error, result) => {
          if (error !== null) {
            this.$store.commit(types.UPDATE_STATUS, "Error watching events!");
            return;
          }

          // Call store to update the item array from the blockchain
          this.$store.dispatch("getMarketplaceItemsForSaleData", {
            storeId: result.args._storeId.toNumber()
          });

          this.$store.dispatch("getCurrentBlockNumber");

          // Alert the user
          this.alertVariant = "success";
          this.alertText = "Item added!";
          this.showAlert();
        }),
        itemNotForSale.watch((error, result) => {
          if (error !== null) {
            this.$store.commit(types.UPDATE_STATUS, "Error watching events!");
            return;
          }

          // Call the store to update the state via mutation
          this.$store.commit(
            types.MARKETPLACE_ITEM_REMOVED_EVENT,
            result.args._sku
          );

          // this.$store.dispatch('getCurrentBlockNumber')

          // Alert the user
          this.alertVariant = "success";
          this.alertText = "Item removed!";
          this.showAlert();
        }),
        itemSold.watch((error, result) => {
          if (error !== null) {
            this.$store.commit(types.UPDATE_STATUS, "Error watching events!");
            return;
          }

          // Call store to update the store array from the blockchain
          // For sale and sold
          this.$store.dispatch("getMarketplaceItemsForSaleData", {
            storeId: result.args._storeId.toNumber()
          });

          // this.$store.dispatch('getCurrentBlockNumber')

          // Alert the user
          this.alertVariant = "success";
          this.alertText = "Item sold!";
          this.showAlert();
        }),
        itemShipped.watch((error, result) => {
          if (error !== null) {
            this.$store.commit(types.UPDATE_STATUS, "Error watching events!");
            return;
          }

          this.$store.dispatch("getMarketplaceItemsToShipData", {
            storeId: result.args._storeId.toNumber()
          });

          // Alert the user
          this.alertVariant = "success";
          this.alertText = "Item shipped!";
          this.showAlert();
        });
    });
  },
  methods: {
    openStore: async function(evt) {
      evt.preventDefault();

      let marketplace = await Marketplace.deployed();
      await marketplace.openStore(this.form.store_name, {
        from: this.account,
        gas: 300000
      });

      // Alert the user
      this.alertVariant = "primary";
      this.alertText = "Opening new store...";
      this.showAlert();

      // Clear the form
      this.form.store_name = "";

      /* Trick to reset/clear native browser form validation state */
      this.show = false;
      this.$nextTick(() => {
        this.show = true;
      });
    },
    reOpenStore: async function(row) {
      // evt.preventDefault();

      let marketplace = await Marketplace.deployed();
      await marketplace.reopenStore(row.item.id, {
        from: this.account,
        gas: 300000
      });

      // Alert the user
      this.alertVariant = "primary";
      this.alertText = "Opening store...";
      this.showAlert();

      /* Trick to reset/clear native browser form validation state */
      this.show = false;
      this.$nextTick(() => {
        this.show = true;
      });
    },
    closeStore: async function(row) {
      // console.log(row)

      // Call the blockchain
      let marketplace = await Marketplace.deployed();
      await marketplace.closeStore(row.item.id, {
        from: this.account,
        gas: 300000
      });

      // Alert the user
      this.alertVariant = "primary";
      this.alertText = "Closing Store ...";
      this.showAlert();
    },
    addItem: async function(evt) {
      evt.preventDefault();

      try {
        let marketplace = await Marketplace.deployed();
        await marketplace.addItem(
          this.form.item_store_id,
          this.form.item_sku,
          this.form.item_name,
          this.form.item_price,
          this.form.item_qty,
          {
            from: this.account,
            gas: 3000000
          }
        );

        // Alert the user
        this.alertVariant = "primary";
        this.alertText = "Adding new item...";
        this.showAlert();

        /* Trick to reset/clear native browser form validation state */
        this.show = false;
        this.$nextTick(() => {
          this.show = true;
        });
      } catch (err) {
        if (err.message.includes("out of gas")) {
          this.errorMessage =
            "Transaction out of gas. Please try a smaller transaction.";
          this.$root.$emit("bv::show::modal", "modal-error");
        } else {
          this.errorMessage = err.message;
          this.$root.$emit("bv::show::modal", "modal-error");
        }
      }
    },
    removeItem: async function(row) {
      // console.log(row)

      // Call the blockchain
      let marketplace = await Marketplace.deployed();
      await marketplace.removeItem(
        row.item.storeId,
        row.item.sku,
        row.item.qty,
        {
          from: this.account,
          gas: 300000
        }
      );

      // Alert the user
      this.alertVariant = "primary";
      this.alertText = "Removing item ...";
      this.showAlert();
    },
    shipItem: async function(row) {
      try {
        let marketplace = await Marketplace.deployed();
        await marketplace.shipItem(
          row.item.storeId,
          row.item.sku,
          row.item.qty,
          row.item.buyer,
          {
            from: this.account,
            gas: 3000000
          }
        );

        // Alert the user
        this.alertVariant = "primary";
        this.alertText = "Shipping item...";
        this.showAlert();
      } catch (err) {
        if (err.message.includes("out of gas")) {
          this.errorMessage =
            "Transaction out of gas. Please try a smaller transaction.";
          this.$root.$emit("bv::show::modal", "modal-error");
        } else {
          this.errorMessage = err.message;
          this.$root.$emit("bv::show::modal", "modal-error");
        }
      }
    },
    countDownChanged: function(dismissCountDown) {
      this.dismissCountDown = dismissCountDown;
    },
    showAlert: function() {
      this.dismissCountDown = this.dismissSecs;
    },
    onReset(evt) {
      evt.preventDefault();
      /* Reset our form values */
      this.form.item_sku = 0;
      this.form.item_name = "";
      this.form.item_price = 0;
      this.form.item_qty = 0;
      /* Trick to reset/clear native browser form validation state */
      this.show = false;
      this.$nextTick(() => {
        this.show = true;
      });
    },
    async onStoreChange(value) {
      // Get For Sale items
      await this.$store.dispatch("getMarketplaceItemsForSaleData", {
        storeId: value
      });
    },
    async onStoreChangeItemsToShip(value) {
      // Get For Sale items
      await this.$store.dispatch("getMarketplaceItemsToShipData", {
        storeId: value
      });
    },
    async onTabChange(tabIndex) {
      if (tabIndex == 0) {
        // Get the stores
        await this.$store.dispatch("getMarketplaceStoreArrayData");
      } else if (tabIndex == 1) {
        // Get For Sale items
        await this.$store.dispatch("getMarketplaceItemsForSaleData", {
          storeId: this.form.item_store_id
        });
      } else if (tabIndex == 2) {
        await this.$store.dispatch("getMarketplaceItemsToShipData", {
          storeId: this.form.item_store_id
        });
      }
    }
  }
};
</script>

<style scoped>
.table {
  box-shadow: 0 2px 2px #aaa;
}

.addForm {
  padding-bottom: 8px;
}

.addForm h6 {
  text-align: left;
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
