loadOEDL('http://goo.gl/4br2MW') #latex:\label{lst:test-sync:load-begin}
loadOEDL('http://goo.gl/qg8Alo')
# From the trace-oml2 package
loadOEDL('file:///usr/share/trace-oml2/trace.rb')#latex:\label{lst:test-sync:load-end}

defProperty('entity1','node20','1st entity ID') #latex:\label{lst:test-sync:prop-begin}
defProperty('entity2','node21','2nd entity ID')
defProperty('source','node19','Event source ID')
defProperty('time',180*60,'Trial duration [s]') #latex:\label{lst:test-sync:prop-end}

defGroup('Entities',prop.entity1,prop.entity2) do |g| #latex:\label{lst:test-sync:entities-begin}
  # Capture ICMP echo packets
  g.addApplication('trace') do |app| #latex:\label{lst:test-sync:trace}
    app.setProperty('filter', 'icmp[icmptype]=icmp-echo')
    app.setProperty('interface', 'eth1')
    app.measure('ethernet', :samples => 1) #latex:\label{lst:test-sync:measure-ethernet}
  end
end #latex:\label{lst:test-sync:entities-end}

defGroup('Source',prop.source) do |g| #latex:\label{lst:test-sync:source-begin}
  # Broadcast ICMP echo requests every 10s
  g.addApplication('ping') do |app| #latex:\label{lst:test-sync:ping}
    app.setProperty('dest_addr', '10.0.0.255') #latex:\label{lst:test-sync:pingbroadcast}
    app.setProperty('broadcast', true)
    app.setProperty('interval', 10)
    app.setProperty('quiet', true)
    app.measure('ping', :samples => 1) #latex:\label{lst:test-sync:measure-ping}
  end
end #latex:\label{lst:test-sync:source-end}

defGroup('All',prop.source,  #latex:\label{lst:test-sync:all-begin}
          prop.entity1,prop.entity2) do |g| 
  # Report time synchronisation every minute
  g.addApplication('ntpq') do |app| #latex:\label{lst:test-sync:ntpq}
    app.setProperty('loop-interval', 60)
    app.setProperty('quiet', true)
    app.measure('ntpq', :samples => 1) #latex:\label{lst:test-sync:measure-ntpq}
  end
end #latex:\label{lst:test-sync:all-end}

onEvent(:ALL_UP_AND_INSTALLED) do #latex:\label{lst:test-sync:experiment-begin} 
  group('All').startApplications
  group('Entities').startApplications
  group('Source').startApplications
  after prop.time do
    allGroups.stopApplications
    Experiment.done
  end
end #latex:\label{lst:test-sync:experiment-end}

