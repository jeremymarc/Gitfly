mongoose   = require "mongoose"
Schema     = mongoose.Schema
User       = mongoose.model("User")

IssueSchema = new Schema(
  #user:
  #type: Schema.ObjectId
  #ref: 'User'
  user: {}

  title: 
    type: String
    default: ''
    trim: true

  body: 
    type: String
    default: ''
    trim: true

  milestone: 
    type: String
    default: ''
    trim: true

  status:
    type: String
    default: ''
    trim: true

  updated_at:
    type: Date

  closed_at:
    type: Date
)

IssueSchema.statics.fromObject = (obj) ->
  Issue = mongoose.model('Issue')

  issue = new Issue
  issue.user = User.fromObject(obj.user)
  issue.id = obj.id
  issue.number = obj.number
  issue.title = obj.title
  issue.body = obj.body
  issue.closed_at = obj.closed_at
  issue.milestone = obj.milestone
  issue.status = obj.status
  issue

IssueSchema.path('title').validate ((title) ->
    return title.length > 0
), 'Issue title cannot be blank'

IssueSchema.path('milestone').validate ((title) ->
    return title.length > 0
), 'Issue milestone cannot be blank'

mongoose.model "Issue", IssueSchema
