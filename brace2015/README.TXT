# Copyright (c) 2015 National ICT Australia Limited (NICTA).
# Thierry.Rakotoarivelo@nicta.com.au
#

This directory contains the OEDL and R scripts to run the BRACE 2015 experiment
and export its result to CSV.

To run the experiment on a OMF6-enabled testbed with the BRACE middleware
installed on the nodes:

omf_ec -u amqp://your_amqp_server --oml_uri tcp:your_oml_server:3003 exp.oedl
-- --result_prefix test --use_global_monitor true etc...

(the list of all experiment parameters are described at the beginning of the
exp.oedl file)

To export the results in foo/bar.sq3 to CSV:

Rscript analysis.r foo/bar.sq3



