library("RSQLite")
args<-commandArgs(TRUE)

name_prefix = 'node'
master_index_list = c(3,7,11,16,30,22,35)
slave_index_list = c(4,8,12,17,32,26,36)
q1 = "_senders.name LIKE '%"
q2 = "_nmetrics_cxt%'"
master_query_list = paste0( paste0(q1, paste0(name_prefix,master_index_list), q2), collapse=' or ' )
slave_query_list = paste0( paste0(q1, paste0(name_prefix,slave_index_list), q2), collapse=' or ' )

plot.cpu <- function(db) {
  library("RSQLite")
  con <- dbConnect(dbDriver("SQLite"), dbname=db)
  query = paste0(
    "SELECT * FROM nmetrics_cpu JOIN _senders WHERE oml_sender_id=_senders.id ",
    "AND (",master_query_list,")"
  )
  name =  unlist(strsplit(db,'.sq3'))
  cpu = dbGetQuery(con, query)
  pdf(file=paste0(name,'.cpu.pdf'), width=7,height=7)
  y=(diff(cpu$user)/diff(cpu$total))
  x=(cpu$oml_ts_client)[1:length(y)]
  plot(
    x=x, y=y, t='l',
    xlab='Time [s]',
    ylab="User CPU [%]",
    main=name
  )
  dev.off()
  dbDisconnect(con)
  d = data.frame(
    time=x,
    cpu_user_percent=y,
    cpu_sys_percent=(diff(cpu$sys)/diff(cpu$total))
  )
  write.csv(d,file=paste0(name,'.cpu.csv'))
}

plot.mem <- function(db) {
  library("RSQLite")
  con <- dbConnect(dbDriver("SQLite"), dbname=db)
  query = paste0(
    "SELECT * FROM nmetrics_memory JOIN _senders WHERE oml_sender_id=_senders.id ",
    "AND (",master_query_list,")"
  )
  name =  unlist(strsplit(db,'.sq3'))
  mem = dbGetQuery(con, query)
  pdf(file=paste0(name,'.mem.pdf'), width=7,height=7)
  x=mem$oml_ts_client
  y=mem$actual_used
  plot(
    x=x, y=y, t='l',
    xlab='Time [s]',
    ylab="Actual Used Memory [B]",
    main=name
  )
  dev.off()
  dbDisconnect(con)
  d = data.frame(
    time=x,
    total_byte=mem$total,
    actual_used_byte=mem$actual_used,
    actual_free_byte=mem$actual_free
  )
  write.csv(d,file=paste0(name,'.mem.csv'))
}

plot.net <- function(db) {
  library("RSQLite")
  con <- dbConnect(dbDriver("SQLite"), dbname=db)
  query = paste0(
    "SELECT * FROM nmetrics_network JOIN _senders WHERE oml_sender_id=_senders.id ",
    "AND (",master_query_list,")"
  )
  name =  unlist(strsplit(db,'.sq3'))
  net = dbGetQuery(con, query)
  pdf(file=paste0(name,'.net.rx.pdf'), width=7,height=7)
  x=net$oml_ts_client
  y=net$rx_bytes
  plot(
    x=x, y=y, t='l',
    xlab='Time [s]',
    ylab="Received Traffic [B]",
    main=name
  )
  dev.off()
  pdf(file=paste0(name,'.net.tx.pdf'), width=7,height=7)
  y=net$tx_bytes
  plot(
    x=x, y=y, t='l',
    xlab='Time [s]',
    ylab="Transmitted Traffic [B]",
    main=name
  )
  dev.off()
  dbDisconnect(con)
  d = data.frame(
    time=x,
    rx_bytes=net$rx_bytes,
    rx_packet=net$rx_packets,
    tx_bytes=net$tx_bytes,
    tx_packet=net$tx_packets
  )
  write.csv(d,file=paste0(name,'.net.csv'))
}

# extract_all <- function(db) {
db = args[1]
plot.cpu(db)
plot.mem(db)
plot.net(db)
# }
