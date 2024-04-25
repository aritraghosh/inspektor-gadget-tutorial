# Inspektor Gadget on AKS - Demo/Tutorial
While this tutorial is based on AKS, it can be used on any kind of Kubernetes cluster (self hosted or otherwise)

## What is inspektor gadget?
[Inspektor Gadget](https://www.inspektor-gadget.io/) is an Open Source EBPF based tool to debug Kubernetes resources. It helps in advanced investigation where metrics or app logs are not sufficient.  One of the major advantages is being able to map low level linux resources to high level Kubernetes resources such as pods. 

### inspektor gadget vs `ig`
This topic is explained further [here](https://www.inspektor-gadget.io/docs/v0.27.0/ig/). In this tutorial, we will focus on inspektor gadget. The usage is very similar in `ig`

##Installing inspektor gadget

There are a number of ways to install [here](https://www.inspektor-gadget.io/docs/v0.27.0/getting-started/install-kubernetes/). In this tutorial, we will be using the [latest release](https://www.inspektor-gadget.io/docs/v0.27.0/getting-started/install-kubernetes/#install-a-specific-release)

