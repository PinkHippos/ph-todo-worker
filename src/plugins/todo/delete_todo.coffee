module.exports = (args, done)->
  {id} = args
  if !id
    err_opts =
      role: 'util'
      cmd: 'missing_args'
      service: 'todo'
      name: 'delete_todo'
      given: @util.clean args
    @act err_opts, (err, response)->
      done null, err: response.data
  else
    add_opts =
      role: 'db'
      cmd: 'destroy'
      query:
        primary_key: id
      model: 'Todo'
    @act add_opts, (err, response)->
      if err or response.err
        done null, err:
          seneca_err: err
          action_err: response.err
          message: 'Error while deleting todo: ' + id
      else
        done null, data: response.data
