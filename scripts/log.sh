#!/bin/bash

minikube start --docker-env="DOCKER_OPTS=--device=/dev/video0:/dev/video0"
eval $(minikube docker-env) && docker build -t checkpoint5/django:latest videoanalytics

while true; do
    minikube addons enable ingress && break
done

kubectl apply -f k8s/postgres-statefulset.yaml
kubectl apply -f k8s/postgres-service.yaml
kubectl apply -f k8s/django-deployment.yaml
kubectl apply -f k8s/django-service.yaml

while true; do
    kubectl apply -f k8s/django-ingress.yaml && break
done
