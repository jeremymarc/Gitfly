fs       = require 'fs'
async    = require 'async'

# Load configurations
env    = process.env.NODE_ENV or "development"
config = require('../config/config')[env]

# Bootstrap db connection
mongoose = require 'mongoose'
Schema   = mongoose.Schema
mongoose.connect config.db

# Bootstrap models
require "./models/user"
require "./models/issue"
require "./models/org"
require "./models/repository"

mongoose   = require("mongoose")
Org        = mongoose.model("Org")
Repository = mongoose.model("Repository")
User       = mongoose.model("User")
Issue      = mongoose.model("Issue")
GitHubApi  = require "github"
Email      = require './controllers/email'

email = new Email

github = new GitHubApi(
    version: "3.0.0"
)

today = new Date
today.setDate(today.getDate() - 1) #yesterday

User.find(
  provider: 'github'
(err, users) ->
  console.log "Found " + users.length + " users ; sending notifications"

  users.forEach((user) ->
    repositories = []

    github.authenticate(
      type: "oauth"
      token: user.access_token
    )

    Org.find(
      users:
        $in: [user]
    (err, orgs) ->
      orgs.forEach((org) ->
        diff = new Date - org.last_notification 
        switch org.notification_period
          when 'daily' then value = 60 * 60 * 1000 * 24
          when 'weekly' then value = 60 * 60 * 1000 * 24 * 7
          when 'none' then value = -1

        console.log diff
        if  diff > value > 0 or true
          Repository.find(
            org: org
          (err, repositories) ->
            console.log "User " + user.id + " has " + repositories.length + " repositories"

            async.map(repositories, (repo, callback) ->
              github.issues.repoIssues(
                  user: org.name
                  repo: repo.name
                  state: "closed"
                  direction: "asc"
                  since: today.toISOString()
                  per_page: 100
              , (err, res) ->
                  return callback null, null if err

                  console.log "Getting issues for organization " + org.name + " and repository " + repo.name
                  r = Repository.fromObject res
                  r.name = repo.name
                  
                  #MOVE TO Repository
                  if r.issues.length > 0
                    issues = {}
                    r.issues.forEach((issue) ->
                      user_id = issue.user
                      issues[user_id] = [] if issues[user_id] is undefined
                      issues[user_id].push(issue)
                    )
                    r.user_issues = issues

                  callback null, r
              )
            , (err, results) ->
              console.log "Computing result and sending notification"

              #remove empty repo
              repos = []
              results.forEach((repo) ->
                if repo and repo.user_issues
                  repos.push(repo)
              )

              dest = org.email or user.email
              if repos.length > 0 and dest
                console.log 'Sending email notifications for org ' + org.name
                email.sendDailyRepositoryIssues 
                  repositories: repos
                  name: org.name
                  to: org.email 

              org.last_notification = new Date
              org.save()
            )
          )
      )
    )
  )
)
