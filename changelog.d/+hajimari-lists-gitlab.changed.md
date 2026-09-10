Hajimari lists GitLab from its own configuration rather than from the
Ingress the GitLab chart renders. The namespace selector that reached
that Ingress is gone with the platform's last Ingress, so an app the
platform ships is listed the same way as every other one.
