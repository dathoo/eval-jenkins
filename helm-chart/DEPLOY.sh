#!/bin/bash
set -e

namespaces=("dev" "qa" "staging" "prod")
releases=("movie-api-dev" "movie-api-qa" "movie-api-staging" "movie-api-prod")

for i in "${!namespaces[@]}"; do
  ns="${namespaces[$i]}"
  release="${releases[$i]}"
  
  if helm list --namespace "$ns" | grep -q "$release"; then
    helm uninstall "$release" --namespace "$ns"
    #   kubectl delete all --all -n "$ns"
  fi
  
  helm install "$release" . -f environments/"$ns"-values.yaml --namespace "$ns" --create-namespace
done
