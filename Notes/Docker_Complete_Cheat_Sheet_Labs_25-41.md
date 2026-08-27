# Docker Complete Cheat Sheet — Labs 25–41

## Core mental model

```text
Dockerfile
   ↓ docker build
IMAGE
   ↓ docker run
CONTAINER
```

Project workflow:

```text
Application → Dockerfile → Docker Image → Amazon ECR → Amazon EKS
```

## 1. Images

```powershell
docker images
docker image ls
docker pull IMAGE
docker image inspect IMAGE
docker history IMAGE
docker rmi IMAGE
docker rmi -f IMAGE
docker image prune
```

Image = immutable package/template. Container = runtime instance.

## 2. Containers

```powershell
docker run IMAGE
docker run -d IMAGE
docker run -it --rm IMAGE
docker ps
docker ps -a
docker stop CONTAINER
docker start CONTAINER
docker restart CONTAINER
docker kill CONTAINER
docker rm CONTAINER
docker rm -f CONTAINER
```

`--rm` removes the container after it exits.

`docker run` creates a new container; `docker start` starts an existing stopped container.

## 3. Exec and debugging

```powershell
docker exec CONTAINER COMMAND
docker exec -it CONTAINER sh
docker logs CONTAINER
docker logs -f CONTAINER
docker logs -t CONTAINER
docker inspect CONTAINER
docker stats CONTAINER --no-stream
```

Useful inspect formats:

```powershell
docker inspect CONTAINER --format "{{.State.Status}}"
docker inspect CONTAINER --format "{{.State.ExitCode}}"
docker inspect CONTAINER --format "{{.State.OOMKilled}}"
docker inspect CONTAINER --format "Status={{.State.Status}} | ExitCode={{.State.ExitCode}} | RestartCount={{.RestartCount}}"
```

## 4. Dockerfile basics

```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]
```

Build/run:

```powershell
docker build -t my-app:v1 .
docker run --rm my-app:v1
```

Important instructions:

- `FROM` — base image
- `WORKDIR` — working directory
- `COPY` — copies build-context files
- `RUN` — executes during image build
- `CMD` — default command at container runtime
- `ENTRYPOINT` — executable/entrypoint
- `ENV` — environment variable
- `USER` — switches user

### RUN vs CMD

```text
docker build → RUN → image
docker run   → CMD/ENTRYPOINT → container
```

## 5. Build context and .dockerignore

```powershell
docker build -t my-app .
```

`.` is the build context.

Typical `.dockerignore`:

```text
.venv
.git
__pycache__
*.log
node_modules
```

Benefits: smaller context, faster builds, less accidental data exposure, better cache behavior.

## 6. Image layers and cache

Example:

```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
```

Put infrequently changing content earlier.

Good pattern:

```text
requirements.txt → install dependencies → application code
```

If application code changes but requirements do not, the dependency layer can remain cached.

## 7. Multi-stage builds

```dockerfile
FROM <build-image> AS builder
WORKDIR /build
COPY .
RUN <build-command>

FROM <runtime-image>
WORKDIR /app
COPY --from=builder /build/<artifact> .
CMD ["..."]
```

Builder stage contains build tools; final stage contains the runtime and artifact.

Benefits: smaller image, smaller attack surface, no unnecessary build tools in production.

### Build-time vs runtime dependencies

Build-time examples: Maven, Gradle, GCC, TypeScript compiler, JDK used for compilation.

Runtime examples: Java runtime + JAR, Python runtime + installed packages.

```text
Source + build tools → artifact
Runtime image + artifact + runtime dependencies → running application
```

The final image does not “know” whether the build was successful; the builder must successfully produce the artifact before it is copied into the runtime stage.

## 8. Tags

```powershell
docker tag SOURCE TARGET
```

Example:

```powershell
docker tag lab33-cache:latest my-app:v1
```

A tag does not rebuild/copy the image. Multiple tags can point to the same image ID.

## 9. Networking

```powershell
docker network ls
docker network create NETWORK
docker network inspect NETWORK
docker network connect NETWORK CONTAINER
docker network disconnect NETWORK CONTAINER
```

