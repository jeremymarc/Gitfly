(function() {
  var GitHubApi, GitHubStrategy, Org, Repository, User, mongoose;
  mongoose = require('mongoose');
  GitHubStrategy = require('passport-github').Strategy;
  User = mongoose.model("User");
  Org = mongoose.model("Org");
  Repository = mongoose.model("Repository");
  GitHubApi = require("github");
  exports.boot = function(passport, config) {
    passport.serializeUser(function(user, done) {
      return done(null, user.id);
    });
    passport.deserializeUser(function(id, done) {
      return User.findOne({
        _id: id
      }, function(err, user) {
        return done(err, user);
      });
    });
    return passport.use(new GitHubStrategy({
      clientID: config.github.clientID,
      clientSecret: config.github.clientSecret,
      callbackURL: config.github.callbackURL,
      scope: ['user', 'public_repo', 'repo', 'gist']
    }, function(accessToken, refreshToken, profile, done) {
      return User.findOne({
        "github.id": profile.id
      }, function(err, user) {
        var github;
        if (!user) {
          user = new User({
            name: profile.displayName,
            email: profile.emails[0].value,
            username: profile.username,
            provider: "github",
            github: profile._json,
            access_token: accessToken
          });
          user.save();
          github = new GitHubApi({
            version: "3.0.0"
          });
          github.authenticate({
            type: "oauth",
            token: accessToken
          });
          console.log('Getting all orgs for user ' + profile.username);
          return github.orgs.getFromUser({
            user: profile.username,
            per_page: '100'
          }, function(err, rep) {
            console.log(rep);
            if (err) {
              done(err, user);
            }
            return rep.forEach(function(r) {
              var org;
              org = Org.fromObject(r);
              org.owner = user;
              org.users = [user];
              console.log('Creating organization ' + org.name);
              return github.orgs.getTeams({
                org: org.name
              }, function(req, resp) {
                var repos, team_id;
                team_id = null;
                repos = [];
                resp.forEach(function(team) {
                  team_id = team.id;
                  if (team.permission === "admin") {
                    team_id = team.id;
                  }
                });
                console.log('Getting team repositories for organization ' + org.name);
                return github.orgs.getTeamRepos({
                  id: team_id,
                  per_page: 100
                }, function(req, resp) {
                  resp.forEach(function(repo) {
                    var rp;
                    rp = Repository.fromObject(repo);
                    rp.org = org;
                    console.log('Creating repository ' + rp.name + ' for organization ' + org.name);
                    rp.save();
                    return repos.push(rp);
                  });
                  org.repositories = repos;
                  org.save();
                  return done(err, user);
                });
              });
            });
          });
        }
      });
    }));
  };
}).call(this);
