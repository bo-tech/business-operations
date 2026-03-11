======
 CRDs
======

The setup has been adjusted so that CRDs can be installed in a first step to
ensure that all application deployments are possible. Especially for CRDs which
are used by nearly all applications this is useful, e.g. the Prometheus stack.

In the directory ``cluster/flux`` is a file ``cluster-crds.yaml`` which starts
the processing of the CRDs. The respective glue objects for Flux are defined in
the directory ``cluster/crds``. They point typically into ``cluster/apps`` so
that the details of the CRD installation are close the the related application
itself.
