# Leequid Infra

## Helm

````shell
helm upgrade --install nginx leequid-infra/charts/app -f leequid-infra/charts/values/dev/nginx.values.yaml -n dev
helm delete nginx -n dev

# --- OR

./scripts/deploy.sh
````

## Addons

- https://external-secrets.io/v0.9.5/introduction/getting-started/
