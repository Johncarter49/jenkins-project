# Jenkins Setup Guide

This project uses a custom Jenkins image (see Dockerfile) plus a Jenkinsfile pipeline.

## 1) Build Jenkins image

```
cd /Users/aliag/Sites/Devops-Project/jenkins\ task/Jenkins_devops_exams

docker build -t local-jenkins:lts .
```

## 2) Run Jenkins container

```
docker run -d \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  local-jenkins:lts
```

Notes:
- The Docker socket mount allows Jenkins to run docker builds inside the pipeline.
- If you want to use docker-compose instead, create your own compose file and reuse the same image.

## 3) Initial Jenkins unlock

```
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Open http://localhost:8080 and finish the setup wizard.

## 4) Required plugins

Install these plugins in Jenkins:
- Git
- Pipeline
- Docker Pipeline
- Credentials Binding
- Kubernetes (only if you deploy to a cluster)

## 5) Credentials

Create these Jenkins credentials (Manage Jenkins -> Credentials):
- `docker-registry` (Username + Password or Token)
- `kubeconfig` (Secret file for kubeconfig)

## 6) Create pipeline job

Recommended: Multibranch Pipeline
- Branch source: your Git repository
- Build strategy: build only branches that have Jenkinsfile

## 7) Pipeline behavior

- Dev deploy uses docker-compose.
- Staging deploy uses Helm for non-master branches.
- Production deploy is manual and only on master (input step).


