mqtt = require 'mqtt'

mqttUrl = process.env.MQTT_URL or 'mqtt://mqtt:1883'
mqttConnOptions =
  mqttClientId: process.env.MQTT_CLIENT_ID or 'fleetr_eu'

mqttTopic = process.env.MQTT_TOPIC or '/fleetr/traccar-records'
mqttSubOptions = {}
mqttSubOptions[mqttTopic] = 1 #subscribe at QoS level 1

exports.listen = (onMessage) ->
  console.log """
    MQTT:
      URL #{mqttUrl}
      Connection options #{JSON.stringify mqttConnOptions}
  """
  client = mqtt.connect mqttUrl, mqttConnOptions

  client.on 'error', (err) ->
    console.error "MQTT ERROR: #{err}"

  client.on 'connect', ->
    console.log 'MQTT CONNECTED OK'
    client.subscribe mqttSubOptions, (err, granted) ->
      if err
        console.error "MQTT ERROR: #{err}"
      else
        console.log 'MQTT SUBSCRIBED: ' + JSON.stringify(granted)

  client.on 'disconnect', -> console.log '*** MQTT DISCONNECTED'

  client.on 'message', onMessage
