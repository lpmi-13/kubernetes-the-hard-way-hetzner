#
#ssh -i kubernetes.ed25519 \
#  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
#  root@$worker_0_public_ip -C "ip route add 10.200.1.0/24 via 10.240.0.7;ip route add 10.200.2.0/24 via 10.240.0.8"
#
#ssh -i kubernetes.ed25519 \
#  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
#  root@$worker_1_public_ip -C "ip route add 10.200.0.0/24 via 10.240.0.6;ip route add 10.200.2.0/24 via 10.240.0.8"
#
#ssh -i kubernetes.ed25519 \
#  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
#  root@$worker_2_public_ip -C "ip route add 10.200.0.0/24 via 10.240.0.6;ip route add 10.200.1.0/24 via 10.240.0.7"
#
#for instance in controller-0 controller-1 controller-2; do
#external_ip=$(vultr-cli instance list | grep ${instance} \
#  | awk -F ' ' '{print $2}')
#
#  ssh -i kubernetes.ed25519 \
#  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
#  root@$external_ip < ./scripts/update_dns.sh
#done
#

# we might still need to manually add routes on the machines, but lets try this first

hcloud network add-route kubernetes \
  --destination 10.200.0.0/24 \
  --gateway 10.240.0.20

hcloud network add-route kubernetes \
  --destination 10.200.1.0/24 \
  --gateway 10.240.0.21

