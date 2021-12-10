# let the workers know where to route the inter-pod traffic

hcloud network add-route kubernetes \
  --destination 10.200.0.0/24 \
  --gateway 10.240.0.20

hcloud network add-route kubernetes \
  --destination 10.200.1.0/24 \
  --gateway 10.240.0.21

# we also have to let the worker nodes know what gateways to use for the pod CIDRs of the alternate worker node

ssh -i kubernetes.ed25519 \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  root@$(hcloud server ip worker-0) -C "ip route add 10.200.1.0/24 via 10.240.0.1 dev ens10"

ssh -i kubernetes.ed25519 \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  root@$(hcloud server ip worker-1) -C "ip route add 10.200.0.0/24 via 10.240.0.1 dev ens10"

# let the controller nodes know where to forward the inter-pod traffic

for instance in controller-0 controller-1 controller-2; do
external_ip=$(hcloud server ip ${instance})

  ssh -i kubernetes.ed25519 \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  root@$external_ip < ./scripts/update_dns.sh
done

