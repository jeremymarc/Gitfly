mongoose   = require 'mongoose'
Schema     = mongoose.Schema


RepositorySchema = new Schema
    org:
      type: Schema.Types.ObjectId
    name:
      type: String
      trim: true
    issues: []


RepositorySchema.statics.fromObject = (obj) ->
  Issue = mongoose.model('Issue')
  Repository = mongoose.model('Repository', RepositorySchema)

  repo = new Repository
  repo.name = obj.name

  for o in obj
    issue = Issue.fromObject o
    - if issue.body
      repo.issues.push(issue)
      console.log "Saving " + issue.title

  repo

mongoose.model "Repository", RepositorySchema
