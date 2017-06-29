{expect} = require 'chai'
seneca = require 'seneca'

plugin_in_test = require "#{__dirname}/../../src/plugins/todo"


_action_opts =
  role: 'todo'
  cmd: 'add_todo'
  new_todo:
    text: 'This is a test todo'

_outside_action_args = {}

_fresh_instance = ()->
  fresh_instance = seneca log: 'test'
    .add 'role:util,cmd:missing_args', (msg, reply)->
      msg.given = @util.clean msg.given
      _outside_action_args['util-missing_args'] = @util.clean msg
      reply null, data:{}
    .add 'role:db,cmd:create', (msg, reply)->
      _outside_action_args['db-create'] = @util.clean msg
      reply null, data: msg.insert
    .use plugin_in_test
  fresh_instance

describe '|--- role:TODO cmd: ADD_TODO ---|', ->
  describe 'bootstrapping', ->
    bootstrapped_instance = null
    before 'create instance and save when ready', (done)->
      test_instance = _fresh_instance()
        .test done
        .ready ->
          bootstrapped_instance = test_instance
          done()
    it 'registers the pattern role:todo,cmd:add_todo', ->
      pattern_exists = bootstrapped_instance.has 'role:todo,cmd:add_todo'
      expect(pattern_exists).to.equal true
  describe 'handling action args without a new_todo', ->
    bad_action_opts = Object.assign {}, _action_opts, new_todo: null
    action_response = null
    before 'start fresh instance, send bad action, and save response', (done)->
      _fresh_instance()
      .test done
      .ready ->
        @act bad_action_opts, (err, response)->
          action_response = response
          done()
    it 'sends back an error', ->
      expect(action_response).to.include.keys 'err'
    it 'calls the error handler', ->
      expect(_outside_action_args).to.include.keys 'util-missing_args'
    it "passes its arguments to the err handler as the 'given' key", ->
      handler_opts = _outside_action_args['util-missing_args']
      expect(handler_opts.given).to.deep.equal bad_action_opts

  describe 'handling correct action args', ->
    action_response = null
    before 'send action and save response', (done)->
      _fresh_instance()
      .test done
      .ready ->
        @act _action_opts, (err, response)->
          action_response = response
          done()
    describe 'responding to succesful calls', ->
      it 'sends back an object with a data key', ->
        expect(action_response).to.include.keys 'data'
      it 'sends back the new todo as the data key', ->
        expect(action_response.data).to.deep.equal _action_opts.new_todo
    describe 'calling the db plugin', ->
      it 'calls the db plugin', ->
        expect(_outside_action_args).to.include.keys 'db-create'
      it 'passes all the required keys', ->
        expect(_outside_action_args['db-create']).to.include.keys [
          'model'
          'insert'
        ]
      it "specifies the 'Todo' model", ->
        expect(_outside_action_args['db-create'].model).to.equal 'Todo'
      it "passes the new_todo as the 'insert' key", ->
        expect(_outside_action_args['db-create'].insert)
          .to.deep.equal _action_opts.new_todo
