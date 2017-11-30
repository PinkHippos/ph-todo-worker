{expect} = require 'chai'
seneca = require 'seneca'
sinon = require 'sinon'
proxyquire = require 'proxyquire'

pusher_stub = sinon.stub()
_get_client_spy = sinon.spy (pusher_opts)->
    {trigger: pusher_stub.callsArg 4}

file_path = "#{__dirname}/../../src/plugins/pusher"
plugin_in_test = proxyquire file_path, {
  './trigger_event': proxyquire "#{file_path}/trigger_event", {
    './_get_pusher_client': _get_client_spy
  }
}

_outside_action_args = {}
_fresh_instance = ->
  instance = seneca log: 'test'
    .add 'role:util,cmd:missing_args', (args, done)->
      _outside_action_args['missing_args'] = @util.clean args
      done null, data:
        status: 400
        message: 'send the right stuff'
    .use plugin_in_test
  instance

default_action_opts =
  role: 'pusher'
  cmd: 'trigger_event'
  channel: 'test_channel'
  event_name: 'test_event'
  data:
    message: 'test message from default actions'

describe 'role: PUSHER, cmd: TRIGGER_EVENT',->

  describe 'bootstraping', ->
    test_instance = null
    before 'get fresh instance', (done)->
      test_instance = _fresh_instance()
        .test done
        .ready ->
          done()
    it 'registers cmd:trigger_event',->
      has_pattern = test_instance.has 'role:pusher,cmd:trigger_event'
      expect(has_pattern).to.equal true

  describe 'handling bad args', ->
    bad_action_tests =
      without_channel: Object.assign {}, default_action_opts, {
        channel: null
      }
      without_event_name: Object.assign {}, default_action_opts, {
        event_name: null
      }
      without_data: Object.assign {}, default_action_opts, {
        data: null
      }
    Object.keys(bad_action_tests).forEach (test_name)->
      describe test_name, ->
        bad_args = bad_action_tests[test_name]
        result = null
        beforeEach 'send bad actions, save response', (done)->
          _fresh_instance()
          .test done
          .ready ->
            @act bad_action_tests[test_name], (err, response)->
              result = response
              done()
        afterEach 'reset stubs', ->
          _outside_action_args = {}
        it 'calls the missing_args action', ->
          expect(_outside_action_args).to.include.keys 'missing_args'
        it "passes a 'given' to missing_args", ->
          expect(_outside_action_args['missing_args']).to.include.keys 'given'
        it 'formats the given args correctly', ->
          expect(_outside_action_args['missing_args'].given).to.be.an 'object'
        it "sends its args as the 'given' key", ->
          expect(_outside_action_args['missing_args'].given).to.deep.equal bad_action_tests[test_name]
        it 'returns an error', ->
          expect(result).to.include.keys 'err'

  describe 'handling correct args', ->
    result = null
    beforeEach 'send action and save result', (done)->
      pusher_stub.calls
      _fresh_instance()
      .test done
      .ready ->
        @act default_action_opts, (err, response)->
          result = response
          done err
    afterEach 'clear _outside_action_args and reset stub and spy', ->
      pusher_stub.reset()
      _get_client_spy.reset()
    describe 'calling outside methods', ->
      {channel, event_name, data} = default_action_opts
      trigger_args = [
        channel
        event_name
        data
      ]
      it "calls '_get_pusher_client' to get a pusher client", ->
        expect(_get_client_spy.called).to.equal true
      it "calls 'trigger' method of pusher client", ->
        expect(pusher_stub.called).to.equal true
      it "calls 'trigger' method with 'event', 'channel', and 'data'", ->
        expect(pusher_stub.args[0]).to.include.members trigger_args
      it "calls 'trigger' method with proper args in correct order", ->
        expect(pusher_stub.args[0][0]).to.equal channel
        expect(pusher_stub.args[0][1]).to.equal event_name
        expect(pusher_stub.args[0][2]).to.equal data

    describe 'returning properly', ->
      it "returns an object with a 'data' key", ->
        expect(result).to.include.keys 'data'
      it "returns a 'data' object with keys 'status', 'message', and 'action_success'", ->
        expect(result.data).to.include.keys [
          'status'
          'message'
          'action_success'
        ]
