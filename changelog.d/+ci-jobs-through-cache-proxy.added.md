GitLab CI jobs fetch through the caching proxy. The runner sets the
proxy and certificate variables for every job it starts, so a
repository inherits the cache without naming it in its CI file. A
consuming repository supplies the proxy URL as `cache_proxy_url` and
the CA as a `cache-ca` ConfigMap in the `gitlab` namespace. An image
whose tooling trusts none of the certificate variables fails rather
than going direct; `sec-caching-proxy-ci` names what an image must
satisfy and how a job opts out.
