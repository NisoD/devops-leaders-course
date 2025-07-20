# Task 1: Create Kubernetes Cluster

**What you'll do:** Use Terraform to create a local Kubernetes cluster  
**Time:** 25 minutes

## Why We Need This

Before we can deploy applications, we need a place to run them. Kubernetes is like having multiple computers working together to run your applications reliably. Instead of setting this up manually (which takes hours), we'll use **Infrastructure as Code** to create it automatically.

**Infrastructure as Code** means: Write a configuration file that describes what you want, then let tools create it for you.

---

## Step 1: Navigate to This Task

```bash
# Go to the cluster setup directory
cd 01-cluster-setup

# See what files we have
ls -la
```

**What you'll see:**
- `main.tf` - Tells Terraform what to create
- `variables.tf` - Settings we can change
- `outputs.tf` - Information Terraform will show us after creating things

## Step 2: Initialize Terraform

```bash
# Download the tools Terraform needs
terraform init
```

**What this does:** Downloads the "Kind provider" - software that knows how to create Kubernetes clusters using Docker.

**Expected output:** You should see "Terraform has been successfully initialized!"

## Step 3: See What Will Be Created

```bash
# Show what Terraform will create (without actually creating it)
terraform plan
```

**What this does:** Terraform reads our configuration files and tells us exactly what it will create. This is like a preview.

**What you'll see:** Terraform will tell you it wants to create:
- A Kubernetes cluster named "devops-workshop"
- 3 nodes (1 control node, 2 worker nodes)
- A configuration file to connect to the cluster

## Step 4: Create the Cluster

```bash
# Actually create the cluster
terraform apply
```

**Type `yes` when it asks for confirmation.**

**What this does:** 
- Creates Docker containers that act like separate computers
- Installs Kubernetes on these "computers"
- Sets up networking so they can talk to each other
- Gives you a file to connect to this cluster

**This takes 2-3 minutes.** You'll see lots of output as it creates everything.

## Step 5: Verify It Worked

```bash
# Check if your cluster is running
kubectl get nodes
```

**What you should see:**
```
NAME                            STATUS   ROLES           AGE   VERSION
devops-workshop-control-plane   Ready    control-plane   2m    v1.27.3
devops-workshop-worker          Ready    <none>          2m    v1.27.3
devops-workshop-worker2         Ready    <none>          2m    v1.27.3
```

**This means:** You now have a 3-node Kubernetes cluster running on your computer!

```bash
# See the cluster information
kubectl cluster-info
```

**What you should see:** URLs showing where your cluster's services are running.

---

## What Just Happened?

1. **You used Infrastructure as Code** - Instead of clicking through dozens of setup screens, you described what you wanted in a file and let Terraform create it.

2. **You created a Kubernetes cluster** - You now have multiple "computers" (Docker containers) working together to run applications.

3. **Everything is reproducible** - Anyone can run the same `terraform apply` command and get exactly the same cluster.

4. **It's fast and reliable** - What used to take hours of manual setup now takes 3 minutes and works the same way every time.

## 🎯 Task Complete!

You now have:
- ✅ A running Kubernetes cluster with 3 nodes
- ✅ Connection configured (kubectl can talk to your cluster)
- ✅ Understanding of Infrastructure as Code basics

**Ready for the next task?** Go to `../02-app-deployment/README.md`

---

## Troubleshooting

**Problem:** `terraform init` fails  
**Solution:** Make sure Docker is running (`docker ps` should work)

**Problem:** `kubectl get nodes` shows "connection refused"  
**Solution:** Run `terraform apply` again - sometimes it takes a moment to start

**Problem:** Nodes show "NotReady"  
**Solution:** Wait 1-2 minutes - Kubernetes needs time to start all its components
