seneca = require 'seneca'
credentials = "#{process.env.PH_RABBIT_USER}:#{process.env.PH_RABBIT_PASS}"
options =
  internal:
    logger: require 'seneca-legacy-logger'
  tag: 'worker'
  log:
    level: 'error'
  debug:
    short_logs: true
seneca = seneca options
  .use 'seneca-amqp-transport', {
    amqp:
      url: "amqp://#{credentials}@rabbitmq:5672"
  }
module.exports = seneca
