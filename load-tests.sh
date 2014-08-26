
#!/bin/bash
#----------------------------------------------------------
# Desc   : Load modules/extensions into Marklogic Document Store
# Authors: Andreas Bester
#----------------------------------------------------------
#set -x  #debug on
set -e  #exit on any errors

# Remove proxy variables, as it prohibits connection to the local mark logic server
unset http_proxy
unset HTTP_PROXY

# Credentials
declare authentication="admin:admin"

# Server connection details
declare host="http://localhost"
declare port="8003"


#Allow for basic authentication
declare cred_base64=$(printf $authentication | base64)
declare connection="$host:$port"
declare counter=0
declare resource

cd test
echo "Loading Tests ..."
for data in $(ls *.xqy);
 do
    resource="/ext/xquery/test/$data"
    curl -X PUT -w %{http_code} -H "Content-type: application/xquery" -H "Authorization: Basic $cred_base64" -T $data "$connection/v1$resource" \
     && ((counter++))
    echo -e " <response [$counter] Loaded $data into modules store at URI: $resource";
done;

echo -e "\nTo view all modules: $connection/v1/ext/"

exit 0;
