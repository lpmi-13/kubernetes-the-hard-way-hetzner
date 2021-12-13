# Prerequisites

## Hetzner Cloud

This tutorial leverages [Hetzner Cloud](https://www.hetzner.com/cloud) to streamline provisioning of the compute infrastructure required to bootstrap a Kubernetes cluster from the ground up. It would cost less then $2 for a 24 hour period that would take to complete this exercise.

> There is no free tier for Hetzner Clud. Make sure that you clean up the resource at the end of the activity to avoid incurring unwanted costs. 

**IMPORTANT**
You may need to pay 20 EUR upfront to be allowed to create the account, which involves a bit more overhead than the providers that feature pay-as-you-go options (eg, vultr, linode, digitalocean), but it's very easy to open a support ticket for a refund at the completion of the walkthrough, so don't worry about needing to spend the entire amount (it will require much less than that).

## Hetzner Cloud CLI

### Install the hcloud CLI

Follow the hcloud CLI [documentation](https://github.com/hetznercloud/cli) to install and configure the `hcloud` command line utility.

The current walkthrough was done with version 1.28.1.

(*NOTE:* at time of writing, there was an issue with the build for 1.29.0, so for ubuntu, I downloaded the [release for 1.28.1](https://github.com/hetznercloud/cli/releases/download/v1.28.1/hcloud-linux-amd64.tar.gz) manually.

Verify the hcloud CLI version using:

```
hcloud version
```

### configure the CLI tool to interact with your account

There isn't much documentation on generating an API token, but you'll need to set up a project first in the [cloud console](https://console.hetzner.cloud/projects). After doing that, you can export it (easier with cli commands) via `HCLOUD_TOKEN=PUT_THE_TOKEN_HERE`.


## Running Commands in Parallel with tmux

[tmux](https://github.com/tmux/tmux/wiki) can be used to run commands on multiple compute instances at the same time. Labs in this tutorial may require running the same commands across multiple compute instances, in those cases consider using tmux and splitting a window into multiple panes with `synchronize-panes` enabled to speed up the provisioning process.

> The use of tmux is optional and not required to complete this tutorial.

![tmux screenshot](images/tmux-screenshot.png)

> Enable `synchronize-panes`: `ctrl+b` then `shift :`. Then type `set synchronize-panes on` at the prompt. To disable synchronization: `set synchronize-panes off`.

Next: [Installing the Client Tools](02-client-tools.md)
