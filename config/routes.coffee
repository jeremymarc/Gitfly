mongoose    = require 'mongoose'
User        = mongoose.model 'User'
Org         = mongoose.model 'Org'
Repository  = mongoose.model 'Repository'
async       = require 'async'

module.exports = (app, passport, auth) ->
  # user routes
  users = require("../app/controllers/users")
  orgs  = require("../app/controllers/orgs")
  repos = require("../app/controllers/repos")

  app.get "/users/:username", users.show
  app.post "/users/:username", users.update
  app.get "/logout", users.logout

  app.get "/users/:username/orgs/:orgId", orgs.show
  app.post "/users/:username/orgs/:orgId", orgs.update
  app.post "/users/:username/orgs/:orgId/sync", orgs.sync
  app.delete "/users/:username/orgs/:orgId/repositories/:repoName", repos.delete

  app.get "/auth/github", passport.authenticate("github",
    failureRedirect: "/"
  ), users.signin
  app.get "/auth/github/callback", passport.authenticate("github",
    failureRedirect: "/"
  ), users.authCallback

  app.param "repoName", (req, res, next, name) ->
    Repository.findOne(
      name: name
    ).exec (err, repo) ->
      return next(err) if err
      return next(new Error("Failed to load Repository " + name)) unless repo
      req.repo = repo
      next()

  app.param "orgId", (req, res, next, name) ->
    Org.findOne(
      name: name
      owner: req.user
    ).exec (err, org) ->
      return next(err) if err
      return next(new Error("Failed to load Org " + name)) unless org
      req.org = org
      next()

  app.param "username", (req, res, next, username) ->
    User.findOne(username: username).exec (err, user) ->
      return next(err)  if err
      return next(new Error("Failed to load User " + username)) unless user
      req.profile = user
      Org.find(owner: user).exec (err, orgs) ->
        return next(err)  if err
        return next(new Error("Failed to load orgs for user " + username)) unless orgs
        req.orgs = orgs

      next()
  
  # home route
  app.get "/", (req, res) ->
    res.render "home/index",
      title: "Involve your team in your development"
