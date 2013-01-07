path           = require "path"
templatesDir   = path.join __dirname,  'templates'
emailTemplates = require "email-templates"
nodemailer     = require "nodemailer"
env            = process.env.NODE_ENV or "development"
config         = require('./../../config/config')[env]

class Email
  transport: null

  constructor: ->
    @transport = nodemailer.createTransport("SMTP", config.smtp)


  sendDailyRepositoryIssues: (obj) ->
    self = this
    emailTemplates templatesDir, (err, template) ->
      console.log err
      template 'closed-issues', obj, (err, html, text) ->
        self.transport.sendMail
          from: "marc.jeremy@gmail.com"
          to: obj.to
          subject: "Daily Closed Issues"
          html: html
          text: text
        , (err, responseStatus) ->
          return console.log if err
          console.log responseStatus.message


module.exports = Email
