#! /bin/bash

Terminating_ns_list=`kubectl get ns | grep Terminating | awk '{print $1}'| xargs`
Check_8001=`netstat -nltup | grep :8001 | wc -l`

if [ "$Terminating_ns_list" = "" ];
then
    exit
fi

if [ $Check_8001 eq 0 ];
then
    kubectl proxy &
fi

for n in $Terminating_ns_list
do
exec 1>/tmp/Terminating_ns.log 2>Terminating_ns.err
   kubectl get ns $n -ojson | jq '.spec.finalizers = []' > $n.json

   curl -k -H "Content-Type: application/json" -X PUT --data-binary @$n.json http://127.0.0.1:8001/api/v1/namespaces/$n/finalize 

done

echo "verify the result"
kubectl get ns
