<template>
  <table class="info-table">
    <tr>
      <td><b>{{ accountLabel }}: </b></td>
      <td>{{ account }}</td>
    </tr>
    <tr>
      <td><b>Balance: </b></td>
      <td>{{ accountBalance }} Ξ</td>
    </tr>
    <tr>
      <td><b>Block #: </b></td>
      <td>{{ currentBlockNumber }}</td>
    </tr>
  </table>
</template>

<script>
export default {
  name: "HeaderInfo",
  props: {
    accountLabel: {
      type: String,
      default: ""
    },
    account: {
      type: String,
      default: ""
    },
    accountBalance: {
      type: Number,
      default: 0
    },
    currentBlockNumber: {
      type: Number,
      default: 0
    }
  }
};
</script>

<style scoped>
.info-table {
  text-align: left;
}

.info-table b {
  color: #06c4d1;
}
</style>
