# CI/CD Learning Notes

## Cloud-Native Test Platform

These notes explain the CI/CD pipeline built for the Cloud-Native Test Platform, with emphasis on concepts and the thinking process needed to design similar pipelines in future projects.

---

# 1. Big Picture

The reusable mental model is:

```text
GET
 ↓
TEST
 ↓
BUILD
 ↓
SCAN
 ↓
AUTH
 ↓
PUBLISH
 ↓
DEPLOY
 ↓
VERIFY
```

Current project status:

```text
GET       ✅
TEST      ✅
BUILD     ✅
SCAN      ✅
AUTH      ✅
PUBLISH   ✅
DEPLOY    ⏳
VERIFY    ⏳
```

Technologies:

```text
GET       → GitHub Checkout
TEST      → Pytest
BUILD     → Docker
SCAN      → Trivy
AUTH      → GitHub OIDC → AWS STS → IAM Role
PUBLISH   → Amazon ECR
DEPLOY    → Amazon EKS (planned)
VERIFY    → Smoke/health tests (planned)
```

---

# 2. CI vs CD

## Continuous Integration

CI automatically validates changes.

Typical flow:

```text
Checkout
 ↓
Install dependencies
 ↓
Run tests
 ↓
Build artifact
 ↓
Security checks
```

The goal is to catch problems early.

## Continuous Delivery / Deployment

CD continues after validation:

```text
Publish artifact
 ↓
Deploy
 ↓
Verify
 ↓
Rollback if necessary
```

For this project, EKS deployment and smoke testing are planned.

---

# 3. GitHub Actions Structure

The basic hierarchy is:

```text
Workflow
 └── Job
      └── Steps
```

Example:

```yaml
name: CI

on:
  push:

jobs:
  test-and-build:
    runs-on: ubuntu-latest

    steps:
      - name: Example
        run: echo "Hello"
```

Remember:

| Element | Meaning |
|---|---|
| `name` | Workflow name |
| `on` | When it runs |
| `jobs` | Work to perform |
| `runs-on` | Runner/machine |
| `steps` | Individual operations |

Do not focus on memorizing indentation. Remember the hierarchy.

---

# 4. Triggers

The `on:` section answers:

> When should this automation run?

Possible triggers include:

- Push
- Pull request
- Specific branches
- Tags
- Manual execution
- Scheduled execution

A mature design might be:

```text
Pull Request
 ↓
Test + Build + Scan

Merge to main
 ↓
Test + Build + Scan
 ↓
Publish
 ↓
Deploy
```

---

# 5. GitHub Actions Runner

A runner is the machine that executes the workflow.

This project uses:

```yaml
runs-on: ubuntu-latest
```

Conceptually:

```text
GitHub
 ↓
Runner
 ↓
Workflow executes
 ↓
Job finishes
 ↓
Runner is temporary
```

The Docker image built on the runner is therefore temporary unless it is published somewhere persistent.

```text
Runner
 ↓
Docker image
 ↓
Amazon ECR
 ↓
Persistent storage
```

---

# 6. `uses` vs `run`

`uses` means use an existing reusable action:

```yaml
uses: actions/checkout@v4
```

`run` means execute a shell command:

```yaml
run: pytest
```

Remember:

```text
uses → reusable Action
run  → shell command
```

Exact action versions and syntax can be looked up when needed.

---

# 7. Checkout

The runner needs the repository files:

```yaml
- name: Checkout repository
  uses: actions/checkout@v4
```

Mental model:

```text
New runner
 ↓
Checkout
 ↓
Repository files available
```

After checkout, commands can access project files such as:

```text
app/
tests/
docker/
pytest.ini
```

---

# 8. Prepare the Environment

The runner needs the application's runtime.

This project uses Python:

```yaml
- name: Set up Python
  uses: actions/setup-python@v5
  with:
    python-version: "3.13"
```

Then:

```yaml
- name: Install dependencies
  run: pip install -r app/requirements.txt
```

The general question is:

> What does my application require?

Examples:

```text
Python → Setup Python → pip install
Node   → Setup Node   → npm install
Java   → Setup Java   → Maven/Gradle
```

Remember the concept, not every command.

---

# 9. Test Before Publishing

