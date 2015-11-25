
# remove any previously installed H2O packages for R
# if ("package:h2o" %in% search()) { detach("package:h2o", unload=TRUE) }
# if ("h2o" %in% rownames(installed.packages())) { remove.packages("h2o") }

# needs java
# sudo apt-get update
# sudo apt-get install default-jdk -y


# ------------------------------------------------
if (! ("methods"  %in% rownames(installed.packages()))) { install.packages("methods") }
if (! ("statmod"  %in% rownames(installed.packages()))) { install.packages("statmod") }
if (! ("stats"    %in% rownames(installed.packages()))) { install.packages("stats")   }
if (! ("graphics" %in% rownames(installed.packages()))) { install.packages("graphics")}
if (! ("RCurl"    %in% rownames(installed.packages()))) { install.packages("RCurl")   }
# needs libcurl-dev
# sudo apt-get install libcurl14-openssl-dev
if (! ("jsonlite" %in% rownames(installed.packages()))) { install.packages("jsonlite")}
if (! ("tools"    %in% rownames(installed.packages()))) { install.packages("tools")   }
if (! ("utils"    %in% rownames(installed.packages()))) { install.packages("utils")   }

# ------------------------------------------------
install.packages("h2o", type="source", repos=(c("http://h2o-release.s3.amazonaws.com/h2o/rel-tibshirani/3/R")))
library(h2o)


## ----echo=FALSE,fig.width=6.8--------------------------------------------
h2o.init()

## ----fig.width=6.8-------------------------------------------------------
h2o.shutdown(prompt = FALSE)


## ----fig.width=6.8-------------------------------------------------------
h2o.init(ip = "127.0.0.1",port = 54321,max_mem_size ="4g",nthreads = 4 )

## ----fig.width=6.8-------------------------------------------------------
h2o.clusterInfo()
localH2O <- h2o.getConnection()

## ----results='hide',fig.width=6.8----------------------------------------
airlinesURL = "https://s3.amazonaws.com/h2o-airlines-unpacked/allyears2k.csv"

airlines.hex = h2o.importFile( path = airlinesURL,destination_frame="airlines.hex" )

## ----fig.width=6.8-------------------------------------------------------
head( airlines.hex , 3 )[1:10]

## ----fig.width=6.8-------------------------------------------------------
h2o.ls()

## ----fig.width=6.8-------------------------------------------------------
dim( airlines.hex )
summary( airlines.hex )[1:4]
quantile( airlines.hex$Distance )

## ------------------------------------------------------------------------
h2o.hist( airlines.hex$Distance )

## ----fig.width=6.8,fig.height=4------------------------------------------
(airlines.hex$IsDepDelayed <- as.factor(airlines.hex$IsDepDelayed ))[1:10]
(MeanOfCancelFlightDOW <- h2o.ddply(airlines.hex, "DayOfWeek", function(x){ mean( x[,12] ) }))

## ----results='hide',fig.width=6.8----------------------------------------
airlines.split = h2o.splitFrame(data = airlines.hex,ratios = 0.6)
airlines.train = airlines.split[[1]]
airlines.test  = airlines.split[[2]]


## ----fig.width=6.8-------------------------------------------------------
dim(airlines.hex)
dim(airlines.train)
dim(airlines.test)

## ----results='hide',fig.width=6.8----------------------------------------
features <- c("Year","Month","DayofMonth","DayOfWeek","Origin","Dest","Distance","DepTime")
target <- "IsDepDelayed"

model <- h2o.glm(x = features ,
                 y= target ,
                 training_frame = airlines.train ,
                 validation_frame = airlines.test ,
                 family = "binomial" )

# ----eval=F,fig.width=6.8------------------------------------------------
model@algorithm
model@parameters
model@allparameters
model@model
model@model$training_metrics
model@model$validation_metrics
model@model$start_time
model@model$end_time
model@model$run_time
model@model$help

# ----fig.width=6.8-------------------------------------------------------
model@model$validation_metrics

# ----fig.width=6.8-------------------------------------------------------
perf.test <- h2o.performance(model,data = airlines.test)
auc.test  <- h2o.auc(perf.test)
auc.test

# ----fig.width=6.8-------------------------------------------------------
fpr <- perf.test@metrics$thresholds_and_metric_scores$fpr
tpr <- perf.test@metrics$thresholds_and_metric_scores$tpr
plot(fpr,tpr,type="l")

# ----fig.width=6.8-------------------------------------------------------
prediction.test <- h2o.predict(object =model,newdata =airlines.test)
head(prediction.test)

# ----eval=FALSE,fig.width=6.8--------------------------------------------
if (! ("h2oEnsemble"  %in% rownames(installed.packages()))) { devtools::install_github("h2oai/h2o-2/R/ensemble/h2oEnsemble-package") }

## ----fig.width=6.8-------------------------------------------------------
library(h2oEnsemble)

## ---- ,results='hide', fig.width = 6.8-----------------------------------
learner <- c("h2o.deeplearning.wrapper", "h2o.glm.wrapper")
metalearner <- c("h2o.gbm.wrapper")

fit <- h2o.ensemble(x = features ,y= target, training_frame = airlines.train, family = "binomial", 
                    learner = learner, metalearner = metalearner,
                    cvControl = list(V=4))

## ----fig.width=6.8-------------------------------------------------------
fit
pred <- predict(fit, airlines.test)
labels <- ifelse(as.data.frame(airlines.test[,c(target)])[,1]=="YES",1,0)

## ----fig.width=6.8-------------------------------------------------------
cvAUC::AUC(predictions=as.data.frame(pred$pred[,3]), labels=labels)
sapply(1:length(learner), function(l) cvAUC::AUC(predictions = as.data.frame(pred$basepred)[,l], labels = labels))

# ----eval=FALSE,fig.width=6.8--------------------------------------------
demo(h2o.kmeans)
demo(h2o.glm)
demo(h2o.gbm)
demo(h2o.randomForest)
demo(h2o.deeplearning)

showMethods(classes="H2OFrame")

