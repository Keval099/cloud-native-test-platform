# Kubernetes Foundation Learning Notes

## Purpose

These notes capture the Kubernetes foundation learning and hands-on labs completed for the Cloud Native Test Platform project.

The goal was **foundational Kubernetes confidence**, not deep Kubernetes specialization.

Focus areas:
- Kubernetes hierarchy: Cluster, Node, Pod, Container
- `kubectl` fundamentals
- Pods and YAML
- Deployments and ReplicaSets
- Scaling
- Services, ClusterIP and NodePort
- Ingress concepts
- ConfigMaps and Secrets
- Liveness and readiness probes
- Troubleshooting
- Rolling updates and rollback
- Blue-Green deployments and traffic switching

---

# 1. Kubernetes Mental Model

```text
Kubernetes Cluster
│
└── Node
    │
    └── Pod
        │
        └── Container
            │
            └── Application
```

A **Cluster** is the overall Kubernetes environment.

A **Node** is a machine that runs Kubernetes workloads.

A **Pod** is the smallest deployable Kubernetes workload unit. A Pod contains one or more containers.

For the local labs, the Node was:

```text
desktop-control-plane
```

The key distinction:

> A Node is the machine providing compute resources. A Pod is a Kubernetes workload unit running on that Node.

---

# 2. Pod Basics

Example Pod YAML:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lab43-pod

spec:
  containers:
    - name: app
      image: python:3.9-slim
      command:
        - python
        - -c
        - print("Hello from Kubernetes YAML")
```

Apply:

```powershell
kubectl apply -f kubernetes\labs\lab43\pod.yaml
```

Check:

```powershell
kubectl get pods
```

Logs:

```powershell
kubectl logs lab43-pod
```

---

# 3. Pod Lifecycle: Running vs Completed

A Pod can successfully execute its command and then finish.

Example:

```text
READY   STATUS
0/1     Completed
```

This does not necessarily mean failure.

In Lab 43, the process printed:

```text
Hello from Kubernetes YAML
```

and exited successfully with:

```text
exitCode: 0
reason: Completed
```

A continuously running server needs a long-running process.

---

# 4. `kubectl` Fundamentals

`kubectl` is the command-line tool used to communicate with Kubernetes.

Common commands:

```powershell
kubectl get pods
kubectl get deployments
kubectl get replicasets
kubectl get services
kubectl get nodes
kubectl describe pod <pod-name>
kubectl describe service <service-name>
kubectl logs <pod-name>
kubectl apply -f <file>
kubectl delete pod <pod-name>
kubectl scale deployment <deployment-name> --replicas=<number>
kubectl rollout status deployment/<deployment-name>
kubectl rollout undo deployment/<deployment-name>
```

---

# 5. Meaning of `-o`

The `-o` option means **output format**. It does not mean "orchestration."

Examples:

```powershell
kubectl get pods -o wide
kubectl get pod <pod-name> -o yaml
kubectl get pod <pod-name> -o json
```

`-o wide` provides additional columns such as Pod IP and Node.

`-o yaml` shows the resource specification and status.

---

# 6. Deployment

A Deployment manages application Pods.

Mental model:

```text
Deployment
    │
    └── ReplicaSet
          │
          ├── Pod
          ├── Pod
          └── Pod
```

Example:

```text
Deployment: lab44-deployment
Replicas: 3
```

Check:

```powershell
kubectl get deployment lab44-deployment
```

A result such as:

```text
READY   UP-TO-DATE   AVAILABLE
3/3     3            3
```

means the desired three replicas are ready and available.

---

# 7. ReplicaSet

A ReplicaSet maintains the desired number of matching Pods.

```powershell
kubectl get replicasets
```

Example:

```text
NAME                         DESIRED   CURRENT   READY
lab44-deployment-67c8854d9   3         3         3
```

Relationship:

```text
Deployment
     │
     ▼
ReplicaSet
     │
     ▼
Pods
```

The ReplicaSet is normally managed by the Deployment.

---

# 8. Why Deleting a Deployment Pod Does Not Reduce Capacity

When a Pod managed by a Deployment is deleted:

```text
Before:
Pod A
Pod B
Pod C

Delete Pod A