The project runs:

```yaml
- name: Run tests
  run: pytest
```

Principle:

> Validate first, publish later.

If tests fail:

```text
Tests ❌
 ↓
STOP
```

This prevents known-bad code from progressing.

The current application test suite validates the root and health endpoints.

---

# 10. Build the Artifact

The project builds a Docker image:

```text
cloud-native-test-platform:ci
```

Conceptually:

```text
Source code
 ↓
Docker build
 ↓
Docker image
```

Other projects might produce:

```text
Java       → JAR
Frontend   → static build
.NET       → package
Container  → Docker image
```

Remember:

> Build creates the artifact that later stages publish and deploy.

---

# 11. Security Scanning

Trivy scans the Docker image:

```text
Docker image
 ↓
Trivy
 ↓
Known vulnerabilities
```

Preferred order:

```text
BUILD
 ↓
SCAN
 ↓
PUBLISH
```

The current pipeline reports vulnerabilities but does not yet fail automatically based on severity.

A future policy might be:

```text
LOW       → allow
MEDIUM    → allow
HIGH      → fail
CRITICAL  → fail
```

The exact policy depends on project/organization requirements.

Key learning:

> Security checks belong inside the pipeline, not as an afterthought.

---

# 12. Authenticate Only When AWS Is Needed

The pipeline first performs work that does not require AWS:

```text
Checkout
 ↓
Setup
 ↓
Install
 ↓
Test
 ↓
Docker build
 ↓
Trivy
```

Then AWS authentication happens.

Useful principle:

> Do work that does not require cloud credentials before requesting cloud access.

---

# 13. GitHub OIDC

This project uses GitHub OIDC instead of long-lived AWS access keys.

Flow:

```text
GitHub Actions
 ↓
OIDC token
 ↓
AWS STS
 ↓
IAM Role
 ↓
Temporary AWS credentials
```

Workflow permission:

```yaml
permissions:
  id-token: write
  contents: read
```

`contents: read` allows repository contents to be read.

`id-token: write` allows the workflow to request an OIDC identity token.

Important:

> `id-token: write` does not itself grant AWS permissions.

It allows the workflow to obtain an identity token that AWS can evaluate.

---

# 14. Why OIDC Instead of AWS Access Keys?

Avoid this pattern when OIDC is appropriate:

```text
GitHub
 ↓
Long-lived AWS access key
 ↓
AWS
```

Prefer:

```text
GitHub
 ↓
OIDC
 ↓
AWS STS
 ↓
Temporary credentials
```

Benefits:

- No long-lived AWS access key stored in GitHub
- Temporary credentials
- IAM role-based authorization
- Trust can be restricted to the intended repository/branch

Remember:

> For GitHub Actions accessing AWS, prefer OIDC federation and IAM roles instead of long-lived AWS credentials.

---

# 15. IAM Role

The project created:

```text
GitHubActions-ECR-CloudNativeTestPlatform
```

An IAM role has two important concepts:

```text
TRUST
 ↓
Who can assume this role?

PERMISSIONS
 ↓
What can the role do?
```

This distinction is fundamental.

---

# 16. IAM Trust Policy = WHO

The trust policy answers:

> Who is allowed to assume this role?

The role trusts the GitHub OIDC provider:

```text
token.actions.githubusercontent.com
```

The trust is restricted to the project's repository and `main` branch using GitHub's immutable subject claim format.

Conceptually:

```text
GitHub Actions
 ↓
OIDC token
 ↓
Repository identity + branch
 ↓
IAM Trust Policy
 ↓
Allowed
```

Remember:

> Trust policy = WHO.

---

# 17. IAM Permissions Policy = WHAT

The permissions policy answers:

> Once the role is trusted, what can it do?

The project role has only the ECR operations needed to push the application image.

Examples include:

```text
ecr:GetAuthorizationToken
ecr:BatchCheckLayerAvailability
ecr:InitiateLayerUpload
ecr:UploadLayerPart
ecr:CompleteLayerUpload
ecr:PutImage
```

The repository is restricted to:

```text
cloud-native-test-platform
```

Remember:

> Permissions policy = WHAT.

This demonstrates least privilege.

---

# 18. OIDC Role-Assumption Flow

