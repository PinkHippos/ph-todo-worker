seneca = require 'seneca'
credentials = "#{process.env.PH_RABBIT_USER}:#{process.env.PH_RABBIT_PASS}"
options =
  log:
    level: true
  tag: 'worker'
  'logstash-logger':
    host: 'logstash'
    port: 9600
    type: 'tcp'
seneca = seneca options
  .use 'seneca-amqp-transport', {
    amqp:
      url: "amqp://#{credentials}@rabbitmq:5672"
  }
  .client {
    type: 'amqp'
  }
  .use require "#{__dirname}/logger"
module.exports = seneca