After:
Pod B
Pod C
Pod D
```

The ReplicaSet creates a replacement to satisfy the Deployment's desired replica count.

This demonstrates Kubernetes' declarative model:

> Kubernetes continuously works toward the desired state.

---

# 9. Scaling

We scaled a Deployment from three replicas to five:

```powershell
kubectl scale deployment lab44-deployment --replicas=5
```

Then back to two:

```powershell
kubectl scale deployment lab44-deployment --replicas=2
```

Mental model:

```text
Desired state = 2
Current state = 5

Kubernetes removes excess Pods.

Result = 2 Pods
```

---

# 10. Services

Pods are not permanent network endpoints because Pod IPs can change when Pods are recreated.

A Service provides a stable networking abstraction in front of Pods.

```text
Client
  │
  ▼
Service
  │
  ├── Pod
  ├── Pod
  └── Pod
```

Services use labels/selectors to determine which Pods receive traffic.

---

# 11. ClusterIP

ClusterIP is the default Service type.

It provides internal cluster access.

```text
Application A
     │
     ▼
ClusterIP Service
     │
     ▼
Application B Pods
```

Example observed Service:

```text
TYPE        CLUSTER-IP
ClusterIP   10.96.x.x
```

---

# 12. Service Selectors

A Service can select Pods by labels.

Example:

```yaml
selector:
  app: lab44
```

Pods with:

```yaml
labels:
  app: lab44
```

can become Service endpoints.

Check:

```powershell
kubectl describe service lab46-service
```

The Service showed endpoints such as:

```text
10.244.0.11:8000
10.244.0.8:8000
```

---

# 13. `targetPort`

A Service can expose one port and forward to another port on the Pod.

Example:

```text
Port:       80
TargetPort: 8000
```

Flow:

```text
Client
  │
  ▼
Service :80
  │
  ▼
Pod :8000
```

The application must actually listen on the target port.

---

# 14. NodePort

NodePort exposes a Service through a port on each Node.

Example:

```text
TYPE       PORT(S)
NodePort   80:30080/TCP
```

Meaning:

```text
Service port = 80
NodePort     = 30080
```

Conceptually:

```text
Client
   ↓
NodeIP:30080
   ↓
NodePort Service
   ↓
Pods
```

We tested Service access from another Pod using:

```powershell
kubectl run lab47-test --rm -it --image=python:3.9-slim -- sh
```

and a request to the Service returned:

```text
Hello from Kubernetes Service
```

---

# 15. ClusterIP vs NodePort

### ClusterIP

Primarily internal:

```text
Inside cluster
    ↓
ClusterIP Service
    ↓
Pods
```

### NodePort

Provides access through a Node port:

```text
Client
   ↓
NodeIP:NodePort
   ↓
Service
   ↓
Pods
```

For foundational learning, remember:

> ClusterIP is the normal internal Service type. NodePort exposes the Service through a Node port.

---

# 16. Ingress

Ingress provides HTTP/HTTPS routing into Kubernetes Services.

Example:

```text
Internet
   │
   ▼
Ingress
   │
   ├── /employees → employee-service
   ├── /leave     → leave-service
   └── /          → frontend-service
```

The important distinction learned:

> A Service provides stable networking access to Pods. Ingress provides higher-level HTTP/HTTPS routing to Services.

Typical architecture:

```text
Client
  ↓
Ingress
  ↓
Service
  ↓
Pods
```

Ingress and NodePort can both participate in exposing applications, but they operate at different layers.

---

# 17. Running Does Not Automatically Mean Reachable

A very useful troubleshooting lesson came from Lab 57.

Pods were:

```text
1/1 Running
```

but requests through the Service returned:

```text
ConnectionRefusedError: [Errno 111] Connection refused
```

The Service targeted:

```text
targetPort: 8000
```

but the application was not actually listening on port 8000.

The fix was to start an HTTP server:

```python
http.server.HTTPServer(("0.0.0.0", 8000), Handler).serve_forever()
```

Then:

```text
Service
   ↓
Pod:8000
   ↓
HTTP server
   ↓
successful response
```

Key lesson:

> `Running` means the container process is running. It does not automatically mean the application is reachable or healthy.

---

# 18. ConfigMap

A ConfigMap stores non-sensitive configuration.

Example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: lab58-config
data:
  APP_NAME: cloud-native-test-platform
  ENVIRONMENT: dev
```

Commands:

```powershell
kubectl get configmap lab58-config
kubectl describe configmap lab58-config
```

Typical uses:
- Application environment
- Feature flags
- URLs
- Non-sensitive settings

---

# 19. Secret

A Secret is intended for sensitive configuration.

