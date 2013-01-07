(function() {
  var Org, Repository, User, async, mongoose;
  mongoose = require('mongoose');
  User = mongoose.model('User');
  Org = mongoose.model('Org');
  Repository = mongoose.model('Repository');
  async = require('async');
  module.exports = function(app, passport, auth) {
    var orgs, repos, users;
    users = require("../app/controllers/users");
    orgs = require("../app/controllers/orgs");
    repos = require("../app/controllers/repos");
    app.get("/users/:username/orgs", users.orgs);
    app.get("/users/:username", users.show);
    app.post("/users/:username", users.update);
    app.get("/logout", users.logout);
    app.get("/users/:username/orgs/:orgId", orgs.show);
    app.post("/users/:username/orgs/:orgId", orgs.update);
    app.post("/users/:username/orgs/:orgId/sync", orgs.sync);
    app["delete"]("/users/:username/orgs/:orgId/repositories/:repoName", repos["delete"]);
    app.get("/auth/github", passport.authenticate("github", {
      failureRedirect: "/login"
    }), users.signin);
    app.get("/auth/github/callback", passport.authenticate("github", {
      failureRedirect: "/login"
    }), users.authCallback);
    app.param("repoName", function(req, res, next, name) {
      return Repository.findOne({
        name: name
      }).exec(function(err, repo) {
        if (err) {
          return next(err);
        }
        if (!repo) {
          return next(new Error("Failed to load Repository " + name));
        }
        req.repo = repo;
        return next();
      });
    });
    app.param("orgId", function(req, res, next, name) {
      return Org.findOne({
        name: name,
        owner: req.user
      }).exec(function(err, org) {
        if (err) {
          return next(err);
        }
        if (!org) {
          return next(new Error("Failed to load Org " + name));
        }
        req.org = org;
        return next();
      });
    });
    app.param("username", function(req, res, next, username) {
      return User.findOne({
        username: username
      }).exec(function(err, user) {
        if (err) {
          return next(err);
        }
        if (!user) {
          return next(new Error("Failed to load User " + username));
        }
        req.profile = user;
        Org.find({
          owner: user
        }).exec(function(err, orgs) {
          if (err) {
            return next(err);
          }
          if (!orgs) {
            return next(new Error("Failed to load orgs for user " + username));
          }
          return req.orgs = orgs;
        });
        return next();
      });
    });
    return app.get("/", function(req, res) {
      return res.render("home/index", {
        title: "Involve your team in your development"
      });
    });
  };
}).call(this);
