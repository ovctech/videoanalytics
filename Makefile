.PHONY: all
all: start_minikube setup_docker_env enable_ingress apply_postgres apply_django apply_django_ingress

start_minikube:
	minikube start --docker-env="DOCKER_OPTS=--device=/dev/video0:/dev/video0"
	echo "start_minikube" > start_minikube

setup_docker_env:
	eval $$(minikube docker-env) && docker build -t checkpoint5/django:latest videoanalytics
	echo "setup_docker_env" > setup_docker_env

enable_ingress:
	minikube addons enable ingress
	echo "enable_ingress" > enable_ingress

apply_postgres:
	kubectl apply -f k8s/postgres-statefulset.yaml
	kubectl apply -f k8s/postgres-service.yaml
	echo "apply_postgres" > apply_postgres

apply_django:
	kubectl apply -f k8s/django-deployment.yaml
	kubectl apply -f k8s/django-service.yaml
	echo "apply_django" > apply_django

apply_django_ingress:
	@status=1; \
	while [ $$status -ne 0 ]; do \
		kubectl apply -f k8s/django-ingress.yaml ; \
		status=$$?; \
	done
	rm -f start_minikube setup_docker_env enable_ingress apply_postgres apply_django