mongoose   = require("mongoose")
User       = mongoose.model("User")
Repository = mongoose.model("Repository")
GitHubApi  = require "github"

exports.delete = (req, res) ->
  repo = req.repo
  if repo
    repo.remove()
    res.send(200, 'success')

  res.send(500, 'error')

