
#OpenStack Configuration
sudo apt-get install libssl-dev libffi-dev python-dev libyaml-dev python-pip
sudo pip install virtualenv
virtualenv ~/zsenv
source ~/zsenv/bin/activate
pip install pyopenssl ndg-httpsclient pyasn1 certifi
pip install python-openstackclient
pip install python-heatclient

pip install python-neutronclient

source ~/zsenv/bin/activate
source /<path_to_zerostackrc

#gsettings set com.canonical.Unity.Launcher launcher-position Bottom