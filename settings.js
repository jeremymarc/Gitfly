(function() {
  var bootApplication, express, mongoStore;
  express = require('express');
  mongoStore = require('connect-mongodb');
  exports.boot = function(app, config, passport) {
    return bootApplication(app, config, passport);
  };
  /*
  Module dependencies.
  */
  bootApplication = function(app, config, passport) {
    app.set("showStackError", true);
    app.use(express.static(__dirname + "/public"));
    app.use(express.logger(":method :url :status"));
    app.set("views", __dirname + "/app/views");
    app.set("view engine", "jade");
    app.configure(function() {
      app.use(function(req, res, next) {
        res.locals.appName = "Nodejs Express Mongoose Demo";
        res.locals.title = "Nodejs Express Mongoose Demo";
        res.locals.showStack = app.showStackError;
        res.locals.req = req;
        res.locals.formatDate = function(date) {
          var monthNames;
          monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sep", "Oct", "Nov", "Dec"];
          return monthNames[date.getMonth()] + " " + date.getDate() + ", " + date.getFullYear();
        };
        res.locals.stripScript = function(str) {
          return str.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/g, "");
        };
        res.locals.createPagination = function(pages, page) {
          var clas, p, params, qs, str, url;
          url = require("url");
          qs = require("querystring");
          params = qs.parse(url.parse(req.url).query);
          str = "";
          params.page = 0;
          clas = (page === 0 ? "active" : "no");
          str += "<li class=\"" + clas + "\"><a href=\"?" + qs.stringify(params) + "\">First</a></li>";
          p = 1;
          while (p < pages) {
            params.page = p;
            clas = (page === p ? "active" : "no");
            str += "<li class=\"" + clas + "\"><a href=\"?" + qs.stringify(params) + "\">" + p + "</a></li>";
            p++;
          }
          params.page = --p;
          clas = (page === params.page ? "active" : "no");
          str += "<li class=\"" + clas + "\"><a href=\"?" + qs.stringify(params) + "\">Last</a></li>";
          return str;
        };
        return next();
      });
      app.use(express.cookieParser());
      app.use(express.bodyParser());
      app.use(express.methodOverride());
      app.use(express.session({
        secret: "noobjs",
        store: new mongoStore({
          url: config.db,
          collection: "sessions"
        })
      }));
      app.use(passport.initialize());
      app.use(passport.session());
      app.use(express.favicon());
      app.use(app.router);
      app.use(function(err, req, res, next) {
        if (~err.message.indexOf("not found")) {
          return next();
        }
        console.error(err.stack);
        return res.status(500).render("500");
      });
      return app.use(function(req, res, next) {
        return res.status(404).render("404", {
          url: req.originalUrl
        });
      });
    });
    return app.set("showStackError", false);
  };
}).call(this);
