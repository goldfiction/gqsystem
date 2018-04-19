os=require 'os'
ip=require 'ip'
http=require 'http'

Log=""
log=(obj)->
  if !obj
    return Log
  if typeof obj=='object'
    Log+=JSON.stringify(obj,null,2)+"\n"
  else
    Log+=obj+"\n"
  Log

externalIP=(cb)->
  result=""
  http.get 'http://bot.whatismyipaddress.com', (res)->
    res.setEncoding 'utf8'
    res.on 'data', (chunk)->
      result+=chunk
    res.on 'end',()->
      cb null,result

#net = require('net')
#client = net.connect {port: 80, host:"google.com"},() =>
#  console.log('MyIP='+client.localAddress)
#  console.log('MyPORT='+client.localPort)
#

getCPUAverage=(cb)->

  #Create function to get CPU information
  cpuAverage = ()->
    #Initialise sum of idle and time of cores and fetch CPU info
    totalIdle = 0
    totalTick = 0
    cpus = os.cpus()
    #Loop through CPU cores
    i = 0
    len = cpus.length
    while i < len
      #Select CPU core
      cpu = cpus[i]
      #Total up the time in the cores tick
      for type of cpu.times
        `type = type`
        totalTick += cpu.times[type]
      #Total up the idle time of the core
      totalIdle += cpu.times.idle
      i++
    #Return the average Idle and Tick times
    {
    idle: totalIdle / cpus.length
    total: totalTick / cpus.length
    }

  #Grab first CPU Measure
  #Set delay for second Measure
  startMeasure = cpuAverage()

  setTimeout (->
    #Grab second Measure
    endMeasure = cpuAverage()
    #Calculate the difference in idle and total time between the measures
    idleDifference = endMeasure.idle - (startMeasure.idle)
    totalDifference = endMeasure.total - (startMeasure.total)
    #Calculate the average percentage CPU usage
    percentageCPU = 100 - (~ ~(100 * idleDifference / totalDifference))
    #Output result to console
    #console.log percentageCPU + '% CPU Usage.'
    cb null,percentageCPU + '%'
    return
  ), 100

osinfo=(cb)->
  info={}
  externalIP (err, exip)->
    getCPUAverage (err,cpuavg)->
      info["Hostname"]=os.hostname()
      info["OS Type"]=os.type()
      info["OS Platform"]=os.platform()
      info["OS Architecture"]=os.arch()
      info["OS Version"]=os.release()
      info["OS Uptime"]=Math.ceil(os.uptime())
      info["System Load"]=(Math.ceil(os.loadavg()[0]*10000)/100)+"%"
      info["OS Memory"]=Math.floor(os.freemem()/1000000)+"MB / "+Math.floor(os.totalmem()/1000000)+"MB ("+Math.ceil((os.totalmem()-os.freemem())/os.totalmem()*10000)/100+"%)"
      info["OS CPU"]=os.cpus()[0].model+" ("+os.cpus().length+" cores)"
      info["CPU Usage"]=cpuavg
      info["network IP"]=ip.address()
      info["external IP"]=exip
      info["private IP"]=os.networkInterfaces()['lo'][0]['address']
      #log "OS Network: "+JSON.stringify(os.networkInterfaces(),null,2)
      #console.log Log
      if cb
        cb err,info

exports.osinfo=osinfo