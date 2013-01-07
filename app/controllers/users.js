(function() {
  var GitHubApi, Org, User, mongoose;
  mongoose = require("mongoose");
  User = mongoose.model("User");
  Org = mongoose.model("Org");
  GitHubApi = require("github");
  exports.signin = function(req, res) {};
  exports.authCallback = function(req, res, next) {
    return res.redirect("/users/" + req.user.username);
  };
  exports.login = function(req, res) {
    return res.render("users/login", {
      title: "GitFly - Login"
    });
  };
  exports.signup = function(req, res) {
    return res.render("users/signup", {
      title: "Gitfly - Sign up"
    });
  };
  exports.logout = function(req, res) {
    req.logout();
    return res.redirect("/");
  };
  exports.session = function(req, res) {
    return res.redirect("/");
  };
  exports.create = function(req, res) {
    var user;
    user = new User(req.body);
    user.provider = "local";
    return user.save(function(err) {
      if (err) {
        return res.render("users/signup", {
          errors: err.errors
        });
      }
      return req.logIn(user, function(err) {
        if (err) {
          return next(err);
        }
        return res.redirect("/");
      });
    });
  };
  exports.show = function(req, res) {
    return Org.find({
      users: {
        $in: [req.user]
      }
    }, function(err, orgs) {
      return res.render("users/show", {
        periods: ["daily", "weekly", "monthly", "none"],
        title: req.user.name,
        user: req.user,
        orgs: orgs
      });
    });
  };
  exports.update = function(req, res) {
    var user;
    user = req.profile;
    user.notification_period = req.body.user.notification_period;
    user.email = req.body.user.email;
    user.save();
    return res.redirect('/users/' + req.user.id);
  };
}).call(this);
