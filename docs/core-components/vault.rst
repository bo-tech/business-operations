=======
 Vault
=======

Vault is deployed as cluster internal secret store.

The main purpose is to provide a dynamic secret store.

It is not adding any layer of extra security because the unsealing key is
available as a secret within the cluster itself.


Bootstrap
=========

After installing, a root token and the key have to be generated. This is
possible via Web UI, potentially also via API.

Splitting the key into 1 gives the desired behavior.

According to the docs, this can be done on the CLI::

   kubectl exec vault-0 -- vault operator init \
      -key-shares=1 \
      -key-threshold=1 \
      -format=json > cluster-keys.json

Source: `Vault installation to minikube via Helm with Integrated Storage
<https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-minikube-raft>`_


Configuring
===========

Make sure to login first::

   / $ vault login

Or have the token in ``$VAULT_TOKEN``.


Key value store
---------------

A key value store should be enabled::

   / $ vault secrets enable -path=secret kv-v2
   Success! Enabled the kv-v2 secrets engine at: secret/


Audit device
-------------

::

   / $ vault audit enable file file_path=/vault/audit/vault_audit.log
   Success! Enabled the file audit device at: file/


Policies
--------

Should be written into files and then imported during deployment:
https://developer.hashicorp.com/vault/docs/concepts/policies#managing-policies


Unsealing
=========

Can be done via CLI::

   kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY

The unsealing is implemented in a sidecar container.


Usage examples k8s-at-home
===========================

- https://github.com/BehnH/fleet/tree/main/clusters/hetzner/apps/security/vault
  --- Simple vault setup
