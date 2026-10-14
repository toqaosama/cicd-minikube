# Jenkins -> Minikube CI/CD

## Repo layout
Python.py, req.txt, Dockerfile, Jenkinsfile, K8s/{deployment,service}.yaml

## Setup
1. `minikube start` then `kubectl get nodes`, `minikube status`
2. Create a self-contained kubeconfig (certs embedded):
   `kubectl config view --flatten --minify > minikube-kubeconfig.yaml`
   - The `server:` URL must be reachable from Jenkins (if Jenkins runs in Docker,
     use `minikube start --listen-address=0.0.0.0` or run Jenkins on the same host/network).
3. Jenkins > Manage Credentials, add:
   - Secret file, ID `minikube-kubeconfig` (the file above)
   - Username/password, ID `dockerhub-creds` (Docker Hub user + access token)
4. Jenkins must reach Docker: `sudo usermod -aG docker jenkins && sudo systemctl restart jenkins`
   (check `/var/run/docker.sock` permissions). `kubectl` must be installed on the agent.
5. Edit `DOCKERHUB_USER` in the Jenkinsfile, push the repo to Git.
6. New Item > Pipeline > "Pipeline script from SCM" > your repo > Build Now.

## Verify
    kubectl get pods
    kubectl get services
    minikube service python-app-service --url
