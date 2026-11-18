<template>
  <div class="vh-100 d-flex bg-warning justify-content-center align-items-center">
    <div class="row p-0 container shadow-sm" id="loginContainer">
      <div class="col-6 text-light left d-none d-md-block">
        <div class="d-flex h-100 justify-content-center align-items-center">
          <div class="text-center p-4">
            <h1 class="display-4 text-warning">HR Software</h1>
            <h5 class="text-white font-weight-light">Vos équipes, simplement.</h5>
          </div>
        </div>
      </div>
      <div class="col-12 col-md-6 bg-white text-dark p-5">
        <h1 class="display-4 font-weight-normal mb-5 text-center text-md-left">Login</h1>
        <form
          autocomplete="off"
          @submit.prevent="submit()"
          @keydown="
            form.errors.clear($event.target.name);
            disabledSubmitButton = false;
          "
        >
          <div class="form-group">
            <label for="email">Email Address</label>
            <input
              type="text"
              name="email"
              class="form-control form-control-lg rounded-0 bg-light"
              :class="{ 'is-invalid': form.errors.has('email') }"
              placeholder="johndoe@example.com"
              v-model="form.email"
            />
            <small
              class="text-danger my-0"
              v-if="form.errors.has('email')"
            >{{ form.errors.get("email") }}</small>
          </div>
          <div class="form-group">
            <label for="password">Password</label>
            <input
              type="password"
              name="password"
              class="form-control form-control-lg rounded-0 bg-light"
              :class="{ 'is-invalid': form.errors.has('password') }"
              v-model="form.password"
            />
            <small
              class="text-danger my-0"
              v-if="form.errors.has('password')"
            >{{ form.errors.get("password") }}</small>
          </div>
          <div class="demo-accounts mb-3">
            <p class="small text-uppercase text-muted font-weight-bold mb-2">Demo accounts</p>
            <button
              v-for="account in demoAccounts"
              :key="account.email"
              type="button"
              class="btn btn-sm btn-outline-dark rounded-pill mr-1 mb-2"
              @click="useDemoAccount(account)"
            >
              {{ account.label }}
            </button>
            <p class="small text-muted mb-0">All demo accounts use password <strong>password</strong>.</p>
          </div>
          <a href="#" class="d-block text-right small text-muted mb-1 comfortaa">Forget Password?</a>
          <button
            class="btn btn-block btn-lg btn-dark rounded-0"
            :disabled="form.errors.any() || this.disabledSubmitButton"
          >Submit</button>
          <p
            class="alert alert-danger mt-2 mb-0 text-center text-md-left"
            v-if="invalidCredentialsError"
          >The provided credentials are incorrect.</p>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import Form from "../core/Form";
import { mapActions } from "vuex";
export default {
  data() {
    return {
      form: new Form({
        email: "manager@example.com",
        password: "password",
      }),
      demoAccounts: [
        { label: "Admin / Manager", email: "manager@example.com" },
        { label: "Human Resources", email: "rh@example.com" },
        { label: "Project Manager", email: "projectmanager@example.com" },
        { label: "Employee", email: "employee@example.com" },
      ],
      invalidCredentialsError: false,
      disabledSubmitButton: false,
    };
  },
  methods: {
    ...mapActions({
      attempt: "auth/attempt",
    }),
    useDemoAccount(account) {
      this.form.email = account.email;
      this.form.password = "password";
      this.invalidCredentialsError = false;
      this.disabledSubmitButton = false;
      this.form.errors.clear("email");
      this.form.errors.clear("password");
    },
    submit() {
      this.invalidCredentialsError = false;
      this.form.post("/auth/login").then(response => {
        this.attempt(response.data.access_token).then(response => {
            let user = response.data.data;
            if(user.permissions.includes('view collaborators')) this.$router.replace({ name: "dashboard" });
            else this.$router.replace({ name: "profile", params: { id: user.id } });
          }).catch((error) => {
            console.log(error);
          });
        })
        .catch((error) => {
          if (error.status === 401) {
            this.invalidCredentialsError = true;
            this.disabledSubmitButton = true;
            return;
          }
        });
    },
  },
};
</script>

<style>
.left {
  background-image: linear-gradient(rgba(0, 0, 0, 0.9) 0 100%),
    url("../assets/images/1.jpg");
  background-position: center;
  background-size: cover;
}
input.form-control-lg {
  font-size: 14pt;
}
.demo-accounts {
  border: 1px solid #eee;
  background: #fafafa;
  padding: 1rem;
}
#loginContainer {
  max-width: 850px;
}
@media screen and (max-width: 767px) {
  #loginContainer {
    max-width: 450px;
  }
}
</style>
