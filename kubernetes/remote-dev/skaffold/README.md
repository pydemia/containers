# Skaffold for Remote Development

## Installation

* standalone: https://skaffold.dev/docs/install/#standalone-binary
* cloud-code: https://cloud.google.com/code

```yaml
apiVersion: skaffold/v2beta28
kind: Config
build:
  artifacts:
  - image: skaffold-example
deploy:
  kubectl:
    manifests:
      - k8s-*
```

