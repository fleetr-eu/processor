MongoClient = require('mongodb').MongoClient

mqtt = require './lib/mqtt'
processRecord = require './lib/processor'

mongoUrl = process.env.MONGO_URL or 'mongodb://mongo:27017/admin'

MongoClient.connect mongoUrl, (err, db) ->
  if err
    console.error err
  else
    console.log "MONGO: Connected at #{mongoUrl}"
    mqtt.listen (topic, msg) ->
      message = msg.toString()
      record = JSON.parse message
      console.log "MQTT: MESSAGE RECEIVED ON TOPIC #{topic}: #{message}"
      processRecord db, record
