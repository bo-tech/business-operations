Prometheus no longer adds a replica external label. It was named
`__replica__` for a Thanos deployment that has since been retired, and
with a single Prometheus the label carried a constant value onto every
metric and every alert.
