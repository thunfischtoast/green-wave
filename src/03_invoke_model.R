# This script reads a XGB-Model (created my 02_predict.Rmd) from model.Rds and 
# reads input parameters from the arguments and applies the parameters to the model.

# format: 
# [1] "hour" "minute" "lag1_other" "lag1_same" "lag2_other" "lag2_same"
# [7] "lag3_other" "lag3_same" "lag4_other" "lag4_same" "status_enc" 

library(xgboost)

args = commandArgs(trailingOnly = FALSE)
# print(length(args))

model_path = args[4]
model_path = dirname(dirname(gsub("--file=", "", model_path)))
model_path = paste0(model_path, "/model.Rds")

model <- readRDS(file = model_path)

model_args = args[6:16]
model_args = model_args[!is.na(model_args)]

# convert and validate input
stopifnot(length(model_args) == 11)
hour = as.numeric(model_args[1])
stopifnot(!is.na(hour), hour >= 0, hour <= 23)
minute = as.numeric(model_args[2])
stopifnot(!is.na(minute), minute >= 0, minute <= 59)
is_day = (hour >= 6 & hour <= 20)
is_rushhour = hour %in% c(8, 15, 16)

lag1_other = as.numeric(model_args[3])
stopifnot(!is.na(lag1_other))
lag1_same = as.numeric(model_args[4])
stopifnot(!is.na(lag1_same))
lag2_other = as.numeric(model_args[5])
stopifnot(!is.na(lag2_other))
lag2_same = as.numeric(model_args[6])
stopifnot(!is.na(lag2_same))
lag3_other = as.numeric(model_args[7])
stopifnot(!is.na(lag3_other))
lag3_same = as.numeric(model_args[8])
stopifnot(!is.na(lag3_same))
lag4_other = as.numeric(model_args[9])
stopifnot(!is.na(lag4_other))
lag4_same = as.numeric(model_args[10])
stopifnot(!is.na(lag4_same))

status_enc = as.numeric(model_args[11])
stopifnot(!is.na(status_enc), status_enc %in% c(0, 1))

# print(model_args)

# model input 
# [1] "hour"        "minute"      "is_day"      "is_rushhour" "lag1_other"  "lag1_same"  
# [7] "lag2_other"  "lag2_same"   "lag3_other"  "lag3_same"   "lag4_other"  "lag4_same"  
# [13] "status_enc" 
# sample input: X = c(15, 2, TRUE, TRUE, 3, 4, 5, 6, 7, 8, 9, 10, 0)

X = c(hour, 
      minute, 
      is_day, 
      is_rushhour, 
      lag1_other, 
      lag1_same, 
      lag2_other, 
      lag2_same, 
      lag3_other,
      lag3_same, 
      lag4_other, 
      lag4_same
)
dmatrix <- xgb.DMatrix(t(as.matrix(X)))
print(paste0("result=",predict(model, dmatrix)))
