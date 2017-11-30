module.exports = (options)->
  plugin = 'pusher'
  patterns = [
    'trigger_event'
  ]
  for pattern in patterns
   pattern_string = "role:#{plugin},cmd:#{pattern}"
   file_path = "#{__dirname}/#{pattern}"
   @add pattern_string, require file_path
  plugin

###
You can subscribe to events using this:
  Pusher.logToConsole = true

  pusher = new Pusher 'PUSHER_APP_ID', {
    cluster: 'PUSHER_APP_CLUSTER',
    encrypted: true
  }
  channel = pusher.subscribe 'CHANNEL_NAME'
  channel.bind 'EVENT_NAME', (data)->
    console.log 'NEW EVENT', data
###
