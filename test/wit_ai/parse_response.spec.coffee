{expect} = require 'chai'
seneca = require 'seneca'
env = require('dotenv').config({path: "#{__dirname}/../../../secrets.env"})
plugin_in_test = require "#{__dirname}/../../src/plugins/wit_ai/"

_outside_action_args = {}

# Generic response to check response with default confidence
_default_test_set =
  raw_wit_response:
    msg_id: 'SOME_WIT_AI_ID_1'
    _text: 'Add an important todo for tomorrow at 1pm and 3pm'
    entities:
      reminder:[
        {
          value: 'an important todo'
          confidence: .65
        }
      ]
      datetime:[
        {
          value: '2017-11-17T13:00:00.000-08:00'
          confidence: .95
        }
        {
          value: '2017-11-16T15:00:00.000-08:00'
          confidence: .80
        }
      ]
      intent: [
        {
          confidence: .75
          value: 'todo:add_todo'
        }
      ]
  expected:
    reminder:
      strongest_value: 'an important todo'
      strongest_confidence: .65
      values: ['an important todo']
    intent:
      strongest_value: 'todo:add_todo'
      strongest_confidence: .75
      values: ['todo:add_todo']
    datetime:
      strongest_value: '2017-11-17T13:00:00.000-08:00'
      strongest_confidence: .95
      values: [
        '2017-11-17T13:00:00.000-08:00'
        '2017-11-16T15:00:00.000-08:00'
      ]
# Checks for using overall confidence lower than the default
_lower_than_default_confidence_test_set =
  raw_wit_response:
    msg_id: 'SOME_WIT_AI_ID_2'
    _text: 'Add an important todo for tomorrow at 1pm and 3pm'
    entities:
      reminder:[
        {
          value: 'an important todo'
          confidence: .3
        }
      ]
      datetime:[
        {
          value: '2017-11-17T13:00:00.000-08:00'
          confidence: .4
        }
        {
          value: '2017-11-16T15:00:00.000-08:00'
          confidence: .35
        }
      ]
      intent: [
        {
          confidence: .3
          value: 'todo:add_todo'
        }
      ]
  min_confidence_settings:
    overall: .25
  expected:
    reminder:
      strongest_value: 'an important todo'
      strongest_confidence: .3
      values: ['an important todo']
    intent:
      strongest_value: 'todo:add_todo'
      strongest_confidence: .3
      values: ['todo:add_todo']
    datetime:
      strongest_value: '2017-11-17T13:00:00.000-08:00'
      strongest_confidence: .4
      values: [
        '2017-11-17T13:00:00.000-08:00'
        '2017-11-16T15:00:00.000-08:00'
      ]
# Checks for specific confidence settings to be used
_specific_confidence_setting_test_set =
  raw_wit_response:
    msg_id: 'SOME_WIT_AI_ID_3'
    _text: 'Add an important todo and buy some milk for tomorrow at 1pm and 3pm'
    entities:
      reminder:[
        {
          value: 'an important todo'
          confidence: .65
        }
      ]
      datetime:[
        {
          value: '2017-11-10T13:00:00.000-08:00'
          confidence: .95
        }
        {
          value: '2017-11-20T15:00:00.000-08:00'
          confidence: .7
        }
      ]
      intent: [
        {
          confidence: .3
          value: 'todo:add_todo'
        }
      ]
  min_confidence_settings:
    intent: .25
  expected:
    reminder:
      strongest_value: 'an important todo'
      strongest_confidence: .65
      values: ['an important todo']
    intent:
      strongest_value: 'todo:add_todo'
      strongest_confidence: .3
      values: ['todo:add_todo']
    datetime:
      strongest_value: '2017-11-10T13:00:00.000-08:00'
      strongest_confidence: .95
      values: [
        '2017-11-10T13:00:00.000-08:00'
        '2017-11-20T15:00:00.000-08:00'
      ]

test_sets = [
  _default_test_set
  _lower_than_default_confidence_test_set
  _specific_confidence_setting_test_set
]
_outside_action_args = {}

_action_opts =
  role: 'wit_ai'
  cmd: 'parse_response'
  raw_wit_response: _default_test_set.raw_wit_response

_fresh_instance = ()->
  fresh_instance = seneca log: 'test'
    .add 'role:util,cmd:missing_args', (msg, reply)->
      msg.given = @util.clean msg.given
      _outside_action_args['util-missing_args'] = @util.clean msg
      reply null, data:{}
    .use plugin_in_test
  fresh_instance

describe '|--- role: WIT_AI cmd: PARSE_RESPONSE ---|', ->
  describe 'bootstrapping', ->
    bootstrapped_instance = null
    before 'create instance and save when ready', (done)->
      test_instance = _fresh_instance()
        .test done
        .ready ->
          bootstrapped_instance = test_instance
          done()
    it 'registers the pattern role:wit_ai,cmd:parse_response', ->
      pattern_exists = bootstrapped_instance.has 'role:wit_ai,cmd:parse_response'
      expect(pattern_exists).to.equal true
  describe 'handling action args without raw_wit_response', ->
    bad_action_opts = Object.assign {}, _action_opts, raw_wit_response: null
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
    test_sets.forEach (test_set)->
      {raw_wit_response, min_confidence_settings, expected} = test_set
      action_response = null
      before 'send action and save response', (done)->
        _fresh_instance()
        .test done
        .ready ->
          @act 'role:wit_ai,cmd:parse_response', {
              raw_wit_response,
              min_confidence_settings
          }, (err, response)->
            action_response = response
            done()
      it 'returns the parsed wit response', ->
        expect(action_response).to.include.keys 'data'
        expect(action_response.data).to.be.an 'object'
      it 'includes each of the entity keys passed on raw_wit_response', ->
        keys_to_parse = Object.keys raw_wit_response.entities
        expect(action_response.data).to.include.keys keys_to_parse
      describe 'parsing each key correctly', ->
        for key of expected
          it "parses #{key} correctly", ->
            actual_value = action_response.data[key]
            expected_value = expected[key]
            expect(actual_value).to.eql expected_value
