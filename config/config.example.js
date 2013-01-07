(function() {
  module.exports = {
    development: {
      db: "mongodb://localhost/gitfly",
      github: {
        clientID: "APP_ID",
        clientSecret: "APP_SECRET",
        callbackURL: "http://localhost:3000/auth/github/callback"
      },
      smtp: {
        service: "Gmail",
        auth: {
          user: "username",
          pass: "password"
        }
      }
    },
    test: {},
    production: {}
  };
}).call(this);
