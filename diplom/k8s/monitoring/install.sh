#!/bin/bash
# Установка стека мониторинга в кластер
set -e

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install monitoring \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values "$(dirname "$0")/values.yaml" \
  --wait --timeout 15m

kubectl get pods -n monitoring
