##### _handle_error #####
# Builds a callback to be used with a .catch or .then in some cases
# @params: done -> function
# @returns -> function
module.exports = (done)->
  (err)->
    error =
      status: err.status || 500
      message: err.message
    done null, err: error
