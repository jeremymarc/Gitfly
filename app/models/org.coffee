mongoose = require 'mongoose'
Schema   = mongoose.Schema

OrgSchema = new Schema
    name:
      type: String
    owner:
      type: Schema.Types.ObjectId
    users:
      type: [Schema.Types.ObjectId]
    notification_period:
      type: String
    last_notification:
      type: Date
      default: new Date
    email:
      type: String
      trim: true
    avatar_url:
      type: String
      trim: true
    github: {}

OrgSchema.statics.fromObject = (obj) ->
  Org = mongoose.model('Org', OrgSchema)
  org = new Org
  org.name  = obj.login
  org.avatar_url = obj.avatar_url
  org.url = obj.url
  org.github = {}
  org.github.id = obj.id
  org.email = ""
  org.notification_period = "daily"

  org

mongoose.model "Org", OrgSchema
