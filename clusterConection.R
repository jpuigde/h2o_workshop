library(h2o)

(h2oCluster <- h2o.init(ip = read.csv("flatfile.txt",header = F,sep = ":",stringsAsFactors = F)[1,1] ,port =54321 ))
