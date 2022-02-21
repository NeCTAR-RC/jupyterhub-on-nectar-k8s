| [Start](README.md) | [Prerequisites](setup.md) | [Create Kubernetes Cluster](cluster-setup.md) | [Install JupyterHub](jupyterhub-setup.md) | Monitoring | [Useful Links](links.md) | [Credits](credits.md) |
| ------------------ | ------------------------- | --------------------------------------------- | ----------------------------------------- | ---------- | ------------------------ | --------------------- |

## Monitoring stack

### Overview

There are many ways to monitor your Kubernetes cluster, and since your JupyterHub is now running on Kubernetes - it makes sense to install monitoring tools for Kubernetes that also allows you to monitor your JupyterHub installation.

One of the most used and recognised tools for monitoring Kubernetes is Prometheus and Grafana - and for a simple way to install the required components in your Kubernetes cluster we can use the kube-prometheus package: https://github.com/prometheus-operator/kube-prometheus

The package includes the following:

- The Prometheus Operator
- Highly available Prometheus
- Highly available Alertmanager
- Prometheus node-exporter
- Prometheus Adapter for Kubernetes Metrics APIs
- kube-state-metrics
- Grafana

This stack is meant for cluster monitoring, so it is pre-configured to collect metrics from all Kubernetes components. In addition to that it delivers a default set of dashboards and alerting rules.

### Installation

#### 1. Clone the kube-prometheus repository

```
git clone https://github.com/prometheus-operator/kube-prometheus.git
cd kube-prometheus
```

#### 2. Install the stack

```
# Create the namespace and CRDs, and then wait for them to be available before creating the remaining resources
kubectl create -f manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl create -f manifests/

```

#### Access the dashboards

Prometheus, Grafana, and Alertmanager dashboards can be accessed quickly using kubectl port-forward after running the installation via the commands below.

Prometheus

```
kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090
```

Then access via http://localhost:9090

Grafana

```
kubectl --namespace monitoring port-forward svc/grafana 3000
```

Then access via http://localhost:3000 and use the default grafana user:password of admin:admin.

Alert Manager

```
kubectl --namespace monitoring port-forward svc/alertmanager-main 9093
```

Then access via http://localhost:9093

Note: There are instructions on how to route to these pods behind an ingress controller in the Exposing Prometheus/Alermanager/Grafana via Ingress section here: https://github.com/prometheus-operator/kube-prometheus#exposing-prometheusalermanagergrafana-via-ingress

#### Remove/Uninstall the monitoring stack

```
kubectl delete --ignore-not-found=true -f manifests/ -f manifests/setup
```
