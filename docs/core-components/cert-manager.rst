==============
 Cert Manager
==============


Overview
========

The current setup uses the DNS system, so that it can also be used for
clusters which are not reachable from the internet.

This needs the following things to be in place:

- ``cert-manager`` configuration so that it does not use the internal
  nameserver.

- DNS zone configuration for the cluster domain. This can be set up in AWS
  Route53 or another DNS provider.

- Issuer configuration which configures ``cert-manager`` so that it can update
  the DNS zone.

Currently the setup is manually done. Automation is still pending.


Access policy on AWS
====================

Example IAM policy for Route53 access:

.. code-block:: json

   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": "route53:GetChange",
               "Resource": "arn:aws:route53:::change/*"
           },
           {
               "Effect": "Allow",
               "Action": [
                   "route53:ChangeResourceRecordSets",
                   "route53:ListResourceRecordSets"
               ],
               "Resource": "arn:aws:route53:::hostedzone/${ZONE_ID}"
           },
           {
               "Effect": "Allow",
               "Action": "route53:ListHostedZonesByName",
               "Resource": "*"
           }
       ]
   }

External domains via CNAME delegation
=====================================

A certificate can be issued for a domain whose DNS is *not* hosted in
the Route53 zone ``cert-manager`` controls, without moving that domain's
DNS. Only the ACME challenge is delegated:

1. In the issuer, add the external domain to the ``dnsZones`` selector of
   a solver that has ``cnameStrategy: Follow`` set. That solver keeps the
   Route53 credentials for the zone you *do* control.

2. At the external domain's DNS provider, create a CNAME that points the
   challenge record into a name under your controlled zone:

   .. code-block:: text

      _acme-challenge.<external-domain>.  CNAME  _acme-challenge.<external-domain>.<controlled-zone>.

3. Create the ``Certificate`` as usual.

With ``cnameStrategy: Follow``, ``cert-manager`` resolves the CNAME and
writes the validation ``TXT`` record into the controlled zone (where it
has Route53 access). No hosted zone is needed for the external domain.

For a wildcard certificate (``*.<external-domain>``) ACME validates at
the apex challenge name ``_acme-challenge.<external-domain>``, so a single
delegation CNAME at that name covers both the apex and the wildcard.

The delegation CNAME lives at the external provider, outside the
cluster's GitOps configuration. If such a certificate fails to issue or
renew, confirm the CNAME still exists.


Backup and restore
==================

The secrets of the ``Certificates`` are included into the backup. They are
restored during cluster bootstrap, so that they are not requested on every
bootstrap of the cluster.
