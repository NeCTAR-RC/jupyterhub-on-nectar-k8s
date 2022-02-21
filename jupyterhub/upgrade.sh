#!/usr/bin/env bash

helm upgrade jupyterhub jupyterhub/jupyterhub \
  --namespace jupyterhub \
  --version=1.2.0 \
  --values config.yaml
