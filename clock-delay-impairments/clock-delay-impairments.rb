loadOEDL('http://goo.gl/4br2MW') #latex:\label{lst:test-sync:load-begin}
loadOEDL('http://goo.gl/qg8Alo')
# From the trace-oml2 package
loadOEDL('file:///usr/share/trace-oml2/trace.rb')#latex:\label{lst:test-sync:load-end}

defProperty('impaired','node20','Impaired entity ID') #latex:\label{lst:test-sync:prop-begin}
defProperty('unimpaired','node21','Unimpaired entity ID')
defProperty('source','node19','Event source ID')
defProperty('clockoffset',0,'Static clock impairment [s]')
defProperty('clockoffset_inc',0,'Incremental clock impairment [s/s]')
defProperty('netdelay',0,'Static network delay [s]')
defProperty('netdelay_inc',0,'Incremental network delay [s/s]')
defProperty('time',180*60,'Trial duration [s]') #latex:\label{lst:test-sync:prop-end}

# Inject metadata about the experiment through the EC's OML4R
# XXX
# ExperimentMetadata.inject_metadata "impaired" prop.impaired
# ExperimentMetadata.inject_metadata "unimpaired" prop.unimpaired
# ExperimentMetadata.inject_metadata "source" prop.source
# ExperimentMetadata.inject_metadata "clockoffset" prop.clockoffset
# ExperimentMetadata.inject_metadata "clockoffset_inc" prop.clockoffset_inc
# ExperimentMetadata.inject_metadata "netdelay" prop.netdelay
# ExperimentMetadata.inject_metadata "netdelay_inc" prop.netdelay_inc
# ExperimentMetadata.inject_metadata "duration" prop.time

defGroup('Entities',prop.impaired,prop.unimpaired) do |g| #latex:\label{lst:test-sync:entities-begin}
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
          prop.impaired,prop.unimpaired) do |g|
  # Report time synchronisation every minute
  g.addApplication('ntpq') do |app| #latex:\label{lst:test-sync:ntpq}
    app.setProperty('loop-interval', 60)
    app.setProperty('quiet', true)
    app.measure('ntpq', :samples => 1) #latex:\label{lst:test-sync:measure-ntpq}
  end
end #latex:\label{lst:test-sync:all-end}

onEvent(:ALL_UP_AND_INSTALLED) do #latex:\label{lst:test-sync:experiment-begin} 

  # Configure static delays
  if prop.clockoffset != 0
	  info "Setting clock offset of #{prop.clockoffset} on #{prop.impaired}"
	  # XXX do it
  end

  if prop.netdelay != 0
	  info "Setting network delay of #{prop.netdelay} between #{prop.impaired} and collection point"
	  # XXX do it
  end

  group('All').startApplications
  group('Entities').startApplications
  group('Source').startApplications

  if prop.clockoffset_inc != 0
	  info "Adding clock offset of #{prop.clockoffset} on #{prop.impaired}"
	  # XXX do it
  end

  if prop.netdelay_inc != 0
	  info "Adding network delay of #{prop.netdelay} between #{prop.impaired} and collection point"
	  # XXX do it
  end

  after prop.time do
    allGroups.stopApplications
    Experiment.done
  end
end #latex:\label{lst:test-sync:experiment-end}

