# Business Operations Project


## Status - In preparation

The current implementation is working and in use. The generic parts have been
split out into this repository and the documentation has been extracted. The
documentation still needs rework to fully reflect the generic approach of
business-operations rather than the original site-specific setup.

- Documentation: <https://business-operations.codeberg.page/business-operations/>
- Source code: <https://codeberg.org/business-operations/business-operations>
- Planning: <https://codeberg.org/business-operations/planning>


## About

Enabling small organizations to re-gain control over their data and
infrastructure is the main objective of the proposed project, so that they can
run their software and data based on their conditions.

Both Families and tiny businesses are considered a "Small Organization" in the
context of this project, and they have surprisingly similar needs in terms of
the underpinning infrastructure to run applications to their own conditions:
Both need backup and restore, a virtual overlay network and isolation from each
other.

This project shall turn the existing solution into a real open source project
by adding and finishing core features for the main use case and lowering the
entry bar to re-use and contribute to the existing solution of a self-sufficient
distributed platform to run applications.

Current key technologies are NixOS and Kubernetes paired up with a high degree
of automation. They have been combined so that both bootstrap from scratch and
restore from backup are only two command calls away.


## Progress

- The generic parts have been split out:
  - `nixos` contains configuration for the machines
  - `ansible` contains automation for bootstrapping
  - `kubernetes` contains the various applications
- Documentation extracted from the original site-specific setup.
- My deployment based on this still works.


## Next steps

- Rework the extracted documentation to be fully generic rather than
  reflecting the original site-specific setup.
- Make it easy to try out the current state and deploy it into a bare-metal or
  virtual machine. Ideally also allow usage in a local dev cluster like minikube
  or similar.


## Contact

Reach me via [`@jbornhold:matrix.org`](https://matrix.to/#/@jbornhold:matrix.org)
or [`@johbo@mastodon.social`](https://mastodon.social/@johbo).


## License

MIT, see the `LICENSES/MIT.txt` file. The repository follows
[REUSE](https://reuse.software/), so `reuse lint` states the licensing of
every file.
