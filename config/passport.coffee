mongoose         = require 'mongoose'
GitHubStrategy   = require('passport-github').Strategy
User             = mongoose.model("User")
Org              = mongoose.model("Org")
Repository       = mongoose.model("Repository")
GitHubApi        = require "github"

exports.boot = (passport, config) ->

  # serialize sessions
  passport.serializeUser (user, done) ->
    done null, user.id

  passport.deserializeUser (id, done) ->
    User.findOne
      _id: id
    , (err, user) ->
      done err, user

  # use github strategy
  passport.use new GitHubStrategy(
    clientID: config.github.clientID
    clientSecret: config.github.clientSecret
    callbackURL: config.github.callbackURL
    scope: ['user', 'public_repo', 'repo', 'gist']
  , (accessToken, refreshToken, profile, done) ->
    User.findOne
      "github.id": profile.id
    , (err, user) ->
      if user 
        done err, user
      else
        user = new User(
          name: profile.displayName
          email: profile.emails[0].value
          username: profile.username
          provider: "github"
          github: profile._json
          access_token: accessToken
        )
        user.save()

        github = new GitHubApi(
          version: "3.0.0"
        )
        github.authenticate(
          type: "oauth"
          token: accessToken
        )

        console.log 'Getting all orgs for user ' + profile.username
        github.orgs.getFromUser(
          user: profile.username
          per_page: '100'
        , (err, rep) ->
          done err, user if err
          rep.forEach((r) ->
            org = Org.fromObject r
            org.owner = user
            org.users = [ user ]

            console.log 'Creating organization ' + org.name

            github.orgs.getTeams(
              org: org.name
            (req, resp) ->
              team_id = null
              repos = []

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
                  rp = Repository.fromObject repo
                  rp.org = org
                  console.log 'Creating repository ' + rp.name + ' for organization ' + org.name
                  rp.save()
                  repos.push(rp)
                )

                org.repositories = repos
                org.save()
                done err, user
              )
            )
          )
        )
  )


