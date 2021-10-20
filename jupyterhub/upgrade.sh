#!/usr/bin/env bash

helm upgrade jupyterhub jupyterhub/jupyterhub --namespace jupyterhub --version=0.11.1 --values config.yaml
