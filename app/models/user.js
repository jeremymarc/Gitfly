(function() {
  var Schema, UserSchema, authTypes, crypto, mongoose, validatePresenceOf, _;
  mongoose = require('mongoose');
  Schema = mongoose.Schema;
  crypto = require('crypto');
  _ = require('underscore');
  authTypes = ["github"];
  UserSchema = new Schema({
    access_token: {
      type: String
    },
    name: {
      type: String,
      trim: true
    },
    email: {
      type: String,
      trim: true
    },
    username: {
      type: String,
      trim: true
    },
    login: {
      type: String,
      trim: true
    },
    avatar_url: {
      type: String,
      trim: true
    },
    provider: {
      type: String,
      trim: true
    },
    hashed_password: {
      type: String,
      trim: true
    },
    salt: {
      type: String,
      trim: true
    },
    github: {},
    notification_period: {
      type: String,
      trim: true
    },
    disabled: {
      type: Boolean,
      trim: true
    }
  });
  UserSchema.statics.fromObject = function(obj) {
    var User, user;
    User = mongoose.model("User");
    user = new User;
    user.id = obj.id;
    user.login = obj.login;
    user.avatar_url = obj.avatar_url;
    user.disabled = false;
    return user;
  };
  UserSchema.virtual("password").set(function(password) {
    this._password = password;
    this.salt = this.makeSalt();
    return this.hashed_password = this.encryptPassword(password);
  }).get(function() {
    return this._password;
  });
  validatePresenceOf = function(value) {
    return value && value.length;
  };
  UserSchema.path("name").validate((function(name) {
    if (authTypes.indexOf(this.provider) !== -1) {
      return true;
    }
    return name.length;
  }), "Name cannot be blank");
  UserSchema.path("email").validate((function(email) {
    if (authTypes.indexOf(this.provider) !== -1) {
      return true;
    }
    return email.length;
  }), "Email cannot be blank");
  UserSchema.path("username").validate((function(username) {
    if (authTypes.indexOf(this.provider) !== -1) {
      return true;
    }
    return username.length;
  }), "Username cannot be blank");
  UserSchema.pre("save", function(next) {
    if (!this.isNew) {
      return next();
    }
    if (!validatePresenceOf(this.password) && authTypes.indexOf(this.provider) === -1) {
      return next(new Error("Invalid password"));
    } else {
      return next();
    }
  });
  UserSchema.method("authenticate", function(plainText) {
    return this.encryptPassword(plainText) === this.hashed_password;
  });
  UserSchema.method("makeSalt", function() {
    return Math.round(new Date().valueOf() * Math.random()) + "";
  });
  UserSchema.method("encryptPassword", function(password) {
    return crypto.createHmac("sha1", this.salt).update(password).digest("hex");
  });
  mongoose.model("User", UserSchema);
}).call(this);
