mongoose  = require 'mongoose'
Schema    = mongoose.Schema
crypto    = require 'crypto'
_         = require 'underscore'
authTypes = ["github"]

UserSchema = new Schema(
  access_token:
    type: String
  name:
    type: String
    trim: true
  email:
    type: String
    trim: true
  username:
    type: String
    trim: true
  login:
    type: String
    trim: true
  avatar_url:
    type: String
    trim: true
  provider:
    type: String
    trim: true
  hashed_password:
    type: String
    trim: true
  salt:
    type: String
    trim: true
  github: {}
  notification_period:
    type: String
    trim: true
  disabled:
    type: Boolean
    trim: true
)

UserSchema.statics.fromObject = (obj) ->
  User = mongoose.model("User")

  user = new User
  user.id = obj.id
  user.login = obj.login
  user.avatar_url = obj.avatar_url
  user.disabled = false
  user

# virtual attributes
UserSchema.virtual("password").set((password) ->
  @_password = password
  @salt = @makeSalt()
  @hashed_password = @encryptPassword(password)
).get ->
  @_password


# validations
validatePresenceOf = (value) ->
  value and value.length


# the below 4 validations only apply if you are signing up traditionally
UserSchema.path("name").validate ((name) ->
  # if you are authenticating by any of the oauth strategies, don't validate
  return true  if authTypes.indexOf(@provider) isnt -1
  name.length
), "Name cannot be blank"


UserSchema.path("email").validate ((email) ->
  # if you are authenticating by any of the oauth strategies, don't validate
  return true  if authTypes.indexOf(@provider) isnt -1
  email.length
), "Email cannot be blank"

UserSchema.path("username").validate ((username) ->
  # if you are authenticating by any of the oauth strategies, don't validate
  return true  if authTypes.indexOf(@provider) isnt -1
  username.length
), "Username cannot be blank"

# pre save hooks
UserSchema.pre "save", (next) ->
  return next() unless @isNew
  if not validatePresenceOf(@password) and authTypes.indexOf(@provider) is -1
    next new Error("Invalid password")
  else
    next()

# methods
UserSchema.method "authenticate", (plainText) ->
  @encryptPassword(plainText) is @hashed_password

UserSchema.method "makeSalt", ->
  Math.round((new Date().valueOf() * Math.random())) + ""

UserSchema.method "encryptPassword", (password) ->
  crypto.createHmac("sha1", @salt).update(password).digest "hex"

mongoose.model "User", UserSchema
