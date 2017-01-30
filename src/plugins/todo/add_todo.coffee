act = require "#{__dirname}/../../seneca/act"
_handle_error = require "#{__dirname}/../helpers/handle_error"

module.exports = (args, done)->
  {todo} = args
  if !todo
    err_opts =
      role: 'util'
      cmd: 'handleErr'
      type: 'missing_args'
      service: 'todo'
      name: 'addTodo'
      given:[
        {name: 'todo'
        value: todo}
      ]
    act err_opts
    .then _handle_error done
  else
    add_opts =
      role: 'db'
      cmd: 'create'
      insert: todo
      model: 'Todo'
    act add_opts
    .then (todo)->
      done null, data: todo
    .catch _handle_error done