Example:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: lab58-secret
type: Opaque
stringData:
  DB_PASSWORD: supersecret
```

Commands:

```powershell
kubectl apply -f kubernetes\labs\lab58\secret.yaml
kubectl get secret lab58-secret
kubectl describe secret lab58-secret
```

The lab showed:

```text
DB_PASSWORD: 11 bytes
```

---

# 20. Base64 Is Not Encryption

Viewing a Secret as YAML showed:

```text
DB_PASSWORD: c3VwZXJzZWNyZXQ=
```

This is Base64 encoding.

Remember:

```text
Base64 encoding ≠ encryption
```

Do not treat Base64 as a security mechanism.

---

# 21. Injecting ConfigMap and Secret Values

Values can be injected into a container as environment variables.

Example:

```yaml
env:
  - name: APP_NAME
    valueFrom:
      configMapKeyRef:
        name: lab58-config
        key: APP_NAME

  - name: ENVIRONMENT
    valueFrom:
      configMapKeyRef:
        name: lab58-config
        key: ENVIRONMENT

  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: lab58-secret
        key: DB_PASSWORD
```

The application can read them with:

```python
import os

os.environ.get("APP_NAME")
os.environ.get("DB_PASSWORD")
```

Lab 58 output:

```text
Application: cloud-native-test-platform
Environment: dev
Database password: supersecret
```

For a real application, sensitive values should not be printed into logs.

---

# 22. Health Probes

Two foundational probes were practiced:

```text
Liveness
Readiness
```

Example:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 5
```

The Lab 52 application exposed:

```text
GET /health
```

and returned:

```text
OK
```

---

# 23. Liveness vs Readiness

### Liveness

Question:

> Is the application still alive?

If it repeatedly fails, Kubernetes can restart the container.

### Readiness

Question:

> Is the application ready to receive traffic?

If readiness fails, the Pod can be removed from Service endpoints while the container remains running.

Simple mental model:

```text
Liveness
    ↓
Should Kubernetes restart me?

Readiness
    ↓
Should I receive traffic?
```

---

# 24. Troubleshooting Workflow

The foundational troubleshooting workflow developed was:

```text
1. kubectl get pods
          ↓
2. kubectl logs <pod>
          ↓
3. kubectl describe pod <pod>
          ↓
4. kubectl get events
          ↓
5. If networking is involved:
   check Service and endpoints
```

Start broad, then narrow down.

---

# 25. Pod Troubleshooting

Start:

```powershell
kubectl get pods
```

Look at:

```text
READY
STATUS
RESTARTS
AGE
```

Possible statuses include:

```text
Running
Completed
Error
CrashLoopBackOff
Pending
```

Then:

```powershell
kubectl logs <pod-name>
```

Then:

```powershell
kubectl describe pod <pod-name>
```

---

# 26. Filtering Events by Pod

All events:

```powershell
kubectl get events --sort-by=.lastTimestamp
```

Events for a specific Pod:

```powershell
kubectl get events --field-selector involvedObject.name=lab53-broken-pod --sort-by=.lastTimestamp
```

The Lab 53 events included:

```text
Scheduled
Pulled
Created
Started
BackOff
```

This is useful when there are many cluster events.

---

# 27. CrashLoopBackOff

A deliberately broken application was created:

```python
print("Starting application...")
raise Exception("Application failed intentionally")
```

The Pod eventually showed:

```text
STATUS
CrashLoopBackOff
```

Logs:

```text
Starting application...
Exception: Application failed intentionally
```

`describe` showed:

```text
Last State: Terminated
Reason: Error
Exit Code: 1
Restart Count: 8
```

Mental model:

```text
Application starts
      ↓
Application crashes
      ↓
Container exits
      ↓
Kubernetes restarts it
      ↓
Application crashes again
      ↓
Repeated failures
      ↓
CrashLoopBackOff
```

---

# 28. Error vs CrashLoopBackOff

A container can first show an error after exiting.

With repeated failures and restart attempts, Kubernetes can show:

```text
CrashLoopBackOff
```

The BackOff represents Kubernetes spacing out restart attempts after repeated failures.

---

# 29. Rolling Updates

Deployments support rolling updates.

We changed an application from:

```text
Application version: v1
```

to:

```text
Application version: v2
```

Kubernetes created a new ReplicaSet and gradually replaced the old Pods.

Conceptually:

