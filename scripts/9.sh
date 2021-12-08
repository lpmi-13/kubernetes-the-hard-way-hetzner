for instance in worker-0 worker-1; do
  external_ip=$(hcloud server ip ${instance})

  ssh -i kubernetes.ed25519 \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  root@$external_ip < ./scripts/bootstrap_workers.sh
done

echo "waiting 60 seconds before checking worker status"
sleep 60

external_ip=$(hcloud server ip controller-0)

ssh -i kubernetes.ed25519 \
-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
root@$external_ip "kubectl get nodes --kubeconfig admin.kubeconfig"

