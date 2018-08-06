<template>
  <section class="single-store">

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

    <!-- Purchase modal -->
    <b-modal 
      id="modal-purchase" 
      ref="modal" 
      ok-variant="success" 
      ok-title="Purchase" 
      centered 
      title="Purchase" 
      header-bg-variant="primary"
      header-text-variant="light" 
      @ok="handleOk">
      <div>
        <!-- Item form element -->
        <b-form @submit.stop.prevent="handleSubmit">
          <b-form-group 
            id="exampleInputGroup1" 
            label="SKU:" 
            label-for="exampleInput1" 
            size="sm" 
            horizontal>
            <b-form-input 
              id="exampleInput1" 
              v-model="form.item_sku" 
              disabled 
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
              disabled 
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
              disabled 
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
        </b-form>
      </div>
    </b-modal>

    <b-jumbotron 
      bg-variant="info" 
      text-variant="white" 
      border-variant="dark">
      <template slot="header">
        {{ currentStore.name }}
      </template>
    </b-jumbotron>

    <b-card no-body>
      <b-tabs 
        card 
        @input="onTabChange">
        <b-tab 
          title="Shop" 
          active>
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
                  variant="success" 
                  @click.stop="buyItem(row)">Purchase</b-button>

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
        <b-tab title="Receive">
          <div>
            <!-- Item table element -->
            <b-table 
              :items="itemsToReceive" 
              :fields="item_receive_fields" 
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
                  @click.stop="receiveItem(row)">Receive</b-button>

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

  </section>
</template>

<script>
import { mapGetters } from "vuex";
import { Marketplace } from "../../contracts";
import * as types from "../../store/mutation-types";

export default {
  name: "Store",
  data() {
    return {
      authenticationCheckInterval: null,
      form: {
        item_store_id: null,
        item_sku: null,
        item_name: null,
        item_price: null,
        item_qty: null
      },
      row: null,
      show: true,
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
          label: "In Stock",
          sortable: true,
          sortDirection: "desc"
        },
        {
          key: "actions",
          label: "Actions"
        }
      ],
      item_receive_fields: [
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
      "isCurrentAdmin",
      "isCurrentStoreOwner",
      "currentBlockNumber",
      "currentStore",
      "items",
      "itemsToReceive"
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
  async beforeCreate() {
    // Get the current store data
    await this.$store.dispatch("getMarketplaceStoreData", {
      storeId: this.$route.params.id
    });

    // Get For Sale items
    await this.$store.dispatch("getMarketplaceItemsForSaleData", {
      storeId: this.$route.params.id
    });
  },
  async mounted() {
    // Poll for user change
    this.authenticationCheckInterval = setInterval(() => {
      this.$store.dispatch("getAuthenticationContractData");
      if (this.isCurrentAdmin || this.isCurrentStoreOwner) {
        this.$router.push({ path: "/" });
      }
    }, 1000);

    Marketplace.deployed().then(instance => {
      const itemSold = instance.ItemSold({
        fromBlock: this.currentBlockNumber,
        toBlock: "latest"
      });
      const itemReceived = instance.ItemReceived({
        fromBlock: this.currentBlockNumber,
        toBlock: "latest"
      });

      itemSold.watch((error, result) => {
        if (error !== null) {
          this.$store.commit(types.UPDATE_STATUS, "Error watching events!");
          return;
        }

        // Call store to update the store array from the blockchain
        // Get For Sale items
        this.$store.dispatch("getMarketplaceItemsForSaleData", {
          storeId: this.$route.params.id
        });

        // Alert the user
        this.alertVariant = "success";
        this.alertText = "Item sold!";
        this.showAlert();
      }),
        itemReceived.watch((error, result) => {
          if (error !== null) {
            this.$store.commit(types.UPDATE_STATUS, "Error watching events!");
            return;
          }

          // Call store to update the store array from the blockchain
          // Get Shipped items
          this.$store.dispatch("getMarketplaceItemsToReceiveData", {
            storeId: this.$route.params.id,
            buyer: this.account
          });

          // Alert the user
          this.alertVariant = "success";
          this.alertText = "Item received!";
          this.showAlert();
        });
    });
  },
  beforeDestroy() {
    clearInterval(this.authenticationCheckInterval);
  },
  methods: {
    buyItem(row) {
      this.row = row;
      this.form.item_store_id = Number(this.$route.params.id);
      this.form.item_sku = row.item.sku;
      this.form.item_name = row.item.name;
      this.form.item_price = row.item.price;
      this.form.item_qty = 1;
      this.$root.$emit("bv::show::modal", "modal-purchase");
    },
    handleOk(evt) {
      evt.preventDefault();
      if (this.form.item_qty <= 0 || this.form.item_qty > this.row.item.qty) {
        this.errorMessage =
          "Please specify a valid quantity before continuing.";
        this.$root.$emit("bv::show::modal", "modal-error");
      } else {
        this.handleSubmit();
      }
    },
    async handleSubmit() {
      try {
        let marketplace = await Marketplace.deployed();
        await marketplace.buyItem(
          this.form.item_store_id,
          this.form.item_sku,
          this.form.item_qty,
          {
            from: this.account,
            value: this.form.item_price * this.form.item_qty,
            gas: 3000000
          }
        );
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

      this.$refs.modal.hide();

      // Alert the user
      this.alertVariant = "primary";
      this.alertText = "Purchasing item...";
      this.showAlert();
    },
    receiveItem: async function(row) {
      try {
        let marketplace = await Marketplace.deployed();
        await marketplace.receiveItem(
          row.item.storeId,
          row.item.sku,
          row.item.qty,
          {
            from: this.account,
            gas: 3000000
          }
        );
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

      // Alert the user
      this.alertVariant = "primary";
      this.alertText = "Receiving item...";
      this.showAlert();
    },
    async onTabChange(tab_index) {
      if (tab_index == 0) {
        // Get the current store data
        await this.$store.dispatch("getMarketplaceStoreData", {
          storeId: this.$route.params.id
        });
      } else if (tab_index == 1) {
        // Get Shipped items
        await this.$store.dispatch("getMarketplaceItemsToReceiveData", {
          storeId: this.$route.params.id,
          buyer: this.account
        });
      }
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
.single-store {
  display: flex;
  flex-flow: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  padding: 30px;
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
