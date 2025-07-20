# Task 2: Deploy Application

**What you'll do:** Build a Docker image and deploy it to Kubernetes  
**Time:** 25 minutes

## Why We Need This

Now that you have a Kubernetes cluster, let's put an application on it! We'll build a simple web application, package it in a Docker container, and deploy it to your cluster.

**Docker** packages your application with everything it needs to run.  
**Kubernetes** takes that packaged application and runs it reliably on your cluster.

---

## Step 1: Navigate and Explore

```bash
# Go to the app deployment directory
cd ../02-app-deployment

# See what we have
ls -la
```

**What you'll see:**
- `app/` - Contains our sample application
- `main.tf` - Terraform configuration to deploy the app
- `variables.tf` - Settings we can customize
- `outputs.tf` - Information Terraform will show us after deployment
- `versions.tf` - Terraform provider requirements

```bash
# Look at our sample application
ls app/
cat app/app.py
```

**What you'll see:** A simple Python web application that:
- Responds to web requests
- Has a health check endpoint
- Logs information (useful for monitoring later)

## Step 2: Build the Application

```bash
# Build a Docker image of our application
cd app/
docker build -t devops-sample-app:latest .
```

**What this does:**
1. Takes our Python application
2. Packages it with Python and all dependencies
3. Creates a "Docker image" - like a blueprint for running our app
4. Tags it with the name "devops-sample-app"

**You'll see:** Docker downloading Python, installing dependencies, and creating the image.

```bash
# Go back to the deployment directory
cd ..
```

## Step 4: Deploy to Kubernetes

```bash
# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Initialize Terraform for this deployment
terraform init

# See what Terraform will create
terraform plan
```

**What you'll see:** Terraform will create:
- A namespace (like a folder for organizing your apps)
- A deployment (tells Kubernetes how to run your app)
- A service (gives your app a network address)
- **Automatic image loading** (Terraform will load your Docker image into Kind)

```bash
# Deploy the application
terraform apply
```

**Type `yes` when prompted.**

**What this does:**
- **Automatically loads your Docker image** into the Kind cluster
- Creates a namespace called "devops-app"
- Starts 3 copies of your application (for reliability)
- Sets up networking so you can access your app

**Smart feature:** If you rebuild your Docker image and run `terraform apply` again, it will automatically detect the change and update your deployment!

## Step 5: Verify the Deployment

```bash
# Check if your application pods are running
kubectl get pods -n devops-app
```

**What you should see:**
```
NAME                         READY   STATUS    RESTARTS   AGE
sample-app-xxxxxxxxx-xxxxx   1/1     Running   0          1m
sample-app-xxxxxxxxx-xxxxx   1/1     Running   0          1m
sample-app-xxxxxxxxx-xxxxx   1/1     Running   0          1m
```

**This means:** Your application is running in 3 copies for reliability!

```bash
# Check the service
kubectl get service -n devops-app
```

## Step 6: Test Your Application

```bash
# Set up port forwarding to access your app
kubectl port-forward service/sample-app-service 8080:80 -n devops-app
```

**Keep this terminal open** - it's forwarding traffic to your app.

**Open a new terminal** and test:
```bash
# Test your application
curl http://localhost:8080

# Test the health check
curl http://localhost:8080/health
```

**What you should see:** 
- Your application responding with a welcome message
- A health check showing your app is healthy

**🎉 Success!** Your application is now running on Kubernetes!

---

## What Just Happened?

1. **You built a Docker image** - Packaged your application with everything it needs
2. **You deployed to Kubernetes** - Used Terraform to tell Kubernetes how to run your app
3. **Kubernetes made it reliable** - It's running 3 copies and will restart them if they crash
4. **You accessed your app** - Used port-forwarding to connect to your application

## 🎯 Task Complete!

You now have:
- ✅ A containerized application built with Docker
- ✅ The application deployed on Kubernetes with 3 replicas
- ✅ A running web service you can access
- ✅ Understanding of the container deployment process

**Ready for the next task?** Go to `../03-monitoring/README.md`

---

## Troubleshooting

**Problem:** Docker build fails  
**Solution:** Make sure Docker Desktop is running

**Problem:** Pods stuck in "Pending" or "ImagePullBackOff"  
**Solution:** Run `kind load docker-image devops-sample-app:latest --name devops-workshop` again

**Problem:** Can't access localhost:8080  
**Solution:** Make sure port-forward command is still running in another terminal

**Problem:** kubectl commands fail  
**Solution:** Make sure you completed Task 1 successfully (cluster is running)
