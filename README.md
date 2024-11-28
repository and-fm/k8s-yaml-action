# k8s YAML Action

A simple and extendable action that can take in any number of secrets, basic auth, or plain text env vars, and generate a valid secret or configmap containing your input data.

## Inputs

The following inputs can be used as `step.with` keys:

| Name            | Type   | Default | Required | Description                                                                          |
| --------------- | ------ | ------- | -------- | ------------------------------------------------------------------------------------ |
| `name`          | String |         | `true`   | The name of the resource                                                             |
| `namespace`     | List   |         | `true`   | The k8s namespace the resource will be in                                            |
| `secrets`       | List   |         | `false`  | List of secrets to pass in to generate a secret                                      |
| `basic_auth`    | String |         | `false`  | A username and password to generate a basic auth secret. E.g. `bobby:iLikeTrains123` |
| `configmap_env` | List   |         | `false`  | List of vars to pass in to generate a configmap (same format as secrets)             |

## Outputs

The following outputs can be accessed with steps.\<step-id\>.outputs.out_yaml :

| Name       | Type     | Description            |
| ---------- | -------- | ---------------------- |
| `out_yaml` | K8s Yaml | The resulting k8s yaml |

## Workflows

Branch protection rules require a PR before code can be merged into _main_. There are two PR workflows:

- Dependency review will check upstream base Apline Linux image or Github Actions for updates. If there are High or Critical vulnerabilities found in feature branch, the workflow will fail.
- [Trivy scanner](https://github.com/aquasecurity/trivy) will check the built Docker image for vulnerabilities. If there's a High or Critical CVEs found in the image, the workflow will fail.

A successful merge into _main_ will update the _latest_ release and update the _latest_ tagged container image uploaded to GitHub Packages.

## Contributions

Any help keeping this repo healthy and secure would be appreciated! \
Remaining in the to-do is automating semantic version releases in case users need to rollback to older, stable versions.

## Usage

Here is an example deploy.yaml file to generate a generic secret from some secrets.  
For generating a plain text insecure configmap, just pass your name value pairs into `configmap_env` instead of `secrets`

```yaml
name: Create a secret
on: workflow_dispatch
jobs:
  create_secret:
    name: Create secret
    runs-on: ubuntu-latest
    steps:
      - name: Generate secret via kubectl
        uses: and-fm/k8s-yaml-action@main
        id: gen
        with:
          name: test-secrets
          namespace: test-dev
          secrets: |-
            SECRET_1:${{ secrets.SECRET_1 }}
            SECRET_2:${{ secrets.SECRET_2 }}
          #optional if you need annotations like for reflection
          annotations: |
            sealedsecrets.bitnami.com/cluster-wide: "true"
            reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
            reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "*"
            reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
            reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "*"
      - name: get secrets
        run: |
          echo "${{ steps.gen.outputs.out_yaml }}"
```

Here's an example for generating a basic auth secret:

```yaml
name: Create a basic auth secret
on: workflow_dispatch
jobs:
  create_secret:
    name: Create secret
    runs-on: ubuntu-latest
    steps:
      - name: Generate secret via kubectl
        uses: and-fm/k8s-yaml-action@main
        id: gen
        with:
          name: test-secrets
          namespace: test-dev
          basic_auth: admin:${{ secrets.ADMIN_PASSWORD }}
      - name: get secrets
        run: |
          echo "${{ steps.gen.outputs.out_yaml }}"
```
