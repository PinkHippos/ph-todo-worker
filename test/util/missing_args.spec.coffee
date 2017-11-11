{expect} = require 'chai'
seneca = require 'seneca'

plugin_in_test = require "#{__dirname}/../../src/plugins/util"


_action_opts =
  role: 'util'
  cmd: 'missing_args'
  service: 'test_service'
  name: 'test_service_action'
  given:
    cmd: 'test_service_action'
    role: 'test_service'
    foo: 'some_arg'
    bar: 23
    baz:
      bat: 'cat?'

_fresh_instance = ()->
  fresh_instance = seneca log: 'test'
    .use plugin_in_test
  fresh_instance

describe '|--- role:UTIL cmd:MISSING_ARGS ---|', ->
  describe 'bootstrapping', ->
    bootstrapped_instance = null
    before 'create instance and save when ready', (done)->
      test_instance = _fresh_instance()
        .test done
        .ready ->
          bootstrapped_instance = test_instance
          done()
    it 'registers the pattern role:util,cmd:missing_args', ->
      pattern_exists = bootstrapped_instance.has 'role:util,cmd:missing_args'
      expect(pattern_exists).to.equal true
  describe 'handling action args without given, name, or service', ->
    bad_action_opts = Object.assign {}, _action_opts, name: null
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
      it 'sends back a formatted error', ->
        expect(action_response.data).to.include.keys [
          'message'
          'status'
        ]
      it 'returns a string err.message', ->
        expect(action_response.data.message).to.be.a 'string'
      it 'returns a 400 err.status', ->
        expect(action_response.data.status).to.be.a 'number'
        expect(action_response.data.status).to.equal 400
