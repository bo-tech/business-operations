======
 SOPS
======


Age keys generation
====================

A new key is generated in the following way:

.. code-block:: shell

   age-keygen

This will print the secret key to standard output and also include the public
key in the comments.

The public key is used in the ``recipients`` list within the configuration file
``.sops.yaml``.

When storing the key for the cluster, then keep the comments like the timestamp
when it has been generated.


Pointers
========

- SOPS - https://getsops.io/

- Age - https://age-encryption.org/
