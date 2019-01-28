minikube start
kubectl create namespace timestamp 
kubectl config set-context $(kubectl config current-context) --namespace=timestamp
kubectl apply -f pod.yml
kubectl get pods
kubectl expose pod timestamp-api --type=LoadBalancer 
minikube service timestamp-api --namespace=timestamp --url
#minikube stop;minikube destroy