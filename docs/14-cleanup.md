In this lab you will delete the compute resources created during the tutorial.

## Compute Instances

```sh
for server_name in $(hcloud server list -o noheader --selector 'type=kubernetes' | awk -F ' ' '{print $2}'); do
  hcloud server delete ${server_name}
done
```

## Remote and Local SSH Keys

```sh
for key in $(hcloud ssh-key list -o noheader | awk -F ' ' '{print $2}'); do
  hcloud ssh-key delete ${key}
done
```

Go ahead and delete the local ssh keys we generated as well.

```sh
rm -rf kubernetes.ed25519
rm -rf kubernetes.ed25519.pub
```

## Load Balancer

```sh
for load-balancer in $(hcloud load-balancer list -o noheader | awk -F ' ' '{print $2}'); do
  hcloud load-balancer delete ${load_balancer}
done
```

## Firewall

```sh
for firewall in $(hcloud firewall list -o noheader | awk -F ' ' '{print $2}'); do
  hcloud firewall delete ${firewall}
done
```

## VPC and Private Subnet

Deleting the network also deletes all the subnets and routes, so we can just delete the whole thing.

```sh
for network in $(hcloud network list -o noheader | awk -F ' ' '{print $2}'); do
  hcloud network delete ${network}
done
```

And as one last cleanup, we can just delete all the config for the remote nodes/pods/etc:

```
rm -rf ./*.{csr,json,kubeconfig,pem,yaml}
```
