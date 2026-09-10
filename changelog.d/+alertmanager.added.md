Alertmanager runs, reachable on `alertmanager.<cluster domain>` through
the internal Traefik and listed in Hajimari beside Grafana and
Prometheus. Alert rules were evaluated and delivered nowhere before it,
because no Alertmanager existed for Prometheus to send them to. It
carries the chart's default receiver, which notifies nothing, so an
alert is visible rather than delivered.
