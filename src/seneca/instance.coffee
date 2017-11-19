seneca = require 'seneca'
credentials = "#{process.env.PH_RABBIT_USER}:#{process.env.PH_RABBIT_PASS}"
options =
  log:
    level: true
  tag: 'worker'
seneca = seneca options
  .use 'seneca-amqp-transport', {
    amqp:
      url: "amqp://#{credentials}@rabbitmq:5672"
  }
  .client {
    type: 'amqp'
    pin: 'role:*,cmd:*'
  }
module.exports = seneca
