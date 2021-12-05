#! /bin/bash

hcloud network create \
  --ip-range 10.240.0.0/24 \
  --name kubernetes \

hcloud load-balancer create \
  --name kubernetes-lb \
  --type lb11 \
  --network-zone eu-central

KUBERNETES_PUBLIC_ADDRESS=$(hcloud load-balancer describe \
  kubernetes-lb -o json | jq -r '.public_net.ipv4.ip')

echo "KUBERNETES_PUBLIC_ADDRESS is $KUBERNETES_PUBLIC_ADDRESS"

ssh-keygen -t ed25519 -o -a 100 -f kubernetes.ed25519 -N ""

hcloud ssh-key create \
  --public-key-from-file "kubernetes.ed25519.pub" --name kubernetes-ssh

# since Hetzner only allows 5 VMs for new accounts, we're gonna try with only 2 controller nodes
for i in 0 1; do
  hcloud server create \
    --name controller-${i} \
    --image ubuntu-20.04 \
    --type cx11 \
    --datacenter nbg1-dc3 \
    --ssh-key kubernetes-ssh \
    --label "type=kubernetes,name=controller-${i}"
done

for i in 0 1 2; do
  hcloud server create \
    --name worker-${i} \
    --image ubuntu-20.04 \
    --type cx11 \
    --datacenter nbg1-dc3 \
    --ssh-key kubernetes-ssh \
    --label "type=kubernetes,name=worker-${i}"
done

for i in 0 1; do
  hcloud load-balancer add-target kubernetes-lb --server controller-${i}
done

hcloud firewall create \
  --name kubernetes-firewall-controllers \
  --rules-file config/controller-rules.json

hcloud firewall create \
  --name kubernetes-firewall-workers \
  --rules-file config/worker-rules.json

for i in 0 1; do
  hcloud firewall apply-to-resource kubernetes-firewall-controllers --type server --server controller-${i}
done

for i in 0 1 2; do
  hcloud firewall apply-to-resource kubernetes-firewall-workers --type server --server worker-${i}
done