Run on a network:

```powershell
docker run -d --name server --network lab-network IMAGE
```

User-defined bridge networks provide DNS-based service discovery.

If two containers are on the same user-defined network:

```text
http://server:8080
```

can resolve `server` to the container's IP.

Inside a container, `localhost` means that same container, not another service.

### Network aliases

```powershell
docker network connect `
  --alias backend `
  --alias api `
  lab29-network `
  lab29-server
```

The same container can then be reached as:

```text
lab29-server
backend
api
```

## 10. Port mapping

```powershell
docker run -p HOST_PORT:CONTAINER_PORT IMAGE
```

Example:

```powershell
docker run -p 8080:8080 my-app
```

`EXPOSE 8080` documents/declares the port but does not publish it. `-p` publishes it.

## 11. Volumes and bind mounts

Named volume:

```powershell
docker volume create mydata
docker volume ls
docker volume inspect mydata
docker run -v mydata:/data IMAGE
```

Bind mount:

```powershell
docker run -v ${PWD}:/app IMAGE
```

Volumes are for persistent Docker-managed data. Bind mounts map host paths into containers and are especially useful for development.

## 12. Docker Compose

```powershell
docker compose up
docker compose up -d
docker compose down
docker compose ps
docker compose logs
docker compose logs -f
```

Compose defines multiple services declaratively and normally provides a project network with service-name DNS.

Example:

```yaml
services:
  backend:
    image: my-backend
  database:
    image: postgres
```

Backend can normally reach `database`, not `localhost`.

`depends_on` controls startup ordering but does not by itself guarantee application readiness.

## 13. Healthchecks

Example:

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --retries=3   CMD curl -f http://localhost:8080/health || exit 1
```

States:

```text
starting
healthy
unhealthy
```

Healthcheck asks:

> Is the application healthy?

Restart policy asks:

> Should Docker restart the container?

They are different mechanisms. A container can be `RUNNING` while `UNHEALTHY`.

## 14. Resource limits

Memory:

```powershell
docker run -d --memory=128m IMAGE
```

CPU:

```powershell
docker run -d --cpus=0.5 IMAGE
```

Inspect:

```powershell
docker inspect CONTAINER --format "Memory={{.HostConfig.Memory}}"
docker inspect CONTAINER --format "CPUs={{.HostConfig.NanoCpus}}"
```

Monitor:

```powershell
docker stats
docker stats CONTAINER --no-stream
```

## 15. OOM behavior

We tested a 64 MB container and deliberately exceeded its limit.

Observed:

```text
OOMKilled=true
ExitCode=137
```

Mental model:

```text
Application needs more memory
        ↓
Container reaches limit
        ↓
OOM mechanism kills process
        ↓
Container exits
```

Exit 137 commonly corresponds to SIGKILL (128 + signal 9).

## 16. Logging

```powershell
docker logs CONTAINER
docker logs -f CONTAINER
docker logs -t CONTAINER
```

Inspect driver:

```powershell
docker inspect CONTAINER --format "{{.HostConfig.LogConfig.Type}}"
docker inspect CONTAINER --format "{{json .HostConfig.LogConfig}}"
```

We used/observed the `json-file` driver.

### Log rotation

```powershell
docker run -d `
  --name my-app `
  --log-opt max-size=10m `
  --log-opt max-file=3 `
  IMAGE
```

`max-size` = maximum size of each log file.

`max-file` = number of rotated files retained.

“Rotate” means starting a new log file and moving/replacing older files according to the retention policy. Rotation occurs as new log data is written and the size threshold is reached.

## 17. Non-root containers

Default Python image test:

```powershell
docker run --rm python:3.9-slim id
```

gave root:

```text
uid=0(root)
```

Run as UID/GID 1000:

```powershell
docker run --rm `
  --user 1000:1000 `
  python:3.9-slim `
  id
```

A Dockerfile can create and switch users:

```dockerfile
RUN useradd --create-home appuser
USER appuser
```

Important:

```text
RUN useradd ... → creates user; current user has not changed
USER appuser    → switches to appuser
```

