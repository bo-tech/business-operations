.. _app-monitoring:

============
 Monitoring
============

Prometheus scrapes the :term:`Cluster` and evaluates alert rules.
Firing alerts go to Alertmanager. Grafana shows the dashboards.


Deployment defaults
===================

:Namespace: ``monitoring``
:Hosts: ``prometheus.<cluster_domain>``,
        ``alertmanager.<cluster_domain>``,
        ``grafana.<cluster_domain>``
:Manifests: ``kubernetes/apps/monitoring/``

All three run on the internal Traefik behind Authelia
(:ref:`sec-internal-access`).

Within that tree, ``kube-prometheus-stack/app/`` holds the Helm values
--- scrape targets, retention, resource limits --- and
``kube-prometheus-stack/addons/alerts/`` the platform's own
``PrometheusRule`` manifests. A rule is worth an evaluation check
(:doc:`/testing`), because an expression that matches nothing never
fires and looks exactly like one that works.


Alerts are not delivered
========================

The platform configures no notification receiver, so nothing is sent
anywhere. An alert waits in Alertmanager until someone opens it, and
``null`` shown as the receiver on every group is that, rather than a
misconfiguration.


Not collected yet
=================

Node metrics and logs. There is no CPU, memory or disk figure for the
machines themselves, and no log view. The node exporter dashboard that
Grafana provisions renders empty for that reason.


Pointers
========

- `kube-prometheus-stack
  <https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack>`_
