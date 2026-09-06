A request through the internal Traefik may take up to an hour to
arrive. The 60 second default bounds the whole request including its
body, which cut off a large git push or image upload.
