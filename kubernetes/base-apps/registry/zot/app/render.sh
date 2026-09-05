#!/usr/bin/env bash
# Renders the upstream zot chart into rendered.yaml, which is committed.
set -euo pipefail

cd "$(dirname "$0")"

CHART_VERSION="0.1.122"
CHART="oci://ghcr.io/project-zot/helm-charts/zot"

helm template zot "$CHART" \
    --version "$CHART_VERSION" \
    --namespace registry \
    --values values.yaml \
    --set-file 'configFiles.config\.json=config.json' \
    --skip-tests \
    > rendered.yaml

echo "rendered.yaml written from chart $CHART_VERSION"
