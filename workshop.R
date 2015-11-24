# The following two commands remove any previously installed H2O packages for R.
if ("package:h2o" %in% search()) { detach("package:h2o", unload=TRUE) }
if ("h2o" %in% rownames(installed.packages())) { remove.packages("h2o") }

# Next, we download packages that H2O depends on.
if (! ("methods" %in% rownames(installed.packages()))) { install.packages("methods") }
if (! ("statmod" %in% rownames(installed.packages()))) { install.packages("statmod") }
if (! ("stats" %in% rownames(installed.packages()))) { install.packages("stats") }
if (! ("graphics" %in% rownames(installed.packages()))) { install.packages("graphics") }
if (! ("RCurl" %in% rownames(installed.packages()))) { install.packages("RCurl") }
if (! ("jsonlite" %in% rownames(installed.packages()))) { install.packages("jsonlite") }
if (! ("tools" %in% rownames(installed.packages()))) { install.packages("tools") }
if (! ("utils" %in% rownames(installed.packages()))) { install.packages("utils") }

# Now we download, install and initialize the H2O package for R.
install.packages("h2o", type="source", repos=(c("http://h2o-release.s3.amazonaws.com/h2o/rel-slater/8/R")))
library(h2o)
localH2O = h2o.init()

# We can shutdown the instance whenever we want.
h2o.shutdown(client = localH2O,prompt = F)

# and start it again!!!
localH2O <- h2o.init(ip = "127.0.0.1",port = 54321,max_mem_size ="4g",nthreads = 4 )
# get his information or reconect to it
h2o.clusterInfo(localH2O)
rm(localH2O)
localH2O <- h2o.getConnection()


# Finally, let's run a demo to see H2O at work.
demo(h2o.kmeans)
demo(h2o.glm)
demo(h2o.gbm)
demo(h2o.randomForest)
demo(h2o.deeplearning)

h2o.randomForest()

# http://h2o-release.s3.amazonaws.com/h2o/rel-slater/8/docs-website/h2o-docs/booklets/R_Vignette.pdf
# http://www.stat.berkeley.edu/~ledell/R/h2oEnsemble.pdf



# Creating Aggregates from Split Data-----
# Import iris dataset to H2O
irisPath = system.file("extdata", "iris_wheader.csv", package = "h2o")
iris.hex = h2o.importFile(localH2O, path = irisPath,destination_frame = "iris.hex")
class(iris.hex)

# Apply function to groups by class of flower
# uses h2o’s ddply, since iris.hex is an H2OParsedData object
res = h2o.ddply(iris.hex, "class", function(df) { sum(df[,1], na.rm = T)/nrow(df) })
res

# DEMO - GLM----
# Import dataset and display summary
airlinesURL = "https://s3.amazonaws.com/h2o-airlines-unpacked/allyears2k.csv"
airlines.hex = h2o.importFile(localH2O, path = airlinesURL,destination_frame="airlines.hex")
h2o.ls(localH2O)
summary(airlines.hex)

# Define columns to ignore, quantiles and histograms
# h2o.ignoreColumns
airlines.hex[,as.data.frame(apply(is.na(airlines.hex),2,sum)==0)==1]

delay_quantiles = quantile(x = airlines.hex$ArrDelay, na.rm = TRUE)
h2o.hist(airlines.hex$ArrDelay)

# Find number of flights by airport
originFlights = h2o.ddply(airlines.hex, 'Origin', nrow)
originFlights.R = as.data.frame(originFlights)
h2o.hist(airlines.hex$Month)

# Find number of cancellations per DayofMonth
flightsByMonth = h2o.ddply(airlines.hex,"DayofMonth", nrow)
cancellationsByMonth = h2o.ddply(airlines.hex,"DayofMonth", function(x,y){sum(x[,"Cancelled"]) })
flightsByMonth.R = as.data.frame(flightsByMonth)
cancellationsByMonth.R = as.data.frame(cancellationsByMonth)


# Find DayofMonth with the highest cancellation ratio
cancellation_rate = cancellationsByMonth$C1/flightsByMonth$C1
rates_table = h2o.cbind(flightsByMonth, cancellation_rate)
rates_table.R = as.data.frame(rates_table)

# Construct test and train sets using sampling
airlines.split = h2o.splitFrame(data = airlines.hex,ratios = 0.6)
airlines.train = airlines.split[[1]]
airlines.test = airlines.split[[2]]

# Display a summary using table-like functions
h2o.table(airlines.train$Cancelled)
h2o.table(airlines.test$Cancelled)

# Set predictor and response variables
Y = "IsDepDelayed"
X = c("Origin", "Dest", "DepTime", "ArrTime", "Distance")
X = names(airlines.hex[,as.data.frame(apply(is.na(airlines.hex),2,sum)==0)==1])
# Define the data for the model and display the results

for( alpha in seq(0,1,0.1))
{
airlines.gbm <- h2o.gbm(training_frame = airlines.train, x=X, y=Y, distribution = "bernoulli",learn_rate=0.1)
airlines.glm@model$training_metrics@metrics$AUC
perf <- h2o.performance(airlines.glm, airlines.test)
print(paste (alpha,perf@metrics$AUC,airlines.glm@model$training_metrics@metrics$AUC))
}
plot(perf@metrics$thresholds_and_metric_scores$fpr,perf@metrics$thresholds_and_metric_scores$tpr,type="l")

for( depth in seq(4,8,2))
for( trees in seq(0,1,0.1))
for( learn_rate in seq(0,1,0.1))
{{{
airlines.gbm <- h2o.gbm(training_frame = airlines.train, x=X, y=Y, distribution = "bernoulli",learn_rate=learn_rate,max_depth = depth,ntrees = trees)
airlines.gbm@model$training_metrics@metrics$AUC
perf <- h2o.performance(airlines.gbm, airlines.test)
perf@metrics$AUC
print(paste (alpha,perf@metrics$AUC,airlines.glm@model$training_metrics@metrics$AUC))
}}}

require(glmnet)






