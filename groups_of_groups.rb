# This simple experiment extends the check_date experiment [1], and
# illustrate the syntax to use groups of groups.
# All the rest is similar to the check_date experiment [1].
# 
# [1] https://raw.githubusercontent.com/mytestbed/experiments/master/check_date.rb

defProperty('node', "unconfigured-node-1", "ID of a node")

defGroup('Blue', property.node)
defGroup('Yellow', property.node)
defGroup('Green', 'Blue', 'Yellow')

onEvent(:ALL_UP) do |event|
  after 2 do
    info ">>>>>> Blue Group"
    group("Blue").exec("/bin/date")
  end
  after 4 do
    info ">>>>>> Yellow Group"
    group("Yellow").exec("/bin/date")
  end
  after 6 do
    info ">>>>>> Green Group, i.e. a group made of other groups"
    group("Green").exec("/bin/date")
  end
  after 8 do
    Experiment.done
  end
end
