# Inspektor Gadget on AKS - Demo/Tutorial
While this tutorial is based on AKS, it can be used on any kind of Kubernetes cluster (self hosted or otherwise)

## What is inspektor gadget?
[Inspektor Gadget](https://www.inspektor-gadget.io/) is an Open Source EBPF based tool to debug Kubernetes resources. It helps in advanced investigation where metrics or app logs are not sufficient.  One of the major advantages is being able to map low level linux resources to high level Kubernetes resources such as pods. 

### inspektor gadget vs `ig`
This topic is explained further [here](https://www.inspektor-gadget.io/docs/v0.27.0/ig/). In this tutorial, we will focus on inspektor gadget. The usage is very similar in `ig`

## Installing inspektor gadget

There are a number of ways to install [here](https://www.inspektor-gadget.io/docs/v0.27.0/getting-started/install-kubernetes/). In this tutorial, we will be using the [latest release](https://www.inspektor-gadget.io/docs/v0.27.0/getting-started/install-kubernetes/#install-a-specific-release)

- Clone the repo to begin with 
- 
We can use Azure CLI to install inskpektor gadget. The instructions are based on the official documentation [here](https://learn.microsoft.com/en-us/azure/linux-workloads/deployigonaks/readme). If you have a cluster, you can skip the the section [here](https://learn.microsoft.com/en-us/azure/linux-workloads/deployigonaks/readme#install-inspektor-gadget). I have included a script in the repo [here](./deployIG.sh)


At the end of the installation, you should see `gadget` pods running on each node of your cluster.



```
kubectl get pods -n gadget
NAME           READY   STATUS    RESTARTS   AGE
gadget-45cxc   1/1     Running   0          19h
gadget-dgtng   1/1     Running   0          21d
gadget-qkntw   1/1     Running   0          22d
gadget-qrhtz   1/1     Running   0          12d
```


##  Testing Inspektor gadgets
We will be going through a few gadgets in this tutorial. The comprehensive list of gadgets are documented [here](https://www.inspektor-gadget.io/docs/latest/builtin-gadgets/)

###  IO Throttling/Saturation

- Apply the `test-pod.yml` , which is present in this repo
  ```
  $ kubectl apply -f test-pod.yml
  pod/io-pod configured
  ```
  This will create a pod named io-pod that continuously performs I/O operations for 60 minutes. You can adjust the parameters in the YAML manifest to customize the I/O workload according to your requirements.

At this point, depending on the node on which the pod is scheduled, you can go the associated VM instance to look at the IO metrics 
- We can use the [top block-io](https://www.inspektor-gadget.io/docs/v0.27.0/builtin-gadgets/top/block-io/) gadget to see which pod is performing how many I/O operations


```bash
$ kubectl gadget top block-io
K8S.NODE         K8S.NAMESPACE    K8S.POD          K8S.CONTAINER    PID     COMM             R/W MAJOR  MINOR  BYTES   TIME(µs) IOs
```

You should see something like the below
```
K8S.NODE                               K8S.NAMESPACE                          K8S.POD                                K8S.CONTAINER                          PID         COMM                R/W MAJOR               MINOR               BYTES               TIME                OPS       
aks-node1       default                                io-pod                                 io-container                           1758184     fio                 W   8                   0                   20713472            299529              5057      
aks-node1      default                                io-pod                                 io-container                           1758184     fio                 R   8                   0                   20258816            579032              4946    
```


- Now, we will use the [profile block-io gadget](https://www.inspektor-gadget.io/docs/v0.28.0/builtin-gadgets/profile/block-io/) to see the distribution of the requests

First, we need to get the node on which the pod is running, the NODE column should have the information

```bash
$ kubectl get pod io-pod -o wide 
```

- We run the profile block-io gadget on that specific node. Once you quit, you can view the I/O latency and the number of operations in each bucket

```
bash
 kubectl gadget profile block-io --node <node-name>

 INFO[0000] Running. Press Ctrl + C to finish
^C        µs               : count    distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 25       |                                        |
        32 -> 63         : 830561   |******************************          |
        64 -> 127        : 1101439  |****************************************|
       128 -> 255        : 206979   |*******                                 |
       256 -> 511        : 14736    |                                        |
       512 -> 1023       : 1354     |                                        |
      1024 -> 2047       : 122      |                                        |
      2048 -> 4095       : 45       |                                        |
      4096 -> 8191       : 27       |                                        |
      8192 -> 16383      : 10       |                                        |
     16384 -> 32767      : 5        |                                        |
     32768 -> 65535      : 2        |                                        |

 ```

Let's now delete the pod created 

```
bash
kubectl delete pod io-pod
```

When you run the profile block-io gadget again, you see a different distribution. We can observe two trends: the number of operations is significantly lower, and the latencies are also reduced.
```
NFO[0000] Running. Press Ctrl + C to finish
^C        µs               : count    distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 11       |*                                       |
        32 -> 63         : 81       |**************                          |
        64 -> 127        : 126      |**********************                  |
       128 -> 255        : 226      |****************************************|
       256 -> 511        : 138      |************************                |
       512 -> 1023       : 4        |                                        |
```       



### OOMKill
Another interesting example of out of memory tracing is available [here](https://www.inspektor-gadget.io/docs/v0.28.0/builtin-gadgets/trace/oomkill/) 


## Uninstalling Inspektor Gadget

```
bash
$ kubectl gadget undeploy
```
