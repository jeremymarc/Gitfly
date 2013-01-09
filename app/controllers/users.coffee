mongoose   = require("mongoose")
User       = mongoose.model("User")
Org        = mongoose.model("Org")
GitHubApi  = require "github"

exports.signin = (req, res) ->

# auth callback
exports.authCallback = (req, res, next) ->
  res.redirect "/users/" + req.user.username

# login
exports.login = (req, res) ->
  res.render "users/login",
    title: "GitFly - Login"

# sign up
exports.signup = (req, res) ->
  res.render "users/signup",
    title: "Gitfly - Sign up"

# logout
exports.logout = (req, res) ->
  req.logout()
  res.redirect "/"

# session
exports.session = (req, res) ->
  res.redirect "/"

# signup
exports.create = (req, res) ->
  user = new User(req.body)
  user.provider = "local"
  user.save (err) ->
    if err
      return res.render("users/signup",
        errors: err.errors
      )
    req.logIn user, (err) ->
      return next(err)  if err
      res.redirect "/"

# show profile
exports.show = (req, res) ->
  Org.find(
    users: 
      $in: [ req.user ]
  (err, orgs) ->
    res.render "users/show",
      periods: ["daily", "weekly", "monthly", "none"]
      title: req.user.name
      user: req.user
      orgs: orgs
  )

exports.update = (req, res) ->
  user = req.profile
  user.notification_period = req.body.user.notification_period
  user.email = req.body.user.email
  user.save()

  #display a flash message
  res.redirect('/users/' + req.user.username)
