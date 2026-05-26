# DevOps Learning Journey — Complete Project Notes
**By: Virender (GitHub: Virender33)**
**AWS Account: 525530758671 | Region: ap-south-1 (Mumbai)**

---

## Infrastructure Details (Always Reference This)

| Resource | Value |
|----------|-------|
| AWS Account | 525530758671 |
| Region | ap-south-1 (Mumbai) |
| Free tier EC2 | t3.small or smaller ONLY |
| Terraform state S3 | terraform-state-525530758671 |
| DynamoDB lock table | terraform-state-lock |
| GitHub repo | https://github.com/Virender33/helm-argocd-demo |
| ECR repo | 525530758671.dkr.ecr.ap-south-1.amazonaws.com/myapp |
| Jenkins EC2 | i-0d224abf6fcf194a4 (stop when not in use!) |
| Jenkins SSH | ssh -i ~/.ssh/jenkins-key.pem ubuntu@IP |
| Jenkins URL | http://EC2_PUBLIC_IP:8080 |
| TF-3 code | ~/terraform-projects/tf-3-eks |
| Helm/App code | ~/helm-projects |

---

## Completed Projects

### ✅ Kubernetes A — Pods, Deployments, Scaling
**Key concepts:** Deployment > ReplicaSet > Pod hierarchy, rolling updates, rollback
**Key commands:**
```bash
kubectl apply -f file.yaml
kubectl get pods -o wide
kubectl scale deployment NAME --replicas=5
kubectl rollout undo deployment/NAME
kubectl rollout history deployment/NAME
```
**Interview:** Deployment manages ReplicaSet which manages Pods. Never run raw Pods in production.

---

### ✅ Kubernetes B — Networking & Services
**Key concepts:** ClusterIP/NodePort/LoadBalancer/Ingress, CoreDNS, kube-proxy
**Key commands:**
```bash
kubectl get svc -n ns
kubectl get endpoints SVC -n ns   # empty = selector mismatch!
kubectl describe ingress NAME -n ns
```
**Interview:** Use 1 ELB with Ingress, not 1 ELB per service. Empty endpoints = selector mismatch.

---

### ✅ Kubernetes C — Storage, ConfigMaps, Secrets
**Key concepts:** PVC > PV > StorageClass chain, liveness vs readiness probes
**Key commands:**
```bash
kubectl get pvc -n ns
kubectl get pv
echo "value" | base64 --decode
```
**Interview:** Liveness probe fails = container killed (RESTARTS goes up). Readiness probe fails = removed from endpoints (RESTARTS stays 0).

---

### ✅ Kubernetes D — Troubleshooting
**7 scenarios:** CrashLoopBackOff (exit 1), OOMKilled (exit 137), ImagePullBackOff, selector mismatch, pending pods, liveness probe fail, readiness probe fail
**Debug order:** get pods → describe pod → logs → endpoints → top pods

---

### ✅ Terraform TF-1 — Basics
**Key concepts:** init/plan/apply/destroy, state file, variables, outputs
**Key commands:**
```bash
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy
terraform state list
terraform output -json
```
**Interview:** Plan = code vs state file (not code vs AWS directly). State file = Terraform's memory.

---

### ✅ Terraform TF-2 — Remote State
**Key concepts:** S3 backend, DynamoDB locking, force-unlock, S3 versioning
**Setup commands:**
```bash
aws s3api create-bucket --bucket NAME --region ap-south-1 --create-bucket-configuration LocationConstraint=ap-south-1
aws s3api put-bucket-versioning --bucket NAME --versioning-configuration Status=Enabled
aws dynamodb create-table --table-name terraform-state-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region ap-south-1
terraform force-unlock LOCK_ID
```
**Interview:** S3 = central state for team. DynamoDB = prevents concurrent applies. 181 bytes after destroy = empty state.

---

### ✅ Terraform TF-3 — EKS with Modules
**Key concepts:** Modules (vpc/iam/eks), count, depends_on, jsonencode, taint, import
**Key commands:**
```bash
cd ~/terraform-projects/tf-3-eks
terraform apply -auto-approve    # creates 22 resources
aws eks update-kubeconfig --region ap-south-1 --name tf3-eks-cluster
kubectl get nodes
terraform taint module.eks.aws_eks_node_group.main
terraform import aws_security_group.manual SG_ID
```
**IMPORTANT:** t3.medium blocked! Use t3.small for node groups.
**Interview:** Modules = reusable Terraform packages. Like functions in programming.

---

