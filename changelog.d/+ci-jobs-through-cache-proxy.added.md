GitLab CI jobs fetch through the caching proxy. The runner points every
job at it and at a trust bundle the consuming repository supplies as a
`cache-ca` ConfigMap, carrying the public roots alongside the proxy CA
so that proxied and directly reached destinations both verify. An image
whose tooling trusts none of the certificate variables fails rather than
going direct; `sec-caching-proxy-ci` names what an image must satisfy
and how a job opts out.
