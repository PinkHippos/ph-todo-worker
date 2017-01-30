q = require 'q'
seneca = require "#{__dirname}/instance"
client = seneca.client {
  type: 'amqp'
  pin: 'role:*,cmd:*'
}
module.exports = (actionOpts)->
  dfd = q.defer()
  client.act actionOpts, (err, res)->
    if err
      dfd.reject err
    else
      if res.err
        dfd.reject res.err
      else
        dfd.resolve res.data
  dfd.promise
