| [Start](README.md) | [Prerequisites](setup.md) | Create Kubernetes Cluster | [Install JupyterHub](jupyterhub-setup.md) | [Monitoring](monitoring.md) | [Useful Links](links.md) | [Credits](credits.md) |
| ------------------ | ------------------------- | ------------------------- | ----------------------------------------- | --------------------------- | ------------------------ | --------------------- |

## Set up Kubernetes cluster on Nectar using the Container Orchestration System

It's time to create your Kubernetes cluster. We can do this via the command-line, but before we issue the command to create the cluster, we need to determine a few things:

### Which cluster template to use?

To find the cluster template ID to use, we need to list the available cluster templates.

```
openstack coe cluster template list
```

This will give you an output like:

```
+--------------------------------------+--------------------------------------+------+
| uuid                                 | name                                 | tags |
+--------------------------------------+--------------------------------------+------+
| 34539368-9cd4-4978-900f-86065c74d104 | kubernetes-melbourne-v1.17.11        |      |
| c03db765-181a-4faa-b27b-680dff776afa | kubernetes-auckland-v1.17.11         |      |
| 7af8258c-83ab-4753-8b5e-42a9a378ddc7 | kubernetes-swinburne-v1.17.11        |      |
| 08498a89-71f8-4cfa-b0f1-d039b2ed7b36 | kubernetes-melbourne-v1.21.1         |      |
| 360151fc-34d9-46fc-b383-ebecce787060 | kubernetes-melbourne-qh2-uom-v1.21.1 |      |
| 0bb3dc9a-cb0e-45c3-b8db-9f07d4b921aa | kubernetes-monash-01-v1.21.1         |      |
| 9825fae6-509f-4012-bb25-5fb9f55bec8b | kubernetes-monash-02-v1.21.1         |      |
| d0f7dc3e-0ca2-4d17-85c5-5d264cc81333 | kubernetes-intersect-v1.21.1         |      |
| 3b359e20-8256-4769-a9a3-8982b28c0509 | kubernetes-tasmania-v1.21.1          |      |
| 11a3e615-68e5-4e89-b11a-d1974ea89613 | kubernetes-auckland-v1.21.1          |      |
| a732bc27-0fa0-44f8-a5b0-53134074947f | kubernetes-QRIScloud-v1.21.1         |      |
+--------------------------------------+--------------------------------------+------+
```

Based on where your Nectar allocation is, identify the uuid of the template you want to use. For example, if you are on melbourne-qh2 - the template ID to use is: `08498a89-71f8-4cfa-b0f1-d039b2ed7b36`

These instructions have been validated with k8s `v1.21.1`

### Select which keypair to use

When we create a cluster, we also need to identify a keypair to use.
To list your keypairs, do the following:

```
openstack keypair list
```

From the output, note down the name of the keypair you want to use.

### Node flavours

You can choose what server flavor you want to use for the different node types in your Kubernetes cluster. To see a list of available flavors type:

```
openstack flavor list
```

You can select different server flavors for master and worker nodes. From the list of available flavors, select the flavors you want to use for master and worker nodes.
In our example below, we are using a m3.medium flavor, which has 8GB Memory and 4 CPUS.

### Cluster size

When creating the cluster, you can specify how many master and worker nodes you want.
You can later adjust this setting, by either scaling your cluster up or down in size as required. For this example, we are going with 3 master nodes and 10 worker nodes.
If you have a large cluster, or a cluster with lots of traffic, it's beneficial to have multiple master nodes in order for Kubernetes to operate efficiently.

## Creating the cluster

Now we are ready to issue the command to actually create the cluster. Depending on number of nodes etc, the creation of a new cluster varies, but expect at least 10-20 minutes before a cluster is fully created.

```
openstack coe cluster create \
--cluster-template 08498a89-71f8-4cfa-b0f1-d039b2ed7b36 \
--labels admission_control_list="NodeRestriction,NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,TaintNodesByCondition,Priority,DefaultTolerationSeconds,DefaultStorageClass,StorageObjectInUseProtection,PersistentVolumeClaimResize,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,RuntimeClass" \
--merge-labels \
--master-count 3 \
--node-count 10 \
--flavor m3.medium \
--master-flavor m3.medium \
--keypair your-keypair-name \
mycluster
```

### Check cluster status

To check the status of your cluster(s), issue the following command:

```
openstack coe cluster list
```

Your new cluster should show up in this list, and when ready it will have a status of `CREATE_COMPLETE`.

To follow the build of your cluster you can do the following

```
openstack coe cluster show -f value -c stack_id <coe cluster id>
openstack stack event list --nested-depth 4 --follow <stack id from above>
```

### Connect with cluster from local machine

To connect to your new cluster, you need to get the configuration for your new cluster.

Create a new directory and cd to it;

```
mkdir mycluster
cd mycluster
```

Use the OpenStack CLI tool to generate the config file for kubectl:

```
openstack coe cluster config mycluster
```

Set the `KUBECONFIG` environment variable used by copy-and-pasting the output of the above to the shell prompt, e.g:

```
export KUBECONFIG=/home/user/temp/coe/mycluster/config
```

You should now be able to execute a kubectl call to query your cluster:

```
kubectl get all --all-namespaces
```

The example above, was taken from: https://tutorials.rc.nectar.org.au/kubernetes/03-administer-cluster

### Reboot flannel pods

After creating or resizing the cluster, it's recommended to restart all the flannel/networking pods in the cluster to avoid any networking issues.
Flannel pods can be restarted by issuing the following command:

```
kubectl -n kube-system get po -l app=flannel -l tier=node  -o name | xargs kubectl -n kube-system delete
```

This works around [this bug](https://github.com/flannel-io/flannel/issues/1155) that you may encounter.

### Create storage classes

You will need to create an additional storage class for your JupyterHub installation. Clusters created by Nectar's Container Orchestration service support the cinder storage type, and in the example below we are setting up this storage type for JupyterHub to use.
Storage classes are availability zone specific, so you will need to provide the availability zone you are launching your cluster in (ref https://tutorials.rc.nectar.org.au/kubernetes/09-volume).

There is an example configuration file to set up storage classes using the melbourne-qh2 availability zone here: [k8s/storage-classes.yaml](../k8s/storage-classes.yaml).
Please replace the references to melbourne-qh2 with your chosen availability zone.

To see a list the available availablility zones, issue the following command:

```
openstack availability zone list
```

Once the storage-classes.yaml file has been updated with the correct availability zone, its time to add this to the cluster.

```
kubectl apply -f k8s/storage-classes.yaml
```

At this point it is strongly recommended that you ensure your cluster is all running and healthy.
Once all pods, services, daemonsets, deployments, replicasets and statefulsets are all shown as ready and healthy we are good to continue.
Check these with

```
kubectl get all --all-namespaces
```

Once all the above steps have been completed - congratulations you now have a running Kubernetes cluster!

It's [time to Install JupyterHub](jupyterhub-setup.md)
