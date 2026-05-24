# nixquad

> Why another method to use quadlets in NixOS?

While alternatives like `quadlet-nix` and `quadnix` exist, I wanted the service generation to be taken care of by podman.
Nixquad uses the same logic to generate systemd services from quadlets as podman's systemd service generator.

> Why not just place quadlets in `/etc/containers/` and let podman take care of generating services?

Nix will not recognise the changed service and hence not restart the container when the configuration changes.

