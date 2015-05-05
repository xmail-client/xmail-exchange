
xmailExchange = require '../lib/xmail-exchange'

assert = require 'should' 

describe 'xmailExchange', ->

  it 'should be awesome', -> 
    xmailExchange().should.equal('awesome')
