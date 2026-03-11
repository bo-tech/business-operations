.. _app-cilium:

========
 Cilium
========


Hints
=====


Pod behind IP Address cannot be reached
----------------------------------------

The troubleshooting section in the Cilium documentation advises to use
``cilium-dbg monitor --type drop`` to inspect if there are dropped packages.

``cilium-dbg`` has a lot of useful subcommands to inspect the state.

Restarting the ``Pod`` behind an exposed ``Service`` does trigger an update to
Cilium and can help to make it work again. Also restarting of the Cilium related
``Pods`` seem to trigger a cleanup / update.

Further details are described in the `L2 documentation`_ of Cilium.


Pointers
========

- `L2 documentation`_


.. _L2 documentation: https://docs.cilium.io/en/stable/network/l2-announcements/
