# Devops Leaders IL Course - Test App
This project is a Python web application built with FastAPI that displays the latest weather reports for a user-specified location along with an interactive map using Leaflet.js. The project uses Bootstrap for styling and features enhanced CSS to provide a modern and responsive user interface.
The Project was built with the assistance of OpenAI o3-mini-high model.


## Features

- **Weather Reports:** Get the latest weather information by entering a location.
- **Interactive Map:** Displays the location on an interactive map.
- **Enhanced UI:** Modern and responsive design using Bootstrap and custom CSS.
- **API Integration:** Uses the [wttr.in API](https://wttr.in/) to fetch weather details.
- **CPU Stress Testing:** Optional CPU stress testing functionality (feature-flagged).
- **Kubernetes Deployment:** Ready for deployment on Kubernetes with plain manifests.

## Getting Started

### Prerequisites

- Python 3.8 or higher
- Docker (for containerization)
- Kind (for local Kubernetes testing)
- Kubectl (for Kubernetes management)

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/deftdot/devops-leaders-course-v2.git
cd devops-leaders-course-v2
```

2. **Create a virtual environment (optional, but recommended):**
```bash
python -m venv venv  
source venv/bin/activate  # On Windows: .\venv\Scripts\activate  
```

3. **Install the required packages:**
```bash
pip install -r requirements.txt  
```

### Running the Application

#### Local Development
**Run the FastAPI server using Uvicorn:**
```bash
uvicorn main:app --reload 
```
**Open your browser and navigate to:**
```bash
http://127.0.0.1:8000
```

#### Docker Deployment
**Build the Docker image:**
```bash
docker build -t devops-leaders-app:latest .
```

**Run the container:**
```bash
docker run -p 8000:8000 devops-leaders-app:latest
```

## Kubernetes Deployment with Kind

### Prerequisites for Kubernetes Deployment

1. **Install Kind:**
```bash
# On macOS
brew install kind

# On Windows (using Chocolatey)
choco install kind

# On Windows (using Scoop)
scoop install kind
```

2. **Install kubectl:**
```bash
# On macOS
brew install kubectl

# On Windows (using Chocolatey)
choco install kubernetes-cli

# On Windows (using Scoop)
scoop install kubectl
```

### Setting up Kind Cluster

1. **Create a Kind cluster:**
```bash
kind create cluster --name devops-leaders
```

2. **Verify cluster is running:**
```bash
kubectl cluster-info --context kind-devops-leaders
```

### Building and Loading Docker Image

1. **Build the Docker image:**
```bash
docker build -t devops-leaders-app:latest .
```

2. **Load the image into Kind:**
```bash
kind load docker-image devops-leaders-app:latest --name devops-leaders
```

### Deploying with Kubernetes Manifests

1. **Navigate to the manifests directory:**
```bash
cd k8s-manifests
```

2. **Deploy using the provided script:**
```bash
./deploy.sh
```

Alternatively, apply manifests manually:

3. **Apply manifests individually:**
```bash
# Create namespace
kubectl create namespace devops-leaders

# Apply manifests in order
kubectl apply -f configmap.yaml -n devops-leaders
kubectl apply -f service.yaml -n devops-leaders
kubectl apply -f deployment.yaml -n devops-leaders
```

4. **Check the deployment:**
```bash
kubectl get pods -n devops-leaders
kubectl get services -n devops-leaders
```

5. **Port forward to access the application:**
```bash
kubectl port-forward service/devops-leaders-app-service 8080:80 -n devops-leaders
```

6. **Access the application:**
Open your browser and navigate to: `http://localhost:8080`

### Kubernetes Resources

The deployment includes the following Kubernetes resources:

- **Deployment:** Runs the FastAPI application with 2 replicas by default
- **Service:** LoadBalancer service (tunneled through kubectl port-forward in Kind)
- **ConfigMap:** Non-sensitive configuration data including environment variables

#### Customizing the Deployment

You can customize the deployment by editing the manifest files:

- **`configmap.yaml`** - Update environment variables (e.g., set `STRESS_TEST_FLAG: "true"`)
- **`deployment.yaml`** - Change resource limits, replicas, or container settings
- **`service.yaml`** - Modify service type or ports

### Monitoring and Scaling

1. **Monitor pods:**
```bash
kubectl get pods -n devops-leaders -w
```

2. **View application logs:**
```bash
kubectl logs -l app.kubernetes.io/name=devops-leaders-app -n devops-leaders
```

3. **Scale manually (if needed):**
```bash
kubectl scale deployment devops-leaders-app-deployment --replicas=5 -n devops-leaders
```

## Stress Test Configuration and Cautions

The CPU stress test feature in this application is protected by a feature flag. To enable the CPU stress test functionality, set the environment variable **STRESS_TEST_FLAG** to `"true"` (case‑insensitive). You can do this by editing your `.env` file or by setting the variable in your shell. If this flag is missing, empty, or set to any other value, the stress test endpoints and UI section will be disabled.

### Configuration Options

- **Duration:**  
  Specify the total runtime (in seconds) for the CPU stress test via the "Duration (sec)" input.

- **Load:**  
  Set the desired CPU load percentage (0–100) using the slider.  
  **Note:** A load value above 50% will trigger a confirmation popup, warning that high CPU loads may heavily overburden your system.

### Caution

- **High CPU Load:**  
  Running the CPU stress test can significantly load your CPU across all cores, potentially degrading system performance or causing temporary unresponsiveness. Use this feature only in a controlled test environment.

- **Multiprocessing:**  
  The application employs multiprocessing to distribute the stress across all available CPU cores. Monitor your system's resource usage accordingly to avoid unintended impacts.

- **Feature Flag:**  
  Ensure that you understand the implications of enabling the stress test. It is recommended to leave the **STRESS_TEST_FLAG** disabled (or set to any value other than `"true"`) during normal operation.


## Code Quality, Secrets, and Vulnerability Checks
### Overview

- **Unit Tests:** The provided `test_main.py` uses pytest and FastAPI's TestClient to validate key endpoints. The weather endpoint test uses monkeypatching to simulate external API responses.

- **Linting and Security:** The instructions above let you run code linters, secret scans, and vulnerability checks to maintain code quality and security.

### Unit Tests

- **pytest:**
  Install and run pytest to run unit tests and api tests on the code:
  ```bash
  pip install pytest httpx
  pytest test_main.py
  ```

### Linting and Formatting

- **black:**
  Verify code formatting with:
    ```bash
  black --check .
  ```

### Secrets Scanning

- **detect-secrets:**
  Install and run detect-secrets to scan for sensitive information in the code:
    ```bash
  pip install detect-secrets
  detect-secrets scan .
  ```

### Vulnerability Scanning

- **bandit:**
  Use Bandit to check the codebase for common security issues:
    ```bash
  pip install bandit
  bandit -r . --exclude ./venv -lll
  ```
- **pip-audit**  
  A free, open‑source tool from the Python Packaging Authority that scans your installed dependencies for known vulnerabilities.  
  ```bash
  pip install pip-audit
  pip-audit -r requirements.txt
  ```

## Architecture Overview

The application is designed with the following architecture:

- **FastAPI Backend:** Serves the web application and API endpoints
- **Static Assets:** CSS and JavaScript files for the frontend
- **Templates:** Jinja2 templates for server-side rendering
- **External API:** Integration with wttr.in for weather data
- **Containerization:** Docker container for consistent deployment
- **Kubernetes:** Plain manifests for deployment
- **Kind:** Local Kubernetes cluster for development and testing