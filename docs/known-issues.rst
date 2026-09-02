==============================
Known issues and limitations
==============================


Admission webhook of ingress-nginx
===================================

There seems to be a problem around the FluxCD controller for ``HelmRelease``
resources when it comes to the admission webhook of ``ingress-nginx``.

It seems that an update of ``ingress-nginx`` can lead to a situation where the
FluxCD controller has to be restarted in order for new certificates to be picked
up.

This might also affect other controllers.

The exact cause is not yet clear.

As a workaround a restart of the controller does help.


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
