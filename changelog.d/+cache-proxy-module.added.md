A node can route its container image pulls through a caching proxy
without adopting the whole platform module, by importing
`nixosModules.cache-proxy` and setting `business-operations.cache-proxy`.
