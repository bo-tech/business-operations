=========
 Services
=========

Some services provide their own backup and restore mechanisms in
addition to the volume-level backup described in :doc:`volumes`.
These are documented alongside each service.

- :ref:`app-postgresql` --- :term:`CloudNativePG` provides native
  backup via Barman WAL archiving to S3, with point-in-time recovery
  support. Reusable kustomize components handle the configuration.
