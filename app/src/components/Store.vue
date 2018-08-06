<template>
  <b-card 
    :title="name" 
    :img-src="thumbnail"
    img-alt="Image" 
    img-top 
    tag="article" 
    style="max-width: 20rem;"
    class="mb-2">
    <p class="card-text">
      {{ previewText }}
    </p>
    <router-link :to="'/stores/' + id">
      <b-button variant="primary">Go!</b-button>
    </router-link>
  </b-card>
</template>


<script>
export default {
  props: {
    id: {
      type: Number,
      default: 0
    },
    thumbnail: {
      type: String,
      default: ""
    },
    name: {
      type: String,
      default: ""
    },
    previewText: {
      type: String,
      default: ""
    }
  }
};
</script>

<style scoped>
</style>
