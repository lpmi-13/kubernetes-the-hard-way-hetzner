for server_name in $(hcloud server list -o noheader --selector 'type=kubernetes' | awk -F ' ' '{print $2}'); do
  hcloud server delete ${server_name}
done

for key in $(hcloud ssh-key list -o noheader | awk -F ' ' '{print $2}'); do
  hcloud ssh-key delete ${key}
done

LOCAL_PRIVATE_SSH_KEY=kubernetes.ed25519
if [ -f "$LOCAL_PRIVATE_SSH_KEY" ]; then
  echo "deleting local private ssh key previously generated"
  rm -rf kubernetes.ed25519
else
  echo "no local private key found"
fi

LOCAL_PUBLIC_SSH_KEY=kubernetes.ed25519.pub
if [ -f "$LOCAL_PUBLIC_SSH_KEY" ]; then
  echo "deleting local public ssh key previously generated"
  rm -rf kubernetes.ed25519.pub
else
  echo "no local public key found"
fi

for load_balancer in $(hcloud load-balancer list -o noheader | awk -F ' ' '{print $2}'); do
  hcloud load-balancer delete ${load_balancer}
done

for firewall in $(hcloud firewall list -o noheader | awk -F ' ' '{print $2}'); do
  hcloud firewall delete ${firewall}
done

for network in $(hcloud network list -o noheader | awk -F ' ' '{print $2}'); do
  hcloud network delete ${network}
done

echo "cleaning up local *.{csr,json,kubeconfig,pem,yaml} files"
rm -rf ./*.{csr,json,kubeconfig,pem,yaml}
