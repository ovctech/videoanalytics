#!/bin/bash

eval $(minikube docker-env)
docker build -t checkpoint5/django:latest videoanalytics
minikube addons enable ingress
kubectl apply -f k8s/postgres-statefulset.yaml
kubectl apply -f k8s/postgres-service.yaml
kubectl apply -f k8s/django-deployment.yaml
kubectl apply -f k8s/django-ingress.yaml
kubectl apply -f k8s/django-service.yaml

echo "127.0.0.1 backend.localhost" | sudo tee -a /etc/hosts


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