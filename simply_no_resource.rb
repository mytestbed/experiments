# This extremely simple experiment does not require any resource at all
# It just makes the experiment controller print an 'INFO' message 
# (e.g. "Hello World! I am foo")
# 
# This would be typically run using a command similar to:
# omf_ec -u amqp://your.server.net simply_no_resource.rb 

defProperty('param_A', 'foo', "Some parameter")

after 1 do
  info "Hello World! I am #{prop.param_A}"
end
after 5 do
  Experiment.done
end
