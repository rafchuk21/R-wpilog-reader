library(reticulate)
library(purrr)

py_require("msgpack")
datalog_reader <- import("datalog")
d <- datalog_reader$read_wpilog("EM12.wpilog")

signals <- d$signals
values <- d$values

names(signals) <- sapply(signals, function(s) s$name)

# Expand raw Pose2D data into (x, y, angle) arrays
pose2d_signals <- signals[lapply(signals, function(s) s$type == 'struct:Pose2d') == TRUE]
for (sig in names(pose2d_signals)) {
  val <- values[[sig]]
  for (timestamp in names(val)) {
    raw_data <- as.raw(val[[timestamp]])
    raw_data_bin_array <- rawToBits(raw_data)
    double_list <- packBits(raw_data_bin_array[1:64 + 64*(rep(c(1,2,3)-1, each=64))], "double")
    double_list <- as.list(double_list)
    names(double_list) <- c("x", "y", "angle")
    values[[sig]][[timestamp]] <- double_list
  }
}