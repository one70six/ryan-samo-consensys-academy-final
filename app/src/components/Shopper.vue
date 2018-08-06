<template>
  <div 
    id="shopper" 
    class="work-area">
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

      <b-row 
        v-for="stores in groupedStores" 
        :key="stores.id">
        <b-col 
          v-for="store in stores" 
          :key="store.id" 
          cols="4">
          <Store 
            :key="store.id"
            :id="store.id"  
            :name="store.name"
            :preview-text="store.text"
            :thumbnail="randomImage()" />
        </b-col>
      </b-row>

    </b-container>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import _ from "underscore";
import Store from "./Store";

export default {
  name: "Shopper",
  components: {
    Store
  },
  data() {
    return {
      errorMessage: ""
    };
  },
  computed: {
    ...mapGetters(["account", "currentBlockNumber", "stores"]),
    groupedStores() {
      return _.chunk(this.stores, 3);
    }
  },
  async mounted() {
    // Get the stores
    await this.$store.dispatch("getMarketplaceStoreArrayData");

    // Get the current block number
    await this.$store.dispatch("getCurrentBlockNumber");
  },
  methods: {
    randomImage() {
      return (
        "https://picsum.photos/600/300/?random&dummyParam=" + Math.random() + ""
      );
    }
  }
};
</script>

<style scoped>
.work-area {
  display: block;
  width: 100%;
  padding: 8px;
}
</style>
