<template>
  <section 
    id="about-page" 
    class="about-page">
    <h2>About</h2>
    <p/>
    <b-card>
      <b-media>
        <div 
          slot="aside" 
          class="LI-profile-badge"
          data-version="v1" 
          data-size="medium" 
          data-locale="en_US" 
          data-type="vertical" 
          data-theme="light" 
          data-vanity="ryansamo"><a 
            class="LI-simple-link" 
            href="https://www.linkedin.com/in/ryansamo?trk=profile-badge">Ryan Samo</a></div>
        <p>
          This dApp was written as a final project for the ConsenSysAcademy: 2018DP 2018 Developer Program. <br><br> Technologies used include...
        </p>
        <ul>
          <li>
            <b-link href="https://nodejs.org/en/">node.js</b-link>
          </li>
          <li>
            <b-link href="https://vuejs.org/">Vue.js</b-link>
          </li>
          <li>
            <b-link href="https://bootstrap-vue.js.org">BootstrapVue</b-link>
          </li>
          <li>
            <b-link href="https://truffleframework.com">Truffle Framework</b-link>
          </li>
          <li>
            <b-link href="https://truffleframework.com/ganache">Ganache</b-link>
          </li>
        </ul>
      </b-media>
    </b-card>
  </section>
</template>

<script>
export default {
  mounted() {
    let linkedInScript = document.createElement("script");
    linkedInScript.setAttribute(
      "src",
      "https://platform.linkedin.com/badges/js/profile.js"
    );
    linkedInScript.async = true;
    linkedInScript.defer = true;
    document.head.appendChild(linkedInScript);
  }
};
</script>


<style scoped>
.about-page {
  text-align: left;
}
</style>
