start_minikube:
	minikube start --docker-env="DOCKER_OPTS=--device=/dev/video0:/dev/video0"

setup_docker_env:
	eval $$(minikube docker-env) && docker build -t checkpoint5/django:latest videoanalytics

enable_ingress:
	while true; do minikube addons enable ingress && break; done

apply_postgres:
	kubectl apply -f k8s/postgres-statefulset.yaml
	kubectl apply -f k8s/postgres-service.yaml

apply_django:
	kubectl apply -f k8s/django-deployment.yaml
	kubectl apply -f k8s/django-service.yaml

apply_django_ingress:
	while true; do kubectl apply -f k8s/django-ingress.yaml && break; done

.PHONY: start_minikube setup_docker_env enable_ingress apply_postgres apply_django apply_django_ingress