### ✅ Helm HELM-1 — Fundamentals
**Key concepts:** Chart/Release/Values/Repository, revision history, rollback
**Key commands:**
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-nginx bitnami/nginx -n helm-demo --set service.type=LoadBalancer
helm upgrade my-nginx bitnami/nginx -n helm-demo --set replicaCount=3
helm rollback my-nginx 1 -n helm-demo   # creates NEW revision!
helm history my-nginx -n helm-demo
helm uninstall my-nginx -n helm-demo    # ALWAYS before terraform destroy!
```
**IMPORTANT:** Always helm uninstall BEFORE terraform destroy. ELB blocks VPC deletion!

---

### ✅ Helm HELM-2 — Custom Charts
**Key concepts:** helm create, Chart.yaml, values.yaml, templates with {{ }}, dev/prod values
**Key commands:**
```bash
helm create myapp-chart
helm template my-release ./myapp-chart     # like terraform plan!
helm install my-release ./myapp-chart -n helm-demo
```
**Chart location:** ~/helm-projects/myapp-chart/ and apps/myapp-chart/ in GitHub

---

### ✅ ArgoCD — GitOps
**Key concepts:** GitOps, reconciliation loop, self-healing, auto-sync, sync vs health status
**Key commands:**
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
argocd login localhost:8080 --username admin --password PASSWORD --insecure
argocd app create myapp --repo https://github.com/Virender33/helm-argocd-demo.git --path apps/myapp-chart --dest-server https://kubernetes.default.svc --dest-namespace myapp --sync-policy automated --auto-prune --self-heal
argocd app sync myapp
argocd app history myapp
```
**3 demos proved:**
1. git push → ArgoCD auto-deploys (GitOps)
2. kubectl delete pod → ArgoCD recreates in 3 seconds (self-healing)
3. git push revert → ArgoCD removes pod (rollback)

---

### ✅ Jenkins-1 — Pipeline Basics
**Key concepts:** Pipeline job, Jenkinsfile, stages, BUILD_NUMBER, Poll SCM trigger
**Setup (one time):**
```bash
# Launch EC2
aws ec2 run-instances --image-id ami-0f58b397bc5c1f2e8 --instance-type t3.small --key-name jenkins-key --security-group-ids SG_ID --region ap-south-1
# SSH
ssh -i ~/.ssh/jenkins-key.pem ubuntu@EC2_IP
```
**Jenkins proved:** Build triggered by SCM change (not manual). Poll SCM every minute.

---

### ✅ Jenkins-2 — Docker + ECR Pipeline
**Key concepts:** Docker build in pipeline, push to ECR, 2-machine setup, AWS credentials for jenkins user
**Files created:**
- `myapp/app.py` — Flask app
- `myapp/test_app.py` — pytest tests
- `myapp/requirements.txt` — pinned dependencies
- `Dockerfile` — image build instructions
- `Jenkinsfile` — pipeline as code

**Working pipeline stages:**
1. Checkout → git clone from GitHub
2. Test → pytest (safety net!)
3. Build → docker build -t myapp:${BUILD_NUMBER} .
4. Push → docker push to ECR

**ECR images created:** myapp:12, myapp:13

**Critical setup steps:**
```bash
# Allow jenkins sudo
echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/jenkins
# Copy AWS creds to jenkins user
sudo mkdir -p /var/lib/jenkins/.aws
sudo cp ~/.aws/credentials /var/lib/jenkins/.aws/credentials
sudo chown -R jenkins:jenkins /var/lib/jenkins/.aws
```

---

## ⏳ Remaining Projects

### Jenkins-3 — Full CI/CD Pipeline
**Goal:** Jenkins builds image → updates Helm values.yaml → ArgoCD auto-deploys to EKS
**Flow:**
```
git push → Jenkins → docker build → ECR
        → Jenkins updates values.yaml image.tag
        → git push values.yaml
        → ArgoCD detects change
        → ArgoCD deploys to EKS
```

### Ansible-1 — Fundamentals
Playbooks, roles, inventory, ad-hoc commands

### Ansible-2 — Terraform + Ansible
Terraform creates infra → Ansible configures it

---

## Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| t3.medium blocked | Use t3.small (free tier eligible) |
| DynamoDB lock stuck | terraform force-unlock LOCK_ID |
| VPC deletion hangs | helm uninstall first, wait 2 mins |
| Jenkins user no AWS creds | Copy ~/.aws/ to /var/lib/jenkins/.aws/ |
| sudo needs password in pipeline | echo "jenkins ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/jenkins |
| EC2 SSH wrong user | Ubuntu = ubuntu@IP, Amazon Linux = ec2-user@IP |
| Jenkinsfile fix overwritten | Fix on Mac → git push (never fix directly on server!) |

---

## Key Architecture Decisions

```
Terraform  → creates AWS infra (EKS, VPC, ECR)
Helm       → packages Kubernetes apps as templates
ArgoCD     → deploys Helm charts from GitHub to EKS
Jenkins    → builds Docker images, triggers ArgoCD
Ansible    → configures servers (install software)

All together:
  Terraform creates EKS
  Jenkins builds myapp:14 → pushes to ECR
  Jenkins updates Helm values.yaml image.tag: "14"
  ArgoCD detects values.yaml change
  ArgoCD deploys myapp:14 to EKS
  Zero manual steps!
```
