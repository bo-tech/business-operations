Prometheus and Alertmanager state the address they are reached on, so a
link out of either interface resolves in a browser. Both fell back to
their in-cluster service address, which put an unreachable host on every
alert's source link and on every silence Alertmanager offered.
