# Promise
kubectl apply --context $PLATFORM -f vcluster-promise/promise.yaml

# Permissions
# kubectl apply --context $PLATFORM -f vcluster-promise/request-pipeline-image/permissions.yaml
kubectl --context $WORKER apply -f vcluster-promise/request-pipeline-image/test-rb.yaml

# Resource request
kubectl apply --context $PLATFORM -f vcluster-promise/vcluster-resource-request.yaml

# Logs
kubectl --context $PLATFORM logs --selector=kratix-promise-id=vcluster-default --container xaas-request-pipeline-stage-0

# Nukify
kubectl --context $PLATFORM delete promise vcluster
kubectl --context $PLATFORM delete vcluster my-vcluster-promise-request

kubectl --context $WORKER port-forward my-vcluster-demo -n vcluster-namespace 8443

kubectl --context $WORKER get secret vc-my-vcluster-demo -n vcluster-namespace --template={{.data.config}} | base64 -D

kubectl --context $WORKER logs --selector=kratix-promise-id=vcluster-default --container xaas-request-pipeline-stage-0

kubectl --context $WORKER logs job/setup-vcluster -n vcluster-namespace

# Ref: https://blog.devgenius.io/k8s-manage-multiple-clusters-using-kubectl-at-scale-9f200c692099
kubectl config --kubeconfig=config-demo use-context dev-frontend