The workflow uses the AWS credentials action:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v6
  with:
    role-to-assume: arn:aws:iam::825765413460:role/GitHubActions-ECR-CloudNativeTestPlatform
    aws-region: ap-south-1
```

Conceptually:

```text
GitHub Actions
 ↓
Request OIDC token
 ↓
GitHub OIDC provider
 ↓
AWS STS
 ↓
Check IAM trust policy
 ↓
Trust matches
 ↓
Assume role
 ↓
Temporary AWS credentials
```

The relevant STS operation is:

```text
sts:AssumeRoleWithWebIdentity
```

---

# 19. Real Troubleshooting Lesson: Immutable Subject Claims

The first OIDC attempt failed with:

```text
Not authorized to perform sts:AssumeRoleWithWebIdentity
```

The original trust policy expected:

```text
repo:Keval099/cloud-native-test-platform:ref:refs/heads/main
```

The repository instead uses immutable subject claims, with a format containing immutable owner/repository IDs.

The trust policy was corrected to match the actual GitHub identity claim.

Result:

```text
GitHub OIDC
 ↓
IAM trust policy
 ↓
MATCH
 ↓
Role assumption succeeds
```

Learning:

> When OIDC role assumption fails, do not immediately loosen the trust policy. Check the actual identity claim and make the trust relationship match the intended identity.

---

# 20. ECR Authentication

After AWS authentication succeeds, Docker still needs to authenticate to ECR.

The pipeline uses:

```bash
aws ecr get-login-password --region ap-south-1 |
docker login --username AWS --password-stdin 825765413460.dkr.ecr.ap-south-1.amazonaws.com
```

Conceptually:

```text
OIDC
 ↓
IAM Role
 ↓
Temporary AWS credentials
 ↓
AWS CLI
 ↓
ECR login
 ↓
Docker authenticated to ECR
```

Important distinction:

```text
OIDC + IAM Role
→ GitHub runner is authenticated to AWS

ECR login
→ Docker is authenticated to the ECR registry
```

---

# 21. Docker Tag

The local image is:

```text
cloud-native-test-platform:ci
```

The ECR destination tag is:

```text
825765413460.dkr.ecr.ap-south-1.amazonaws.com/cloud-native-test-platform:ci
```

Conceptually:

```text
Local image
 ↓
docker tag
 ↓
ECR destination
```

Important:

> `docker tag` does not upload the image.

It creates another reference to the same image.

Think of it as putting the destination address on the package.

---

# 22. Docker Push

The final publish operation is:

```bash
docker push 825765413460.dkr.ecr.ap-south-1.amazonaws.com/cloud-native-test-platform:ci
```

This uploads the image:

```text
GitHub Runner
 ↓
Docker image
 ↓
Amazon ECR
```

ECR then stores the image persistently.

---

# 23. Current Complete Pipeline

```text
Developer
 ↓
GitHub
 ↓
GitHub Actions
 ↓
Checkout
 ↓
Setup Python
 ↓
Install dependencies
 ↓
Pytest
 ↓
Docker build
 ↓
Trivy scan
 ↓
GitHub OIDC
 ↓
AWS STS
 ↓
IAM Role
 ↓
ECR Login
 ↓
Docker Tag
 ↓
Docker Push
 ↓
