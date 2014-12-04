# This extends check_date to ask for resource date repeatedly
#
defProperty('resource', 'foo', 'ID of a resource')

defGroup('bob', property.resource)

onEvent(:ALL_UP) do |event|
  # Timer is specified in seconds
  every 5 do
    info '>>> Every 5 secs'
    group('bob').exec('/bin/date')
  end

  # You can make it clear that it is in seconds
  every 7.seconds do
    info '>>> Every 7 secs'
    group('bob').exec('/bin/date')
  end

  # You can use minutes too
  every 2.minutes do
    info '>>> Every 2 mins'
    group('bob').exec('/bin/date')
  end

  # It will run for 10 mins
  # You could also stop this experiment by sending term signal (ctrl+c)
  after 10.minutes do
    Experiment.done
  end
end

# Timer can be placed anywhere,
# but normally placing it inside onEvent callback makes more sense
#
after 1.day do
  warn 'I suppose you will not wait enough time to see this'
end
