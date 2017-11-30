seneca = require "#{__dirname}/seneca/instance"
act = require "#{__dirname}/seneca/act"
version = process.env.PH_WORKER_V or 'X.X.X'
listener = seneca
  .use '/plugins/todo'
  .use '/plugins/util'
  .use '/plugins/wit_ai'
  .ready (err)->
    if err
      args =
        role: 'util'
        cmd: 'handle_err'
        service: 'system'
        message: 'Error with starting seneca listener in system'
        err: err
    else
      base =
        type: 'amqp'
        pins: [
          'role:util,cmd:*'
          'role:todo,cmd:*'
          'role:wit_ai,cmd:*'
        ]
      listener.listen base
      args =
        role: 'util'
        cmd: 'log'
        service: 'worker'
        type: 'general'
        message: "Worker v#{version} started"
      @act args
