deploy:
  group.present:
    - system: False

  # Add the deploy user
  user.present:
    - fullname: Deploy User
    - home: /home/deploy
    - shell: /bin/bash
    - gid_from_name: True
    # Enable sudo access for the deploy user
    - groups:
      - sudo
    - require:
      - group: deploy

  # Set up authorized_keys for the deploy user
  ssh_auth.present:
    - user: deploy
    - names:
      - ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBC3jdO0ojv6W28wA95qJQexaFNMtVte1xEASeNTAPgyjTqzojZ3cINVXbZS55UD83upMJd5jugohfKp+k/Dus+Y= jlund@Mal
    - require:
      - user: deploy
