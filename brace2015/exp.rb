# Copyright (c) 2015 National ICT Australia Limited (NICTA).
# Thierry.Rakotoarivelo@nicta.com.au
#
# This is the OMF6 OEDL script to run the experiment from the Brace 2015 paper
#
# omf_ec -u amqp://srv.mytestbed.net --oml_uri tcp:10.0.0.200:3003 exp.rb --
# --result_prefix bar --any_other_experiment_property foo
#

################################################################################
#
# STEP 0 - Load the declaration of the Applications used in this experiment
#
loadOEDL("file:///home/thierry/experiments/rv2015/nmetrics.oedl")
loadOEDL("file:///home/thierry/experiments/rv2015/brace_apps.oedl")

################################################################################
#
# STEP 1 - Declare the variables (aka properties) for this experiment
#

# set = 1 -> run exp with nodes 1, 2, 3, 4
# set = 2 -> run exp with nodes 5, 6, 7, 8
# set = 3 -> run exp with nodes 9, 10, 11, 12
# set = 4 -> run exp with nodes 14, 15, 16, 17
defProperty('set', '1', 'Group number for this experiment')
defProperty('result_prefix', 'foo', 'Prefix for directory storing the results')
defProperty('use_global_monitor', 'true', 'Use or not a Global Monitor in this experiment, true (default) / false')
defProperty('task_issuer_load', 1, 'Number of iteration for assigning task. Each iteration has 4 tasks, e.g assign 1 for 4 tasks, 12 for 48 tasks, 96 for 384 tasks, 768 for 3072 tasks')
defProperty('mqtt_port', 1883, 'MQTT Port')
defProperty('global_error_number', 0, 'Number of injected glocal errors')
defProperty('master_name', 'Police', 'Name of the Master Agent')
defProperty('master_x', 40, 'X position of the Master Agent')
defProperty('master_y', 100, 'Y position of the Master Agent')
defProperty('task_number', 0, 'Number of injected local events per second (master agent only)')
defProperty('local_error_number', 0, 'Number of injected local errors (master agent only)')
defProperty('specification', '1LocalSpec', 'Specification to use, either 1LocalSpec (default) 1GlobalSpec 2GlobalSpecs  2LocalSpecs  3GlobalSpecs  3LocalSpecs  NoSpec')
defProperty('slave_name', 'Ambulance', 'Name of the Slave Agent')
defProperty('slave_x', 80, 'X position of the Slave Agent')
defProperty('slave_y', 200, 'Y position of the Slave Agent')

outpath = "#{property.result_prefix}_#{Time.now.to_i}"

all_nodes = case property.set.to_s
   when '1' then ['node1','node2','node3','node4']
   when '2' then ['node5','node6','node7','node8']
   when '3' then ['node9','node10','node11','node12']
   when '4' then ['node14','node15','node16','node17']
end

################################################################################
#
# STEP 2 - Define the groups of resources and their associated applications and
# configurations
#

defGroup('All_Resources', *all_nodes) do |g|
  g.addApplication("nmetrics") do |a|
    a.setProperty('cpu', true)
    a.setProperty('memory', true)
    a.setProperty('interface0', 'eth0')
    a.setProperty('sample-interval', 1)
    a.measure('cpu', :samples => 1)
    a.measure('memory', :samples => 1)
    a.measure('network', :samples => 1)
  end
end

all_nodes.each_index do |i|
  defGroup("Peer_#{i}", all_nodes[i])
end

defGroup('MQTT_Broker',all_nodes[0]) do |g|
  g.addApplication("mqtt")
end

defGroup('Task_Issuer',all_nodes[0]) do |g|
  g.addApplication("taskissuer") do |a|
    a.setProperty('mqtt_addr', "192.168.#{property.set.to_s}.100")
    a.setProperty('mqtt_port', property.mqtt_port)
    a.setProperty('task_load', property.task_issuer_load)
  end
end

defGroup('Global_Monitor',all_nodes[1]) do |g|
  g.addApplication("globalmonitor") do |a|
    a.setProperty('mqtt_addr', "192.168.#{property.set.to_s}.100")
    a.setProperty('mqtt_port', property.mqtt_port)
    a.setProperty('error_number', property.global_error_number)
  end
end

defGroup('Master_Agent',all_nodes[2]) do |g|
  g.addApplication("agent") do |a| # also known internally as "agent_cxt_0"
    a.setProperty('name', property.master_name)
    a.setProperty('is_master', 'true')
    a.setProperty('x', property.master_x)
    a.setProperty('y', property.master_y)
    a.setProperty('mqtt_addr', "192.168.#{property.set.to_s}.100")
    a.setProperty('mqtt_port', property.mqtt_port)
    a.setProperty('task_number', property.task_number)
    a.setProperty('error_number', property.local_error_number)
    a.setProperty('slave_name', property.slave_name)
    a.setProperty('specification', property.specification)
  end
end