Non-root users may not be able to write everywhere:

```powershell
docker run --rm --user 1000:1000 python:3.9-slim sh -c "touch /test.txt"
```

can fail with permission denied, while writable locations such as `/tmp` can work.

## 18. Secrets

Bad:

```dockerfile
ENV DB_PASSWORD=supersecret
```

This was visible through image inspection.

Better than baking into the image:

```powershell
docker run -e DB_PASSWORD=supersecret IMAGE
```

But the secret still exists as container environment data.

Security progression:

```text
ENV in Dockerfile → ❌ baked into image
docker run -e      → ⚠️ not baked into image, but in environment
dedicated secret manager → ✅ preferred
```

### Docker Swarm secret demonstration

```powershell
docker swarm init
"supersecret" | docker secret create lab35-db-password -
docker secret ls
docker secret inspect lab35-db-password
```

Create service:

```powershell
docker service create `
  --name lab35-secret-service `
  --secret lab35-db-password `
  python:3.9-slim `
  sh -c "cat /run/secrets/lab35-db-password && sleep 3600"
```

Secret is mounted at:

```text
/run/secrets/lab35-db-password
```

`docker secret inspect` showed metadata, not the secret value.

Docker Secrets are primarily a Swarm feature. For AWS architectures, dedicated secret management such as AWS Secrets Manager or Kubernetes Secrets may be used depending on the design.

## 19. Restart policies

### Never

```powershell
--restart=no
```

### Restart on failure

```powershell
--restart=on-failure:3
```

Non-zero exit → restart, up to the configured retry count.

```text
exit 0 → no restart
exit 1 → restart
```

### Always

```powershell
--restart=always
```

Restarts whenever the container stops, including after exit code 0.

### Unless stopped

```powershell
--restart=unless-stopped
```

Restarts when appropriate but respects an intentional manual stop.

| Policy | Exit 0 | Exit non-zero |
|---|---:|---:|
| `no` | ❌ | ❌ |
| `on-failure` | ❌ | ✅ |
| `always` | ✅ | ✅ |
| `unless-stopped` | generally yes | yes |

## 20. Image security

Docker Scout was available, but the CVE scan required Docker authentication in our environment.

Typical workflow:

```text
Base image
   ↓
OS packages
   ↓
Runtime dependencies
   ↓
Application
   ↓
Final image
   ↓
Vulnerability scan
```

Severity commonly includes:

```text
CRITICAL
HIGH
MEDIUM
LOW
```

A CVE finding does not automatically mean the application is compromised. Consider whether the package is present, used, exploitable, and whether a fixed version/base image exists.

## 21. Amazon ECR

Project workflow:

```text
Docker image → Amazon ECR → Amazon EKS
```

Create repository:

```powershell
aws ecr create-repository `
  --repository-name cloud-native-test-platform `
  --region ap-south-1 `
  --profile ecr-lab
```

Authenticate Docker:

```powershell
aws ecr get-login-password `
  --region ap-south-1 `
  --profile ecr-lab |
docker login `
  --username AWS `
  --password-stdin `
  <ECR_REGISTRY>
```

Expected:

```text
Login Succeeded
```

Tag:

```powershell
docker tag lab33-cache:latest `
  <ECR_REGISTRY>/cloud-native-test-platform:v1
```

Push:

```powershell
docker push `
  <ECR_REGISTRY>/cloud-native-test-platform:v1
```

`docker push` pushes the exact local image referenced by the tag supplied to it.

### ECR URI anatomy

```text
825765413460.dkr.ecr.ap-south-1.amazonaws.com/cloud-native-test-platform:v1
│            │   │       │          │                         │
│            │   │       │          │                         └─ tag
│            │   │       │          └─ repository
│            │   │       └─ AWS region
│            │   └─ ECR registry
│            └─ registry/account ID
```

## 22. Cleanup

List:

```powershell
docker ps -a
docker images
docker volume ls
docker network ls
```

Remove stopped containers:

```powershell
docker container prune
```

Remove dangling images:

```powershell
docker image prune
```

Remove unused networks:

