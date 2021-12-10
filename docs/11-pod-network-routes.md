# Provisioning Pod Network Routes

Pods scheduled to a node receive an IP address from the node's Pod CIDR range. At this point pods can not communicate with other pods running on different nodes due to missing network routes.

In this lab you will create a route for each worker node that maps the node's Pod CIDR range to the node's internal IP address.

Essentially, we want a pod in each worker node to be able to find a pod in another worker node. So in case of a pod on worker-0 communicating with a pod on worker-1, the route is something like the following:

- pod on worker-0 has a CIDR range of 10.200.0.0/24 (from the kubelet config on that node). It needs to know that for contacting a pod in CIDR range 10.200.1.0/24 (a different subnet), it can route through the worker-1 node.

- we want to add a route like the following:

```sh
$ ip route add 10.200.1.0/24 via 10.240.0.1 dev ens10
```
(10.200.1.0/24 is the possible range for a pod on worker-1, and 10.240.0.1 is the gateway that knows where to forward requests for this route to, and the ens10 device is what hetzner uses as the interface for the private subnet)

> There are [other ways](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-achieve-this) to implement the Kubernetes networking model.

# public IP addresses for running commands via ssh

```
worker_0_public_ip=$(hcloud server ip worker-0)
worker_1_public_ip=$(hcloud server ip worker-1)
```

run the following commands for each of the worker nodes:

- worker-0

```sh
ssh -i kubernetes.ed25519 \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  root@$worker_0_public_ip -C "ip route add 10.200.1.0/24 via 10.240.0.1 dev ens10"
```

- worker-1

```sh
ssh -i kubernetes.ed25519 \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  root@$worker_1_public_ip -C "ip route add 10.200.0.0/24 via 10.240.0.1 dev ens10"
```

Next: [Deploying the DNS Cluster Add-on](12-dns-addon.md)