```text
v1
 ↓
new ReplicaSet
 ↓
new Pods
 ↓
old Pods gradually terminated
 ↓
v2
```

---

# 30. ReplicaSet Revision Hashes

Deployment-generated ReplicaSets had names such as:

```text
lab54-deployment-55fbbc594d
lab54-deployment-77dcd6999f
lab54-deployment-5c48db9d78
lab54-deployment-7445868894
```

Different suffixes correspond to different Pod template revisions.

Therefore a Deployment can retain multiple historical ReplicaSets.

---

# 31. Rollout Status

Monitor a Deployment rollout:

```powershell
kubectl rollout status deployment/lab54-deployment
```

Successful output:

```text
deployment "lab54-deployment" successfully rolled out
```

If the new application is broken, the rollout may fail to make all updated replicas available.

---

# 32. Rollback

A deliberately broken v3 was deployed:

```text
Application version: v3
Exception: v3 application failure
```

Pods entered:

```text
CrashLoopBackOff
```

The Deployment showed:

```text
READY 0/3
AVAILABLE 0
```

Rollback:

```powershell
kubectl rollout undo deployment/lab54-deployment
```

The Deployment returned to:

```text
READY 3/3
AVAILABLE 3
```

and logs showed:

```text
Application version: v2
```

---

# 33. Rolling Update vs Rollback

Rolling update:

```text
v1 → v2
```

Moves forward to a new version.

Rollback:

```text
v3 ❌
 ↓
rollback
 ↓
v2 ✅
```

Returns to a previous Deployment revision.

---

# 34. Blue-Green Deployment

Lab 57 introduced Blue-Green deployment.

Two Deployments were created:

```text
Blue Deployment
3 Pods
version=blue

Green Deployment
3 Pods
version=green
```

Both versions ran at the same time.

Conceptually:

```text
             Service
                │
          version=blue
                │
                ▼
          Blue v1
          3 Pods

          Green v2
          3 Pods
          standby
```

---

# 35. Blue-Green Labels

Blue Pods:

```text
app=lab57
version=blue
```

Green Pods:

```text
app=lab57
version=green
```

Verified with:

```powershell
kubectl get pods --show-labels
```

---

# 36. Blue-Green Traffic Switching

The Service initially selected:

```yaml
selector:
  app: lab57
  version: blue
```

Traffic therefore went:

```text
Service
   ↓
version=blue
   ↓
Blue Pods
```

The test returned:

```text
BLUE - Application version v1
```

---

# 37. Switching Traffic to Green

The Service selector was changed to:

```yaml
selector:
  app: lab57
  version: green
```

Apply:

```powershell
kubectl apply -f kubernetes\labs\lab57\service.yaml
```

Testing the same Service returned:

```text
GREEN - Application version v2
```

This proved that traffic had switched to Green.

The important concept:

> Blue and Green can both be running, while the Service selector determines which version receives traffic.

---

# 38. Blue-Green Rollback

If Green is bad, change:

```yaml
version: green
```

back to:

```yaml
version: blue
```

and apply the Service manifest.

Traffic then returns to Blue without redeploying either version.

```text
                 Service
                    │
              version=green
                    │
                    ▼
                 Green v2
                    ❌
                    │
                 rollback
                    │
                    ▼
              version=blue
                    │
                    ▼
                 Blue v1
                    ✅
```

---

# 39. Rolling Update vs Blue-Green

### Rolling Update

```text
v1 v1 v1
 ↓
v1 v1 v2
 ↓
v1 v2 v2
 ↓
v2 v2 v2
```

Gradually replaces the old version.

### Blue-Green

```text
Blue v1        Green v2
3 Pods         3 Pods
   │              │
   └──────┬───────┘
          │
       Service
          │
     choose one
```

Both versions exist simultaneously and traffic is switched between them.

---

# 40. Foundational Architecture

```text
                    Kubernetes Cluster
                           │
                       Node(s)
                           │
                          Pods
                           │
                      Containers
                           │
                      Applications


Deployment
    │
    ▼
ReplicaSet
    │
    ▼
Pods


Ingress
    │
    ▼
Service
    │
    ▼
Pods


ConfigMap ──────┐
                ├──> Pod / Container
Secret ─────────┘


Health Probes
    │
    ├── Liveness
    └── Readiness
```

---

# 41. Core Command Cheat Sheet

## Nodes

```powershell
kubectl get nodes
kubectl get nodes -o wide
```

## Pods

