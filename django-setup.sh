#fedora
uname -r

yum install redhat-lsb-core
lsb_release -a

yum update
python3 --version
python3 -m django --version
pip3 --version

git --version

yum install vivaldi
yum install code

pip3 install virtualenv --user

echo "Set ENV name:"
read envname

virtualenv --distribute ~/.env/$envname
source ~/.env/$envname/bin/activate
repo=$(pwd)
pip3 install -r $repo/req.txt

echo "Set site name:"
read sitename

django-admin startproject $sitename
cd $sitename
ifconfig | grep inet

echo "Set site IP Address:"
read ipaddress
nano /etc/hosts

python3 manage.py runserver $ipaddress:8080

echo "Set APP name:"
read appname

python3 manage.py startapp $appname

#something about allowed hosts need to be changed

#intial views/url changes

code $repo/$sitename/$appname/views.py
touch $repo/$sitename/$appname/urls.py
code $repo/$sitename/$appname/urls.py

#database setting up
code $repo/$sitename/settings.py

#read "holding for SQL migration"
#python3 manage.py loaddata main.sql

python3 manage.py migrate
sqlite3 db.sqlite3 < "/home/mwtilton/Documents/GitHub/budget/Main.sql"

#deactivate