# Kubernetes Infrastructure

This repository creates the kubernetes clusters.

### Required
- [terraform](https://www.terraform.io/downloads.html)
- [gcloud](https://cloud.google.com/sdk/install)
- [rust](https://rustup.rs)

### How to generate a new cluster name
`make generate-name`

### How to deploy
```
gcloud auth application-default login
make deploy
```
