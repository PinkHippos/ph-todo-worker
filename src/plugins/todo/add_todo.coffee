module.exports = (args, done)->
  {new_todo} = args
  if !new_todo
    err_opts =
      role: 'util'
      cmd: 'missing_args'
      given: @util.clean args
    @act err_opts, (err, response)->
      if err
        done err
      else if response.err
        done null, err: response.err
      else
        done null, err: response.data
  else
    add_opts =
      role: 'db'
      cmd: 'create'
      insert: new_todo
      model: 'Todo'
    @act add_opts, (err, response)->
      if err
        done err
      else if response.err
        done null, err: response.err
      else
        done null, data: response.data
