sudo apt-get update
sudo apt-get install default-jdk -y
sudo apt-get install unzip
wget http://h2o-release.s3.amazonaws.com/h2o/rel-tibshirani/3/h2o-3.6.0.3.zip
unzip h2o-3.6.0.3.zip
cd h2o-3.6.0.3
wget https://raw.githubusercontent.com/jpuigde/h2o_workshop/master/flatfile.txt
java -Xmx1g -jar h2o.jar -flatfile flatfile.txt -port 54321
