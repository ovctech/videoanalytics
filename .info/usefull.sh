echo "192.168.49.2 backend.info" | sudo tee -a /etc/hosts
kubectl apply -f k8s/test-pod.yaml
(eval $(minikube docker-env) && docker images)
kubectl get all
kubectl get pods
kubectl logs deployment.apps/django-deployment
kubectl get persistentvolumes
kubectl patch deployment backend-deployment \
        --patch-file k8s/backend-deployment-patch.yaml
kubectl -n ingress-nginx get pods
kubectl -n ingress-nginx logs deployment/ingress-nginx-controller
kubectl delete -f k8s/postgres-statefulset.yaml
kubectl delete -f k8s/django-deployment.yaml
kubectl delete pv pvc-896f0333-39c4-400e-9488-a162b3afae6c
kubectl describe pod/postgres-statefulset-0
kubectl describe deployment.apps/django-deployment
kubectl describe pod django-deployment-66b9d6644c-8d5xv
kubectl delete deployment.apps/django-deployment
kubectl get ingress
kubectl describe ingress django-ingress
minikube tunnel list
minikube service web --url
kubectl get service postgres-service
kubectl exec -it test-pod -- /bin/bash
python -m pip install psycopg2
python -q
import psycopg2
conn = psycopg2.connect(
host='postgres-statefulset-0.postgres-service.default.svc.cluster.local',
port='5432',
database='my_database',
user='my_username',
password='my_password'
)
cursor = conn.cursor()
cursor.execute("CREATE TABLE public.my_table (id INTEGER);")
cursor.execute("SELECT * FROM public.my_table")
result = cursor.fetchone()
\dt *.*
psql --username=my_username --dbname=my_database
backend.localhost
curl --resolve "backend.localhost:80:$( minikube ip )" -i http://hello-world.info