# The mirror's alerting rules, run against the synthetic series in
# `fixtures/kubernetes/registry-mirror-alerts.test.yaml`.
#
# Deliberately not a "test-" file: flake.nix wraps those in
# runNixOSTest, which needs a disabled sandbox and registry access.
{ pkgs, ... }:
let
  rule = ../kubernetes/apps/monitoring/kube-prometheus-stack/addons/alerts/registry-mirror.yaml;

  ruleTest = ./fixtures/kubernetes/registry-mirror-alerts.test.yaml;
in
pkgs.runCommand "check-registry-mirror-alerts"
  {
    nativeBuildInputs = [
      pkgs.yq-go
      pkgs.prometheus.cli
    ];
  }
  ''
    # promtool reads a bare rules file; the repository keeps a
    # PrometheusRule, whose .spec is that file.
    yq eval '.spec' ${rule} > rules.yaml
    cp ${ruleTest} test.yaml

    promtool check rules rules.yaml
    promtool test rules test.yaml

    touch $out
  ''
