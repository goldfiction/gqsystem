index=require '../index.js'
assert=require 'assert'

it 'should be able to run os info',(done)->
  index.osinfo (e,r)->
    console.log r
    assert r["OS Type"]
    done()