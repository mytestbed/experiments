# This extremely simple experiment ask a resource to run the /bin/date 
# command (which should be installed by default on all linux-based 
# resources)
# The ID of the resource to use is set via the parameter 'resource'
#
# At the end of the experiment, we explicitly ask the resource to leave the
# experiment ('leave_memberships') before shutting it down ('done').
# 
# This would be typically run using a command similar to:
# omf_ec -u amqp://your.server.net check_date.rb  -- --resource my_resource

defProperty('resource', 'foo', 'ID of a resource')

defGroup('Actor', prop.resource)

onEvent(:ALL_UP) do 
  after 2 do
    info ">>>>>>> Ask Resource #{prop.resource} for its date..."
    group("Actor").exec("/bin/date")
  end
  after 5 do
    Experiment.done
  end
end
