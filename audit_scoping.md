# Audit Scoping

## Scope

- Kubernetes resources:
  - pod (3 containers: geth, prysm-beacon-chain, prysm-validator + intContainer)
  - secret
  - sts (conf: `leequid-infra/kubernetes/lukso-[testnet|mainnet].sts.yaml`)
  - serviceaccount
  - configmap
  - pvc
- Google Cloud Platform: 
  - VPC & Network 
  - IAM
  - Service Account (+ workload identity with GKE)
  - GKE (private cluster)
  - Bucket `leequid-prod-infra` (private)
  - Secret Manager
  - Cloud Nat + Public IP (egress only)
- Docker Image (for InitContainer)
    - `leequid-infra/docker/init-container`
    - `leequid-infra/scripts/lukso-key-geb-cli` (https://github.com/percenuage/tools-key-gen-cli)
    - Github PR: https://github.com/lukso-network/tools-key-gen-cli/pull/30