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

Backup and restore
==================

The secrets of the ``Certificates`` are included into the backup. They are
restored during cluster bootstrap, so that they are not requested on every
bootstrap of the cluster.
