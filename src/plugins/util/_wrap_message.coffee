act = require "#{__dirname}/../../seneca/act"
module.exports = (type, message, service)->
  if !service or !message
    errOpts =
      role: 'util'
      cmd: 'handle_err'
      type: 'missing_args'
      name: '_wrap_message'
      service: 'util'
      given: [{name: 'service', given: service}]
    act errOpts
    false
  else
    title = "*_*_* #{type} from #{service.toUpperCase()} *_*_*\n"
    header = for char in title
      '='
    message = """
    #{header.join ''}
    #{title}
    #{message}

    _*_*_*_*_ END _*_*_*_*_
    =======================
    """
    message
