# Main application entry file. Please note, the order of loading is important.
# Configuration loading and booting of controllers and custom error handlers 
express  = require 'express'
fs       = require 'fs'
passport = require 'passport'

require 'express-namespace'

# Load configurations
env    = process.env.NODE_ENV or "development"
config = require('./config/config')[env]
auth   = require './authorization' 

# Bootstrap db connection
mongoose = require 'mongoose'
Schema   = mongoose.Schema
mongoose.connect config.db

# Bootstrap models
#models_path = __dirname + "/app/models"
#model_files = fs.readdirSync(models_path)
#model_files.forEach (file) ->
#require models_path + "/" + file if file.match(/js$/i)
require "./app/models/user"
require "./app/models/issue"
require "./app/models/org"
require "./app/models/repository"

# bootstrap passport config
require("./config/passport").boot passport, config
app = express() # express app
require("./settings").boot app, config, passport # Bootstrap application settings

# Bootstrap routes
require("./config/routes") app, passport, auth

# Start the app by listening on <port>
port = process.env.PORT or 3000
app.listen port
console.log "Express app started on port " + port
