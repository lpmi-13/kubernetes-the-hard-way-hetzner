#! /bin/bash

hcloud network create \
  --ip-range 10.240.0.0/16 \
  --name kubernetes \

hcloud network add-subnet kubernetes \
  --ip-range 10.240.0.0/24 \
  --network-zone eu-central \
  --type cloud

hcloud load-balancer create \
  --name kubernetes-lb \
  --type lb11 \
  --network-zone eu-central

hcloud load-balancer attach-to-network \
  --network kubernetes \
  kubernetes-lb

ssh-keygen -t ed25519 -o -a 100 -f kubernetes.ed25519 -N ""

hcloud ssh-key create \
  --public-key-from-file "kubernetes.ed25519.pub" --name kubernetes-ssh

for i in 0 1 2; do
  hcloud server create \
    --name controller-${i} \
    --image ubuntu-18.04 \
    --type cx11 \
    --datacenter nbg1-dc3 \
    --ssh-key kubernetes-ssh \
    --label "type=kubernetes,name=controller-${i}"
done

# since Hetzner only allows 5 VMs for new accounts, we're gonna try with only 2 worker nodes
for i in 0 1; do
  hcloud server create \
    --name worker-${i} \
    --image ubuntu-18.04 \
    --type cx11 \
    --datacenter nbg1-dc3 \
    --ssh-key kubernetes-ssh \
    --label "type=kubernetes,name=worker-${i}"
done

for i in 0 1 2; do
  hcloud load-balancer add-target kubernetes-lb --server controller-${i}
done

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


hcloud firewall create \
  --name kubernetes-firewall-controllers \
  --rules-file config/controller-rules.json

hcloud firewall create \
  --name kubernetes-firewall-workers \
  --rules-file config/worker-rules.json

for i in 0 1 2; do
  hcloud firewall apply-to-resource kubernetes-firewall-controllers --type server --server controller-${i}
done

for i in 0 1; do
  hcloud firewall apply-to-resource kubernetes-firewall-workers --type server --server worker-${i}
done

hcloud load-balancer add-service kubernetes-lb \
  --listen-port 443 \
  --destination-port 6443 \
  --protocol tcp
