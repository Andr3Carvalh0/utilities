#!/bin/bash
#
# Created by André Carvalho in April 2020
# Last modified August 2020
#
certs=`openssl s_client -servername $1 -host $1 -port 443 -showcerts </dev/null 2>/dev/null | sed -n '/Certificate chain/,/Server certificate/p'`
rest=$certs
keys=""

i=1

echo "Extracting..."
echo ""
while [[ "$rest" =~ '-----BEGIN CERTIFICATE-----' ]]
do
 	cert="${rest%%-----END CERTIFICATE-----*}-----END CERTIFICATE-----"
 	rest=${rest#*-----END CERTIFICATE-----}
 	
 	# Logs the name + other info comment to keep my sanity while debugging this + not that interrested :D 
 	# echo `echo "$cert" | grep 's:' | sed 's/.*s:\(.*\)/\1/'`

 	key=`echo "$cert" | 
 		openssl x509 -pubkey -noout | 
 		openssl rsa -pubin -outform der 2>/dev/null | 
 		openssl dgst -sha256 -binary | 
 		openssl enc -base64`

 	echo "SSL Pinning Key ${i}: ${key}" 

	echo "${cert}" | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > certificate_${i}.crt

	if [ $i -eq 1 ];then
		keys="Certificate key ${i}: ${key}"
	else
		keys="${keys}\nCertificate key ${i}: ${key}"
	fi

 	((i=i+1))
done

echo "${keys}" > keys.txt

echo ""
echo "You can find all the certificates + keys in this script's folder"