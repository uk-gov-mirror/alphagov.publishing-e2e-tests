# Kubernetes Support

The files in `apps/` were created from the docker-compose.yml file using [Kompose](https://github.com/kubernetes-incubator/kompose).

Run using a K8s local development tool such as [minekube](https://github.com/kubernetes/minikube).

## Docker Registry

Currently we do not host any images in a Docker Registry (note: we should add this as a build step to
push the latest container image to a registry).

We can work around this for now. Run a build job in the root of this repo:

`docker-compose build`

This will build the images locally, so we need to have a local registry that kubernetes can communicate
with.

Run the docker [registry](https://hub.docker.com/_/registry/) image:

`docker run -d -p 5000:5000 --restart always --name registry registry:2`

We need to tag the images for the local repo:

`for i in $(ls apps); do docker tag $i localhost:5000/$i; done`

Then we need to push them:

`for i in $(docker images |awk '/localhost:5000/ {print $1}'); do docker push $i; done`

**There's probably a better way to do this (like just putting the images in a registry)**

## Start Kubernetes

Check the IP that is assigned to the minikube VM using `ifconfig`, and start
minikube by referencing this registry:

`minikube start --insecure-registry=192.168.99.1:5000`

Be aware that this option will not work if the minikube VM was previously
created. In this instance, you must first do `minikube delete`.

When that's configured, you can use [`kubectl`](https://kubernetes.io/docs/user-guide/kubectl-overview/)
to create the full set of apps:

`kubectl create -Rf apps`

A single app:

`kubectl create -f apps/publishing-api`

Check what's happening:

`minikube dashboard`

Use the API:

`kubectl get pods`

## But why?

For fun.

Maybe.
