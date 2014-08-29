
#!/bin/bash
#----------------------------------------------------------
# Desc   : Load resource extensions into Marklogic
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
declare host="https://10.0.108.34"
declare port="9991"

#Allow for basic authentication
declare cred_base64=$(printf $authentication | base64)
declare connection="$host:$port"
declare counter=0
declare resource
declare metaData

cd resources
echo "Loading Resources - Rest API Endpoint(s) ..."
for data in $(ls *.xqy);
 do
    metadata=$(head -1 $data | cut -c 3-)
    echo $firstLine
    resource="/v1/config/resources/b2b-exporter-${data%.*}"
    curl --socks5-hostname 127.0.0.1:4332 -k -E /Users/bestea02/work/cert/userkey.pem --cacert /Users/bestea02/work/cert/ca-bundle.pem -X PUT -w %{http_code} -H "Content-type: application/xquery" -H "Authorization: Basic $cred_base64" -T $data "$connection$resource$metadata" \
     && ((counter++))
    echo -e " <response [$counter] Loaded $data into modules store at URI:$resource";
done;

echo -e "\nTo view all resource extensions: $connection/v1/config/resources/"


exit 0;