```powershell
kubectl get pods
kubectl get pods -o wide
kubectl get pods --show-labels
kubectl describe pod <pod>
kubectl logs <pod>
kubectl delete pod <pod>
```

## Deployments

```powershell
kubectl get deployments
kubectl describe deployment <deployment>
kubectl scale deployment <deployment> --replicas=5
kubectl rollout status deployment/<deployment>
kubectl rollout undo deployment/<deployment>
```

## ReplicaSets

```powershell
kubectl get replicasets
kubectl describe replicaset <replicaset>
```

## Services

```powershell
kubectl get services
kubectl describe service <service>
```

## Configuration

```powershell
kubectl get configmaps
kubectl describe configmap <configmap>
kubectl get secrets
kubectl describe secret <secret>
```

## Events

```powershell
kubectl get events --sort-by=.lastTimestamp
```

Specific Pod:

```powershell
kubectl get events --field-selector involvedObject.name=<pod-name> --sort-by=.lastTimestamp
```

## YAML

```powershell
kubectl apply -f <file>
kubectl get <resource> <name> -o yaml
```

---

# 42. Troubleshooting Decision Tree

```text
Application problem
       │
       ▼
kubectl get pods
       │
       ├── Pod not Running?
       │       │
       │       ├── kubectl describe pod
       │       └── kubectl get events
       │
       └── Pod Running?
               │
               ▼
          kubectl logs
               │
               ▼
       Application error?
               │
               └── Fix application


If Pod is healthy but networking fails:

kubectl get services
       │
       ▼
kubectl describe service
       │
       ▼
Check selector
       │
       ▼
Check endpoints
       │
       ▼
Check targetPort
       │
       ▼
Verify application is listening
```

---

# 43. Kubernetes Foundation Scope

The project intentionally focuses on foundational Kubernetes knowledge rather than becoming Kubernetes-specialist training.

Advanced topics deliberately left for later include:

- Advanced scheduling
- Custom controllers/operators
- CRDs
- Advanced networking
- Service mesh
- Advanced RBAC
- Advanced storage
- StatefulSets in depth
- DaemonSets in depth
- Advanced admission control
- Kubernetes internals
- Advanced HPA configuration

The objective is to confidently use Kubernetes as part of the larger cloud-native architecture.

---

# 44. Moving from Local Kubernetes to EKS

The local Kubernetes environment provides the foundation for understanding EKS.

Local:

```text
Local Kubernetes
       │
       ▼
Local Node
       │
       ▼
Pods
       │
       ▼
Containers
```

Later in AWS:

```text
Amazon EKS
       │
       ▼
Worker compute / Nodes
       │
       ▼
Pods
       │
       ▼
Containers
```

The Kubernetes concepts learned locally continue to apply when moving to EKS.

The major difference is that AWS provides managed Kubernetes control-plane capabilities and AWS integrations around the cluster.

---

# 45. Completed Kubernetes Foundation

From the project backlog:

```text
- [x] Learn Pods
- [x] Learn Deployments
- [x] Learn Services
- [x] Learn Ingress
- [x] Learn ConfigMaps
- [x] Learn Secrets
- [x] Add health probes
- [ ] Configure resource limits
- [ ] Configure HPA
- [x] Practice troubleshooting
```

Additional deployment knowledge completed:

```text
- [x] Rolling updates
- [x] Rollback
- [x] Blue-Green deployment
- [x] Blue → Green traffic switching
```

Resource limits and HPA were intentionally left unchecked because they were not part of the completed foundational labs.

---

# 46. Final Mental Model

If you remember one diagram:

```text
                         CLUSTER
                            │
                         NODE(S)
                            │
                           POD
                            │
                        CONTAINER
                            │
                       APPLICATION


                    DEPLOYMENT
                         │
                    REPLICASET
                         │
                        PODS


USER / CLIENT
      │
      ▼
   INGRESS
      │
      ▼
   SERVICE
      │
      ▼
    PODS


CONFIGMAP ──────┐
                ├──> APPLICATION
SECRET ─────────┘


APPLICATION
     │
     ├── LIVENESS  → "Am I alive?"
     │
     └── READINESS → "Can I receive traffic?"


DEPLOYMENT STRATEGIES

Rolling Update:
v1 → v2 gradually

Blue-Green:
Blue v1 ←→ Service ←→ Green v2
```

This is the foundational Kubernetes knowledge needed before continuing into the project's CI/CD → ECR → EKS workflow.
