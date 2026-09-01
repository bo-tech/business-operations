A CI job trusts its image's own roots as well as the cache proxy CA. The
runner assembles the two into one bundle at job start, so a destination
reached directly - the site's own GitLab among them - keeps working
alongside proxied traffic.
