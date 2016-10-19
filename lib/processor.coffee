knotsToKph = (speed) ->
  (speed or 0) * 1.852

processRecord = (db, record) ->
  Vehicles = db.collection 'vehicles'
  Tyres = db.collection 'tyres'
  Logbook = db.collection 'logbook'

  insertInLogbook = (record) ->
    Logbook.insertOne record, ->
      console.log """Inserted logbook record:
        #{JSON.stringify record}
      """

  updateVehicle = (v, rec, updater, cb) ->
    update = updater?()
    console.log "Updating vehicle #{v._id}"
    Vehicles.updateOne {_id: v._id}, {$set: update}, (err) ->
      if err
        console.error "Failed updating vehicle #{v._id}! #{err}"
      else
        cb?(v)

  updateTyres = (v, distance, cb) ->
    console.log "Updating tyres for vehicle #{v._id}"
    Tyres.updateMany {vehicle: v._id, active: true}, {$inc: {usedKm: distance}}, (err) ->
      if err
        console.error "Failed updating tyres of vehicle #{v._id}! #{err}"
      else
        cb?(v)

  record.recordTime = new Date(record.recordTime.$date)
  record.fixTime = new Date(record.fixTime.$date)

  existing =
    deviceId: record.deviceId
    recordTime: record.recordTime
  unless Logbook.find(existing).count()
    console.warn 'Duplicate record received:', existing
  else
    Vehicles.find({unitId: record.deviceId}).limit(1).next (err, v) ->
      if err
        console.error """Error while trying to find vehicle
          with unitId #{record.deviceId}"""
      else
        if v
          record.odometer = if record?.attributes?.odometer
            parseInt record.attributes.odometer
          else
            parseInt(v?.odometer or 0) + parseInt(record?.distance or 0)

          record.speed = knotsToKph(record.speed)
          record.maxSpeed = knotsToKph(record.maxSpeed)
          insertInLogbook record

          updateVehicle v, record, ->
            'trip.id': record.attributes?.trip
            lastUpdate: record.recordTime
            lat: record.lat
            lng: record.lng
            loc: record.loc
            address: record.address
            odometer: record.odometer
            state: record.state
            tripTime: record.attributes?.tripTime
            idleTime: record.attributes?.idleTime
            restTime: record.attributes?.restTime
            speed: record.speed
            course: Math.round(record.course)

          updateTyres v, (record?.distance or 0)
        else
          console.log "No vehicle found with unitId #{record.deviceId}"
          record.odometer = parseInt(record.odometer or 0)
          insertInLogbook record

module.exports = processRecord
