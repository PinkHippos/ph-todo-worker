Pusher = require 'pusher'

module.exports = (args, done)->
  {channel, event_name, data} = args
  if !channel or !event_name or !data
    err_opts =
      role: 'util'
      cmd: 'handle_err'
      type: 'missing_args'
      given: [
        {name: 'channel', value: channel}
        {name: 'event_name', value: event_name}
        {name: 'data', value: data}
      ]
    @act err_opts, (err, response)->
      done null, data: response.data
  else
    # Build pusher client and trigger event
    pusher_opts =
      appId: @options().pusher.PUSHER_APP_ID
      key: @options().pusher.PUSHER_APP_KEY
      secret: @options().pusher.PUSHER_APP_SECRET
      cluster: @options().pusher.PUSHER_APP_CLUSTER
      encrypted: true
    pusher = new Pusher pusher_opts
    pusher_cb = (pusher_err, request, response)->
      # Log out anything we get back from pusher
      if pusher_err
        console.log 'PUSHER ERR', pusher_err
        done null, err:
          status: pusher_err.status or 500
          message: 'Error while sending event to pusher'
          err: pusher_err
      else
        # Send response assuming the event was triggered
        done null, data:
          action_success: true
          status: 200
          message: "Triggered a #{event_name} event in the #{channel} channel"
    # Send Pusher event
    pusher.trigger channel, event_name, data, null, pusher_cb
