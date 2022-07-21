#!/bin/bash

# Search the unifi mongo database using the server cli
# Feb 24, 2022 - Some guy on the internet
# requires: jq - https://stedolan.github.io/jq/download/


# got mac?
if [ $# -eq 0 ]; then
    echo "no mac provided"
    exit 1
fi

# convert to lowercase
mac=${1,,}

# server cli info (not the web gui creds)
server="fqdn.server.com"
username="youser"
#password="batteryhorsestaple"   # $password will need sshpass, but I like mobaxterm better.


# search for mac, returns a string
echo
echo Checking Unifi server for $mac
a=$(ssh $username@$server "mongo --port 27117 ace --eval 'db.device.find({\"mac\":\"$mac\"})'")


# test if a result was found
if [ ${#a} -lt 65 ]; then
	echo not found
	exit 
fi


# extract the json from the string
a=${a:65}


# jq will not parse the json as is; it is considered "invalid json format" because ~~ubiquiti~~ mongo, so we fix it.
# https://jsonparseronline.com/

# before
# echo $a >test.json


s="ObjectId("
while [[ "$a" == *"$s"* ]]; do
	a="${a/$s/}" 
done

s='NumberLong('
while [[ "$a" == *"$s"* ]]; do
	a="${a/$s/}" 
done

s='ISODate('
while [[ "$a" == *"$s"* ]]; do
	a="${a/$s/}" 
done

s='")'
while [[ "$a" == *"$s"* ]]; do
	a="${a/$s/\"}"
done

s='),'
while [[ "$a" == *"$s"* ]]; do
	a="${a/$s/,}"
done

s=') '
while [[ "$a" == *"$s"* ]]; do
	a="${a/$s/}"
done


# after
# echo $a >>test.json


# notes: ubiquiti in their infinite wisdom may break the json format further in a future update.
#        there maybe also be a problem if there are brackets in the site names or device names.


# extract the site_id and device name from the json
siteId=$(jq -r '.site_id' <<< $a)
name=$(jq -r '.name' <<< $a)


# get the site info using the above site_id
b=$(ssh $username@$server "mongo --port 27117 ace --eval 'db.site.find({\"_id\":ObjectId(\"$siteId\")})'")


# extract invalid json and fix it
b=${b:65}
b="${b/ObjectId(/}" 
b="${b/)/}" 


# results
echo
echo -e "device name: \t $name"
echo -e "site name: \t $(jq -r '.desc' <<< $b)"
echo -e "url: \t\t https://$server/manage/site/$(jq -r '.name' <<< $b)/devices/list/"
