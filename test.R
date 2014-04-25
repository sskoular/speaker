args <- commandArgs(trailingOnly = TRUE)
k = type.convert(args[1])
cat(seq(1,k))
data = read.csv(args[2], header = FALSE)

head(data)