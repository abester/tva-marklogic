#!/bin/bash
#----------------------------------------------------------
# Desc   : Load Pips XML into Marklogic Document Store
# Authors: Andreas Bester
#----------------------------------------------------------
#set -x  #debug on
set -e  #exit on any errors

# Remove proxy variables, as it prohibits connection to the local mark logic server
unset http_proxy
unset HTTP_PROXY

# Credentials
declare authentication="admin:password"

# Server connection details
declare host="https://10.0.107.192"
declare port="9991"

#declare host="https://b2b-pusher-dnodes-ml.int.cloud.bbc.co.uk/v1"
#declare port="80"

#Allow for basic authentication
declare cred_base64=$(printf $authentication | base64)
declare connection="$host:$port"
declare counter=0
declare resource

declare command
declare commandResponse

cd pips
echo "Loading Pips Data..."
for data in $(ls *.xml);
 do
    resource="/pips/${data%.*}"
    #--socks5-hostname 127.0.0.1:4332
    curl --socks5-hostname 127.0.0.1:4332 -k -E /Users/bestea02/work/cert/userkey.pem --cacert /Users/bestea02/work/cert/ca-bundle.pem -X PUT -w %{http_code} -H "Content-type: application/xml" -H "Authorization: Basic $cred_base64" -T $data "$connection/v1/documents?uri=$resource&collection=pips"\
     && ((counter++))
    echo " <response [$counter] Stored $data at URI: $resource";
done;

exit 0;
