==============================
Known issues and limitations
==============================


External IP address of Service not working
===========================================

Restores do at times suffer from external IP addresses not working as expected.
It seems that this is related to updating Cilium while deploying new services.

A restart of the ``Pod`` behind the ``Service`` does trigger an update and help
to workaround the problem in most cases.

See also details about :doc:`core-components/cilium`.


Snapshot restore seems to have a race condition
================================================

The restore path via snapshots seems to suffer from a race condition. In some
cases the snapshot does not contain all restored files.

This is currently worked around by a call to ``sleep`` 20 seconds right before
creating the snapshot.


Truncated image layers behind a caching proxy
==============================================

A container image pull fails with ``unexpected EOF``, or a layer arrives
smaller than the registry reports it to be, on a :term:`Node` that fetches
through a caching proxy in front of a CDN.

The proxy stores a short body after revalidating the entry, and keeps serving
it. See :ref:`sec-caching-proxy-truncation` for the mechanism and the
workaround.
