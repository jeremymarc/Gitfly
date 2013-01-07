mongoose   = require("mongoose")
User       = mongoose.model("User")
Repository = mongoose.model("Repository")
GitHubApi  = require "github"

exports.show = (req, res) ->
  repos = []
  team_id = null
  org = req.org

  github = new GitHubApi(
    version: "3.0.0"
  )
  github.authenticate(
    type: "oauth"
    token: req.user.access_token
  )

  Repository.find(
    org: org
  (req, repos) ->
    res.render "orgs/show",
      periods: ['daily', 'weekly', 'monthly', 'none']
      org: org
      title: org.name
      repos: repos
  )

exports.update = (req, res) ->
  email = req.body.org.email
  notification_period = req.body.org.notification_period

  org = req.org
  org.email = email
  org.notification_period = notification_period
  org.save()

  res.redirect('/users/' + req.user.username + '/orgs/' + req.org.name)

exports.sync = (req, res) ->
  org = req.org
  user = req.user

  github = new GitHubApi(
    version: "3.0.0"
  )
  github.authenticate(
    type: "oauth"
    token: req.user.access_token
  )

  github.orgs.getTeams(
    org: org.name
  (req, resp) ->
    team_id = null

    resp.forEach((team) ->
      team_id = team.id
      if team.permission == "admin"
        team_id = team.id
        return
    )

    console.log 'Getting team repositories for organization ' + org.name
    github.orgs.getTeamRepos(
      id: team_id
      per_page: 100
    (req, resp) ->
      resp.forEach((repo) ->
        Repository.findOne(
          name: repo.name
          org: org
        (err, r) ->
          if not r
            rp = Repository.fromObject repo
            rp.org = org
            console.log 'Creating repository ' + rp.name + ' for organization ' + org.name
            rp.save()
        )
      )

      res.redirect('/users/' + user.username + '/orgs/' + org.name)
    )
  )
