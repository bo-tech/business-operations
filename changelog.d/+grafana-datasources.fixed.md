Grafana's datasources name services the cluster runs. Prometheus was
addressed as `thanos-query`, which no longer exists, so every dashboard
drew from nothing; Loki was configured without ever being deployed and
is gone.
