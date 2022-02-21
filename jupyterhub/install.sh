#!/bin/bash

# below as per docs: https://zero-to-jupyterhub.readthedocs.io/en/latest/jupyterhub/installation.html#initialize-a-helm-chart-configuration-file
helm upgrade --cleanup-on-fail \
  --install jupyterhub jupyterhub/jupyterhub \
  --namespace jupyterhub \
  --create-namespace \
  --version=1.2.0 \
  --values config.yaml
