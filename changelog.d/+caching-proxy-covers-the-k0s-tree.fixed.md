The caching proxy documentation no longer says that container image
pulls are the whole of what the proxy option covers. The whole `k0s`
process tree inherits the proxy environment, and k0s's own update
prober reaches `updates.k0sproject.io` through it, so a Node that
looks like it only pulls images may not be one.
