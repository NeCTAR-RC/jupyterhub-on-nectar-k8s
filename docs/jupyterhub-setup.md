| [Start](README.md) | [Prerequisites](setup.md) | [Create Kubernetes Cluster](cluster-setup.md) | Install Jupyterhub | [Monitoring](monitoring.md) | [Useful Links](links.md) | [Credits](credits.md) |
| ------------------ | ------------------------- | --------------------------------------------- | ------------------ | --------------------------- | ------------------------ | --------------------- |

## Install jupyterhub using Helm

Ok, its finally time to actually install Jupyterhub into our cluster!
To do this, we are going to use a helm chart which makes this installation really easy. We are using the method at zero-to-juyterhub https://zero-to-jupyterhub.readthedocs.io/ as a guide for this.

### Customizing Jupyterhub

In this repository, you can find a sample configuration file for your jupyterhub cluster [jupyterhub/config.yaml](../jupyterhub/config.yaml).

**NOTE:** Before using this file, you need to edit the file to replace/update the following values:

### Generate secrets

- Jupyter Proxy secret ( PROXY_SECRET_TOKEN )
- CryptKeeper ( CRYPTKEEPER_SECRET_TOKEN )
- Service Token ( this is only applicable if you want to create a 'service account' in Jupyterhub that can act on users' behalf )

**TIP** - To generate a random token/secret using the command line, use the following command - where 32 is the length of the token in characters

```
openssl rand -base64 32
```

For more detailed information on jupyterhub customization, please see the following guide: https://zero-to-jupyterhub.readthedocs.io/en/latest/jupyterhub/customization.html

#### Authentication

The example in the config file supplied here shows a sample configuration for integrating Jupyterhub with Keycloak. For other authentication methods please refer to this guide: https://zero-to-jupyterhub.readthedocs.io/en/latest/administrator/authentication.html

### Custom Images/User environments

One of the main features of Jupyterhub is the ability to provide users with a preconfigured environment. The sample config file shows how to configure multiple preconfigured images ready for the user to choose.

It's quite easy to extend the base images available from Jupyterhub ( https://github.com/jupyter/docker-stacks ) and create your own custom images. For an example of custom images based on the Jupyterhub stack, please see this example from the EcoCommons platform: https://gitlab.com/ecocommons-australia/ecocommons-platform/analysis-playground-notebooks

For more info, see this: https://zero-to-jupyterhub.readthedocs.io/en/latest/jupyterhub/customizing/user-environment.html

### Customising User Resources

It's easy to customise how much resources a user should have when starting a Jupyterhub server, in the example configuration file we have set the limits per user to:

- Max 3GB Memory
- Max 0.5 CPU

You should configure these limits based on your users requirements, but please note that you are constrained by the size of your 'worker nodes' - so the maximum configuration for a user must be within the available resources on a single node.
As an example, if you have a cluster with worker nodes using the r3.medium flavor, these nodes have 4CPUs and 16GB memory each, which means that you need to set your individual user limits just a bit below those, eg Max 15GB Memory and Max 3.5 CPU - this will ensure that a user's server can actually 'fit' on the node.

More details: https://zero-to-jupyterhub.readthedocs.io/en/latest/jupyterhub/customizing/user-resources.html

### Run the install script

OK, with our config file updated, we are ready to attempt the installation of Jupyterhub.

```
./jupyterhub/install.sh
```

While the installation is running, you should be able to see pods being created by issuing this command in a different terminal:

```
kubectl get pod --namespace jupyterhub
```

Once the helm installation has been created, you should be able to access your Jupyterhub installation!

Find the IP we can use to access the JupyterHub. Run the following command until the EXTERNAL-IP of the proxy-public service is available like in the example output.

```
kubectl get service --namespace jupyterhub

```

To use JupyterHub, enter the external IP for the proxy-public service in to a browser.

Wow, you should now have a working Jupyterhub cluster!

## Updating your Jupyterhub installation

If you want to modify your Jupyterhub installation, you can make your changes to the config.yaml file and issue the following command

```
./jupyterhub/update.sh
```

Next, look into installing a [Monitoring Stack](monitoring.md) for your cluster.
