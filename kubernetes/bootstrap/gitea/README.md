# Gitea

## Generate the manifests

The manifests have been generated with the following command, so that they can
be applied via `kustomize` during bootstrap:

```
helm -n flux-bootstrap template \
  --repo https://dl.gitea.com/charts \
  --skip-tests \
  --values ./helm-values.yaml \
  --version 12.4.0 \
  gitea gitea > gitea.yaml
```
