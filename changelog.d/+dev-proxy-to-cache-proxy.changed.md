The caching proxy is configured through `business-operations.cache-proxy`
on the `nixosModules.cache-proxy` module rather than through
`dev.proxy` on the platform module, so that a node which does not run
the platform can use the cache and no tier has to set an option named
after an environment it is not.
