Pusher = require 'pusher'
_default_opts =
  appId: process.env.PUSHER_APP_ID
  key: process.env.PUSHER_APP_KEY
  secret: process.env.PUSHER_APP_SECRET
  cluster: process.env.PUSHER_APP_CLUSTER
  encrypted: true
module.exports = (pusher_opts = _default_opts)->
  new Pusher pusher_opts
