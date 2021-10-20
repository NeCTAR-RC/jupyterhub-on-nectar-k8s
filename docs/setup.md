| [Start](README.md) | Prerequisites | [Create Kubernetes Cluster](cluster-setup.md) | [Install Jupyterhub](jupyterhub-setup.md) | [Monitoring](monitoring.md) | [Useful Links](links.md) | [Credits](credits.md) |
| ------------------ | ------------- | --------------------------------------------- | ----------------------------------------- | --------------------------- | ------------------------ | --------------------- |

## Setup prerequisites

### Local tools/dependencies

Please look at: https://tutorials.rc.nectar.org.au/kubernetes/01-overview to see a list of local tools to install. A more detailed guide to the Openstack CLI tools is located here: https://tutorials.rc.nectar.org.au/openstack-cli/01-overview

#### Helm

Setting up helm
helm, the package manager for Kubernetes, is a useful command line tool for: installing, upgrading and managing applications on a Kubernetes cluster. Helm packages are called charts. We will be installing and managing JupyterHub on our Kubernetes cluster using a Helm chart.

Charts are abstractions describing how to install packages onto a Kubernetes cluster. When a chart is deployed, it works as a templating engine to populate multiple yaml files for package dependencies with the required variables, and then runs kubectl apply to apply the configuration to the resource and install the package.

While several methods to install Helm exist, the simplest way to install Helm is to run Helm’s installer script in a terminal:

```
curl https://raw.githubusercontent.com/helm/helm/HEAD/scripts/get-helm-3 | bash
```

### Nectar allocation prerequisites

- 1 x Cluster
- 1 x Network
- 1 x Router
- 2 x Floating IP
- 3 x Loadbalancer
- 3 x m3.small Compute

You also need to create a keypair for your allocation. See this guide for more details: https://tutorials.rc.nectar.org.au/keypairs/01-overview

Once you have all prerequisites ready, its time to proceed to [creating a new Kubernetes cluster](cluster-setup.md)
