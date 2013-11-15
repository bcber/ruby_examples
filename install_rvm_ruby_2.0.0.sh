echo insecure >> ~/.curlrc
curl https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer | bash -s stable
source ~/.bash_profile
rvm install 2.0.0
rvm use 2.0.0 --default