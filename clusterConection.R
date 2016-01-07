wget https://raw.githubusercontent.com/jpuigde/h2o_workshop/master/AWS_h2o_install.sh
chmod 777 AWS_h2o_install.sh
./AWS_h2o_install.sh

cd h2o-3.6.0.3
wget https://raw.githubusercontent.com/jpuigde/h2o_workshop/master/flatfile.txt

java -Xmx1g -jar h2o.jar -flatfile flatfile.txt -port 54321




cd R/x86_64-pc-linux-gnu-library/3.2/h2o/java
java -jar h2o.jar





library(h2o)

(h2oCluster <- h2o.init(ip = read.csv("flatfile.txt",header = F,sep = ":",stringsAsFactors = F)[1,1] ,port =54321 ))

(h2oCluster <- h2o.init(ip = "52.29.113.214" ,port =54321 ))


