import Vue from "vue";
import Router from "vue-router";
import Main from "@/components/Main";
import Stores from "@/pages/stores";
import About from "@/pages/about";

Vue.use(Router);

export default new Router({
  routes: [
    {
      path: "/",
      name: "Main",
      component: Main
    },
    {
      path: "/about",
      name: "About",
      component: About
    },
    {
      path: "/stores/:id",
      name: "Stores",
      component: Stores
    }
  ]
});