```powershell
docker network prune
```

Remove unused volumes:

```powershell
docker volume prune
```

General cleanup:

```powershell
docker system prune
```

More aggressive:

```powershell
docker system prune -a
```

Be careful with `-a`.

ECR repository deletion:

```powershell
aws ecr delete-repository `
  --repository-name cloud-native-test-platform `
  --force `
  --region ap-south-1 `
  --profile ecr-lab
```

## 23. High-priority commands

```powershell
# Images
docker images
docker pull IMAGE
docker build -t NAME:TAG .
docker image inspect IMAGE
docker history IMAGE
docker rmi IMAGE

# Containers
docker run IMAGE
docker run -d IMAGE
docker run -it IMAGE
docker run --rm IMAGE
docker ps
docker ps -a
docker stop CONTAINER
docker start CONTAINER
docker restart CONTAINER
docker rm CONTAINER

# Debugging
docker logs CONTAINER
docker logs -f CONTAINER
docker exec CONTAINER COMMAND
docker exec -it CONTAINER sh
docker inspect CONTAINER
docker stats CONTAINER

# Networking
docker network ls
docker network create NETWORK
docker network inspect NETWORK
docker network connect NETWORK CONTAINER
docker network disconnect NETWORK CONTAINER

# Volumes
docker volume ls
docker volume create VOLUME
docker volume inspect VOLUME

# Compose
docker compose up
docker compose up -d
docker compose down
docker compose ps
docker compose logs
docker compose logs -f

# Registry
docker login
docker tag SOURCE TARGET
docker push IMAGE
docker pull IMAGE
```

## 24. Production Dockerfile pattern

Typical application:

```dockerfile
FROM <runtime-image>

WORKDIR /app

COPY <dependency-files> .

RUN <install-runtime-dependencies>

COPY . .

RUN useradd --create-home appuser

USER appuser

HEALTHCHECK ...

CMD ["..."]
```

Compiled application:

```dockerfile
FROM <build-image> AS builder

WORKDIR /build

COPY .
RUN <build-command>

FROM <runtime-image>

WORKDIR /app

COPY --from=builder /build/<artifact> .

USER appuser

CMD ["..."]
```

## 25. Final Docker → AWS mental model

```text
GitHub
   ↓
Dockerfile
   ↓
docker build
   ↓
Docker Image
   ├─ optimized layers
   ├─ build cache
   ├─ multi-stage build
   ├─ non-root
   ├─ healthcheck
   ├─ resource limits
   └─ security scan
   ↓
Amazon ECR
   ↓
Amazon EKS
   ↓
Kubernetes Pods
   ↓
AWS VPC / ALB
   ↓
CloudWatch / Prometheus / Grafana
```

## 26. Docker principles to remember

- Small images
- Multi-stage builds
- Good layer ordering
- Build cache
- Non-root users
- Never bake secrets into images
- Runtime configuration
- Healthchecks
- Resource limits
- Log management and rotation
- Appropriate restart policies
- Network isolation
- Vulnerability scanning
- Versioned image tags
- Registry workflow

## 27. Next stage

Docker is complete for the current project.

Next progression:

```text
Docker ✅
   ↓
Kubernetes fundamentals
   ↓
kubectl
   ↓
Pods
   ↓
Deployments
   ↓
Services
   ↓
ConfigMaps / Secrets
   ↓
Ingress
   ↓
ECR → EKS
   ↓
AWS VPC + ALB
   ↓
IAM
   ↓
CI/CD
   ↓
CloudWatch / Prometheus / Grafana
```

### Quick revision list

1. Image vs container
2. `docker build` vs `docker run`
3. `RUN` vs `CMD`
4. Dockerfile layers
5. Build cache
6. Multi-stage builds
7. Build-time vs runtime dependencies
8. User-defined networking and DNS
9. Volumes vs bind mounts
10. Healthcheck vs restart policy
11. CPU/memory limits
12. OOMKilled / exit 137
13. Non-root containers
14. Secrets
15. Log rotation
16. Image tagging
17. ECR authentication
18. ECR push/pull workflow
