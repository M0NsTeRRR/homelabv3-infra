# Flux

## What is Flux ?

[Flux](https://fluxcd.io/flux/) is a declarative, GitOps continuous delivery tool for Kubernetes.

## Usage

Configuration is stored in `kubernetes` folder.

Configuration is deployed in the cluster from the Git repository.

## Webhook receiver

Once the Flux instance is deployed and the receiver is up and running, extract the webhook path with `kubectl get receiver -n flux-system github-webhook -o jsonpath='{.status.webhookPath}'`. Then, in your GitHub repository settings, create a webhook pointing to `https://flux-webhook.unicornafk.fr/<hook_path>`, with Content type set to `application/json`, the secret you chose, and the "push" event only.
