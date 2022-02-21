| [Start](README.md) | Prerequisites | [Create Kubernetes Cluster](cluster-setup.md) | [Install JupyterHub](jupyterhub-setup.md) | [Monitoring](monitoring.md) | [Useful Links](links.md) | [Credits](credits.md) |
| ------------------ | ------------- | --------------------------------------------- | ----------------------------------------- | --------------------------- | ------------------------ | --------------------- |

## Setup prerequisites

### Local tools/dependencies

Please look at: https://tutorials.rc.nectar.org.au/kubernetes/ to see a list of local tools to install.
A more detailed guide to the OpenStack CLI tools is located here: https://tutorials.rc.nectar.org.au/openstack-cli/

#### Helm

helm, the package manager for Kubernetes, is a useful command line tool for installing, upgrading and managing applications on a Kubernetes cluster. Helm packages are called charts. We will be installing and managing JupyterHub on our Kubernetes cluster using a Helm chart.

Charts are abstractions describing how to install packages onto a Kubernetes cluster. When a chart is deployed, it works as a templating engine to populate multiple yaml files for package dependencies with the required variables, and then runs kubectl apply to apply the configuration to the resource and install the package.

Helm can be installed through your operating systems package manager or as a binary. See the [helm install docs](https://helm.sh/docs/intro/install/) for details.

### Nectar allocation prerequisites

These figures are sized for the example cluster detailed in this repo which would allow for 4 users per worker node (see cpu/memory limit in the [config.yaml](../jupyterhub/config.yaml) file (8 users are possible with the cpu/memory guarantee although you will need to double the volume storage in that case)

- 1 x Cluster
- 1 x Network
- 1 x Router
- 2 x Floating IP
- 3 x Loadbalancer
- 13 x m3.medium Compute
- 400GB of volume storage

You also need to create a keypair for your allocation. See this guide for more details: https://tutorials.rc.nectar.org.au/keypairs/

Note that these are the requirements for 40 users with up to 2GB of RAM, 1 VCPU each and 10Gi of storage.
Before making your Nectar Research Cloud allocation request, we recommend you read through the documentation on this site and consider the `memory` and `cpu` limits and guarantees in the Helm chart [config.yaml](../jupyterhub/config.yaml) file.
Volume storage should be scoped to the expected maximum number of users × storage capacity as specified in [config.yaml](../jupyterhub/config.yaml).
Also note that if you intend to scale this cluster up you may need to amend your allocation to support your requirements.

Once you have all prerequisites ready, it's time to proceed with [creating a new Kubernetes cluster](cluster-setup.md)
