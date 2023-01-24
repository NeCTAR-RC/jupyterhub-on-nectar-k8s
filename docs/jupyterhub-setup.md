| [Start](README.md) | [Prerequisites](setup.md) | [Create Kubernetes Cluster](cluster-setup.md) | Install JupyterHub | [Monitoring](monitoring.md) | [Useful Links](links.md) | [Credits](credits.md) |
| ------------------ | ------------------------- | --------------------------------------------- | ------------------ | --------------------------- | ------------------------ | --------------------- |

## Install JupyterHub using Helm

It's finally time to actually install JupyterHub into our cluster!
To do this, we are going to use a helm chart which makes this installation really easy.
We are using the method provided by the zero-to-juyterhub project https://zero-to-jupyterhub.readthedocs.io/ as a guide for this.

All resources will be created in the `jupyterhub` namespace in our Kubernetes cluster.

### Customizing JupyterHub

In this repository, you can find a sample configuration file for your JupyterHub cluster [jupyterhub/config.yaml](../jupyterhub/config.yaml).

**NOTE:** Before using this file, you need to edit the file to replace/update the following values:
- `proxy.service.loadbalancerIP`
- `proxy.https.hosts`
- `proxy.https.letsencrypt.contactEmail`

In this example we are using letsencrypt-staging, see the [security](https://zero-to-jupyterhub.readthedocs.io/en/latest/administrator/security.html#https) page for other options.
You can comment out the `proxy.https.acmeServer` for production letsencrypt.

Helm charts traditionally use a file called `values.yaml`, the JupyterHub docs use `config.yaml` so that is what we have gone with here.

### Generate secrets

It is not required to change these values as they are automatically generated if not provided.

- Jupyter Proxy secret (PROXY_SECRET_TOKEN)
- CryptKeeper (CRYPTKEEPER_SECRET_TOKEN)
- Service Token (this is only applicable if you want to create a 'service account' in JupyterHub that can act on users' behalf)

**TIP** - To generate a random token/secret using the command line, use the following command - where 32 is the length of the token in characters

```
openssl rand -base64 32
```

For more detailed information on JupyterHub customization, please see the [customization](https://zero-to-jupyterhub.readthedocs.io/en/latest/jupyterhub/customization.html) guide.

#### Authentication

The example in the configuration file supplied here shows a sample configuration for integrating JupyterHub with Keycloak.
For other authentication methods please refer to the [authentication](https://zero-to-jupyterhub.readthedocs.io/en/latest/administrator/authentication.html) guide.

### Custom Images/User environments

One of the advantages of JupyterHub is the ability to provide users with a pre-configured environment.
The sample config file shows how to configure multiple preconfigured images ready for the user to choose.

It's quite easy to extend the base images available from JupyterHub (https://github.com/jupyter/docker-stacks) and create your own custom images.
For an example of custom images based on the JupyterHub stack, please see this example from the EcoCommons platform: https://gitlab.com/ecocommons-australia/ecocommons-platform/analysis-playground-notebooks

For more info, see this: https://zero-to-jupyterhub.readthedocs.io/en/latest/jupyterhub/customizing/user-environment.html

**Note** `/home/jovyan` is the default baked in to the JupyterHub images.

### Customising User Resources

It's easy to customise how many resources a user should have when starting a JupyterHub server, in the example configuration file we have set the limits per user to:

- Max 2GB Memory
- Max 1 CPU

You should configure these limits based on your users requirements, but please note that you are constrained by the size of your 'worker nodes' - so the maximum configuration for a user must be within the available resources on a single node.
As an example, if you have a cluster with worker nodes using the m3.medium flavor, these nodes have 4CPUs and 8GB memory each, which means that you need to set your individual user limits just a bit below those, eg Max 7GB Memory and Max 3.5 CPU - this will ensure that a user's server can actually 'fit' on the node.

More details: https://zero-to-jupyterhub.readthedocs.io/en/latest/jupyterhub/customizing/user-resources.html

### Create external access floating IP and DNS

You will first need to know on which network to create the floating ip. To discover this you can run

```
openstack router list | egrep 'ID|<cluster name>'
openstack router show <router_id_from_above>
```
the network you should use will be the external_gateway_info->network_id from the last command. Using this info we can create our floating ip and dns record
(you will need to have python-designateclient client installed for `openstack recordset create ...`)

```
openstack floating ip create <network_id>
openstack recordset create --record <floating ip> --type A <project>.cloud.edu.au. <name>
```

Update config.yml with the following values
- `proxy.service.loadBalancerIP` - `<Floating IP>`
- `proxy.https.hosts` - `<name>.<project>.cloud.edu.au`

### Run the install script

With our configuration file updated, we are ready to attempt the installation of JupyterHub.

```
./jupyterhub/install.sh
```

The install may fail for a few different reasons (e.g. timeout performing the image pull).
If you do find this happens, simply re-run the install script.

While the installation is running, you should be able to see pods being created by issuing this command in a different terminal:

```
kubectl get pod --namespace jupyterhub
```

Once the helm installation has completed, you may not yet be able to access your JupyterHub installation.

In some circumstances, the autohttps pods attempt to set up the HTTPS certificate request before the JupyterHub service has its external IP address provisioned.
For more details, you can find the open bug report at: https://github.com/jupyterhub/zero-to-jupyterhub-k8s/issues/2150

We can determine if this has occured by looking at the autohttps logs using the command:
```
kubectl --namespace jupyterhub logs -f deployment/autohttps --all-containers=true
```

and looking for messages like the following:
* Unable to obtain ACME certificate
* Timeout during connect (likely firewall problem)

We can resolve the issue by simply deleting the autohttps pods and letting them re-create once the external IP address is available.

Run the following command until the EXTERNAL-IP of the proxy-public service is available like in the example output.

```
kubectl get service --namespace jupyterhub
```

Once the EXTERNAL-IP is available, get the name of the autohttps pods using:

```
kubectl get pod --namespace jupyterhub | grep autohttps
```

and then issue a delete on it:

```
kubectl --namespace jupyterhub delete pod autohttps-xxxxxxxxxx-xxxxx
```

It should re-create itself and you can use the logs command again to follow its progress, and this time you should see messages like:

```
Created secret proxy-public-tls-acme since it does not exist
Updated secret proxy-public-tls-acme with new value for key acme.json
```

You should now be able to connect to your JupyterHub service by entering the DNS name you provisioned.


## Updating your JupyterHub installation

If you want to modify your JupyterHub installation, you can make your changes to the config.yaml file and issue the following command

```
./jupyterhub/update.sh
```

Next, look into installing a [Monitoring Stack](monitoring.md) for your cluster.