defGroup('Slave_Agent',all_nodes[3]) do |g|
  g.addApplication("agent") do |a| # also known internally as "agent_cxt_1"
    a.setProperty('name', property.slave_name)
    a.setProperty('is_master', 'false')
    a.setProperty('x', property.slave_x)
    a.setProperty('y', property.slave_y)
    a.setProperty('mqtt_addr', "192.168.#{property.set.to_s}.100")
    a.setProperty('mqtt_port', property.mqtt_port)
    a.setProperty('specification', property.specification)
  end
end

################################################################################
#
# STEP 3 - Define the sequence of tasks to perform when all the nodes are up
#

onEvent(:ALL_UP) do
  info ">>>>>>> USING NODE SET: #{all_nodes.to_s}"
  after 2 do
    info ">>>>>>> NETWORK SETUP + SOME CLEANUP"
    all_nodes.each_index do |i|
      group("Peer_#{i}").exec("/sbin/ifconfig eth0 192.168.#{property.set.to_s}.#{100+i} netmask 255.255.0.0 up")
    end
    group("Peer_1").exec("/bin/rm -f /root/GlobalMonitorNode/GlobalMonitorResult*")
    group("Peer_2").exec("/bin/rm -f /root/RoverAgent/LocalMonitorResult*")
    group("Peer_3").exec("/bin/rm -f /root/RoverAgent/LocalMonitorResult*")
  end

  after 4 do
    info ">>>>>>> COLLECT SYSTEM STATS"
    group('All_Resources').startApplications
  end

  after 6 do
    info ">>>>>>> MQTT STARTUP"
    group('MQTT_Broker').startApplications
  end

  after 10 do
    info ">>>>>>> TASK ISSUER STARTUP"
    group('Task_Issuer').startApplications
  end

  if (property.use_global_monitor.to_s == 'true')
    after 12 do
      info ">>>>>>> GLOBAL MONITOR STARTUP"
      group('Global_Monitor').startApplications
    end
  end

  after 14 do
    info ">>>>>>> MASTER AGENT STARTUP"
    group('Master_Agent').startApplications
  end

  after 16 do
    info ">>>>>>> SLAVE AGENT STARTUP"
    group('Slave_Agent').startApplications
  end
end

################################################################################
#
# STEP 4 - Define the condition that will stop this experiment
#

defEvent :APP_EXITED do |state|
  triggered = false
  state.each do |resource|
    # Trigger this event when the application  'agent_cxt_0' is stopped
    triggered = true if (resource.type == 'application') && (resource.app == 'agent_cxt_0') && (resource.state == 'stopped')
  end
  triggered
end

################################################################################
#
# STEP 5 - Define the sequence of tasks to perform when the stopping conditions
# are fulfilled
#

onEvent :APP_EXITED do
  info ">>>>>>> MASTER AGENT APPLICATION STOPPED"
  # Stop all applications
  allGroups.stopApplications
  after 10 do
    info ">>>>>>> COLLECTING LOCAL FILES IN #{outpath}"
    # Collect local result files from each node
    r = `mkdir #{outpath}`
    r = `mkdir #{outpath}/task_issuer`
    r = `scp -o StrictHostKeyChecking=no root@#{all_nodes[0]}:/tmp/mqtt.log #{outpath}/task_issuer/`
    r = `scp -o StrictHostKeyChecking=no root@#{all_nodes[0]}:/tmp/taskissuer.log #{outpath}/task_issuer/`
    if (property.use_global_monitor.to_s == 'true')
      r = `mkdir #{outpath}/global_monitor`
      r = `scp -o StrictHostKeyChecking=no root@#{all_nodes[1]}:/root/GlobalMonitorNode/GlobalMonitorResult* #{outpath}/global_monitor/`
      r = `scp -o StrictHostKeyChecking=no root@#{all_nodes[1]}:/tmp/globalmonitor.log #{outpath}/global_monitor/`
    end
    r = `mkdir #{outpath}/master_agent`
    r = `mkdir #{outpath}/slave_agent`
    r = `scp -o StrictHostKeyChecking=no root@#{all_nodes[2]}:/root/RoverAgent/LocalMonitorResult* #{outpath}/master_agent/`
    r = `scp -o StrictHostKeyChecking=no root@#{all_nodes[2]}:/tmp/agent.log #{outpath}/master_agent/`
    r = `scp -o StrictHostKeyChecking=no root@#{all_nodes[3]}:/root/RoverAgent/LocalMonitorResult* #{outpath}/slave_agent/`
    r = `scp -o StrictHostKeyChecking=no root@#{all_nodes[3]}:/tmp/agent.log #{outpath}/slave_agent/`
    # Collect the database with the System Stats (cpu,mem,...)
    r = `cp /var/lib/oml2/#{Experiment.ID}.sq3 #{outpath}/`
    # Dump in a txt file the set of parameters used in this experiment
    f = File.open("#{outpath}/exp_parameters.txt", 'w')
    f << "- nodes : #{all_nodes.to_s}\n"
    property.each do |p|
      f << "- #{p.name} : #{p.value}\n"
    end
    f.close
    # Now Reset all controllers so that we start 'fresh' next time
    info ">>>>>>> RC RESET"
    all_nodes.each_index do |i|
      group("Peer_#{i}").exec("/etc/init.d/omf_rc restart")
    end
    after 15 do
      Experiment.done
    end
  end
end