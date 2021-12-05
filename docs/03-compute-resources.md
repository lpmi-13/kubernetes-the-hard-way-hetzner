# Provisioning Compute Resources

Before you start this guide, be advised that when your account is new, there's a default limit of 5 VMs, and that won't be enough to complete this tutorial in the normal configuration (ie, 3 controllers and 3 workers).

I've currently got a support ticket open to request an increase to 6 VMs, but for now, I'll try to complete the walkthrough with only 2 worker nodes.

## Networking

### VPC

Hetzer doesn't call these VPC's, but their "network" is essentially the same thing.

(*NOTE:* it's unfortunate that for a lot of these commands, there is no option for output on create, so we need to add some extra steps to grab the IDs of things)

```sh
hcloud network create \
  --ip-range 10.240.0.0/16 \
  --name kubernetes \
```

similar to AWS, you can only put resources in subnets, which is very sensible, so we also need to create one of those.

```sh
hcloud network add-subnet kubernetes \
  --ip-range 10.240.0.0/24 \
  --network-zone eu-central \
  --type cloud
```

### Kubernetes Public Access - Create a Network Load Balancer

First, we create the load balancer, and then we can attach it to the network.

```sh
hcloud load-balancer create \
  --name kubernetes-lb \
  --type lb11 \
  --network-zone eu-central \ # this is the same zone as the Nuremberg data center, which is the same as where we created the network

hcloud load-balancer attach-to-network \
  --network kubernetes \
  kubernetes-lb
```

Let's go ahead and grab the public IP of our load balancer.

```sh
KUBERNETES_PUBLIC_ADDRESS=$(hcloud load-balancer describe \
  kubernetes-lb -o json \
  | jq -r '.public_net.ipv4.ip')
```

## Compute Instances

### SSH Key

```
ssh-keygen -t ed25519 -o -a 100 -f kubernetes.ed25519
```

then import it via the hcloud CLI

```sh
hcloud ssh-key create \
  --public-key-from-file kubernetes.ed25519.pub --name kubernetes-ssh
```

### Kubernetes Controllers

Using `cx11` instances, slightly smaller than the t3.micro instances used in the AWS version, but should get the job done

```sh
for i in 0 1 2; do
  hcloud server create \
    --name controller-${i} \
    --image ubuntu-20.04 \
    --type cx11 \
    --datacenter nbg1-dc3 # this is the Nuremberg data center
    --ssh-key kubernetes-ssh \
    --label "type=kubernetes,name=controller-${i}"
done
```

### Kubernetes Workers

```sh
for i in 0 1; do
  hcloud server create \
    --name worker-${i} \
    --image ubuntu-20.04 \
    --type cx11 \
    --datacenter nbg1-dc3 # this is the Nuremberg data center
    --ssh-key kubernetes-ssh \
    --label "type=kubernetes,name=worker-${i}"
done
```

### Add the Controller nodes to the load balancer

```sh
for i in 0 1 2; do
  hcloud load-balancer add-target kubernetes-lb --server controller-{i}
done
```

### Add all the nodes to the private network

This is an additional step that doesn't get done by default for some reason, but it's easy enough to do.

```sh
for i in 0 1 2; do
  hcloud server attach-to-network \
    --ip 10.240.0.1${i} \
    --network kubernetes \
    controller-${i}
done

for i in 0 1; do
  hcloud server attach-to-network \
    --ip 10.240.0.2${i} \
    --network kubernetes \
    worker-${i}
done
```

### Firewall Rules

We'll create the firewall for the controllers first, since these need to be publicly accessible from the internet.

```sh
hcloud firewall create \
  --name kubernetes-firewall-controllers \
  --rules-file config/controller-rules.json

for i in 0 1 2; do
  hcloud firewall apply-to-resource kubernetes-firewall-controllers --type server --server controller-${i}
done
```

And now we can create the firewall for the workers, to restrict traffic between internal nodes.

```sh
hcloud firewall create \
  --name kubernetes-firewall-workers \
  --rules-file config/worker-rules.json

for i in 0 1; do
  hcloud firewall apply-to-resource kubernetes-firewall-workers --type server --server worker-${i}
done
```

Next: [Certificate Authority](04-certificate-authority.md)
