The cluster bootstrap is a Kluctl deployment rather than an ansible
playbook. `ansible-playbook bootstrap-cluster.yaml` becomes two
commands: `kluctl deploy -t <target>`, then
`git-push-into-cluster.yaml` for the push, which still needs a working
tree and a port-forward. `kubernetes/bootstrap` and
`kubernetes/flux/config` are Kluctl libraries now, taking
`git_repo_name` and `cluster_path` as declared arguments, so a
consumer's `flux/config` overlay and its `spec.path` patch go away.
`flux/config` stays readable by both tools during the transition: its
only template is the `spec.path` a consumer already patches.

Because the manifests are templated, `kubectl apply --kustomize` no
longer renders them — the commit that bumps a consumer's pin past this
one is the commit that moves it to the Kluctl bootstrap. A cluster Flux
already manages needs `prune: false` on its `cluster` Kustomization
before `./config` and `./vars` leave `flux/kustomization.yaml`,
otherwise Flux prunes its own entry point and cascades into the apps.
