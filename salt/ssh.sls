include:
  - deploy-user

# Restart SSH if the configuration changes
ssh:
  service:
    - running
    - enable: True
    - watch:
      - file: ssh-conf

# Reconfigure SSH to only allow access using key-based authentication
ssh-conf:
  file.sed:
    - name: /etc/ssh/sshd_config
    - before: "#PasswordAuthentication yes"
    - after: "PasswordAuthentication no"
    # We only want to make these changes if we can log in as deploy
    - require:
      - ssh_auth: deploy