Amazon ECR
```

---

# 24. How to Design a Pipeline From Scratch

Do not start with an empty YAML file and try to remember syntax.

Start with plain English.

Requirement:

> Build a CI pipeline for a Python application and publish its Docker image to ECR.

Write:

```text
1. Decide when it runs
2. Select runner
3. Checkout code
4. Set up Python
5. Install dependencies
6. Run tests
7. Build Docker image
8. Scan image
9. Authenticate to AWS
10. Login to ECR
11. Tag image
12. Push image
13. Deploy
14. Verify
```

Then translate each sentence into YAML.

This is the reusable skill.

---

# 25. Pipeline Design Checklist

## Trigger

- When should it run?
- Push?
- Pull request?
- Main?
- Tag?
- Manual?

## Environment

- What runtime is required?
- What dependencies need installation?
- What tools are required?

## Validation

- What tests should run?
- What should stop the pipeline?

## Build

- What is the deployable artifact?
- Docker image?
- JAR?
- Package?

## Security

- Dependency scanning?
- Container scanning?
- IaC scanning?
- Secret scanning?

## Authentication

- Does the pipeline need AWS/cloud access?
- Can OIDC/federation be used?
- What identity should be trusted?

## Authorization

- What exact permissions are required?
- Can permissions be restricted to one resource?

## Publish

- Where does the artifact go?
- ECR?
- Package registry?
- Artifact repository?

## Deployment

- Where will it run?
- EKS?
- ECS?
- VM?
- Serverless?

## Verification

- How will success be verified?
- Health endpoint?
- Smoke test?
- Metrics?

## Recovery

- What happens if deployment fails?
- Rollback?
- Previous image?
- Blue-Green?

---

# 26. What to Remember vs What to Look Up

## Remember the concepts

```text
Workflow → Jobs → Steps
```

```text
Trigger → When
Runner  → Where
Steps   → What
```

```text
Test before publish
```

```text
Build → Scan → Publish
```

```text
Trust policy = WHO
Permissions policy = WHAT
```

```text
OIDC → STS → IAM Role → Temporary credentials
```

```text
ECR Login → Tag → Push
```

Overall:

```text
GET → TEST → BUILD → SCAN → AUTH → PUBLISH → DEPLOY → VERIFY
```

## Look up the exact syntax

Do not waste time memorizing:

- Exact action versions
- Exact YAML indentation
- Exact Trivy flags
- Exact AWS CLI options
- Exact IAM JSON syntax
- Exact Docker command options

Understanding what each operation accomplishes is more valuable than memorizing every character.

---

# 27. What to Avoid

## Avoid long-lived AWS credentials

Prefer:

```text
GitHub OIDC
 ↓
IAM Role
 ↓
Temporary credentials
```

## Avoid AdministratorAccess

Do not solve permission problems by attaching administrator permissions.

Ask:

> What exact AWS API operations does this pipeline need?

## Avoid unnecessarily broad resources

Prefer a specific ECR repository over all ECR repositories when possible.

## Avoid deploying before validation

Prefer:

```text
Test
 ↓
Build
 ↓
Scan
 ↓
Publish
```

rather than publishing/deploying first and discovering problems afterward.

## Avoid blindly copying pipelines

Before adding a step, ask:

> What does this step accomplish?

If you cannot explain it, investigate it first.

## Avoid generic image tags in mature deployment systems

The current:

```text
:ci
```

tag is acceptable for learning.

A stronger strategy is a commit-based tag:

```text
Git commit abc1234
 ↓
Docker image :abc1234
 ↓
ECR
 ↓
EKS
```

This improves traceability and rollback.

---

# 28. Current Project Status

```text
GitHub Actions CI              ✅
Python tests                   ✅
Docker build                   ✅
Trivy scan                     ✅
GitHub OIDC                    ✅
AWS IAM role                   ✅
Least-privilege ECR policy     ✅
AWS role assumption            ✅
ECR authentication             ✅
Docker tagging                 ✅
ECR push                       ✅

EKS deployment                 ⏳
Smoke tests                    ⏳
Automated rollback             ⏳
```

---

# 29. Final Mental Model

If only one diagram is remembered:

```text
             CI
              |
              v
       GET → TEST → BUILD
                    |
                    v
                   SCAN
                    |
                    v
             AUTHENTICATE
                    |
                    v
                PUBLISH
                    |
                    v
             Amazon ECR
                    |
                    v
                  CD
                    |
                    v
                 DEPLOY
                    |
                    v
                 VERIFY
```

AWS authentication:

```text
GitHub Actions
 ↓
OIDC
 ↓
AWS STS
 ↓
IAM Trust Policy
 ↓
IAM Role
 ↓
IAM Permissions
 ↓
ECR
```

The two IAM questions:

```text
TRUST:
"WHO are you?"
 ↓
GitHub repository/main branch

PERMISSIONS:
"WHAT can you do?"
 ↓
Specific ECR operations
```

The most reusable skill is:

```text
Requirement
 ↓
Pipeline stages
 ↓
Individual steps
 ↓
Tools/actions/commands
```

That is the approach to use when designing CI/CD pipelines in future projects.
