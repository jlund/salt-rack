include:
  - deploy-user
  - nginx-passenger
  - ruby-falcon

# Generate the imgur-display virtual host
imgur-display-vhost:
  file.managed:
    - name: /etc/nginx/sites-available/imgur-display
    - source: salt://app/imgur-display/vhost
    - template: jinja
    - require:
      - file: /etc/nginx/sites-available

# Enable the imgur-display virtual host
imgur-display-vhost-symlink:
  file.symlink:
    - name: /etc/nginx/sites-enabled/imgur-display
    - target: /etc/nginx/sites-available/imgur-display
    - require:
      - file: imgur-display-vhost
      - file: /etc/nginx/sites-enabled

# Create the application directories
{% for directory in 'bundle', 'log' %}
{{ pillar['imgur_display_location'] }}/shared/{{ directory }}:
  file.directory:
    - user: deploy
    - group: deploy
    - makedirs: True
    - require:
      - user: deploy
{% endfor %}

# Check out the latest revision of the codebase
imgur-display-codebase:
  git.latest:
    - name: https://github.com/jlund/imgur-display.git
    - target: {{ pillar['imgur_display_location'] }}/current
    - runas: deploy
    - require:
      - pkg: git
      - user: deploy
      - file: {{ pillar['imgur_display_location'] }}/shared/bundle

# Symlink the log directory to the shared location
imgur-display-log-symlink:
  file.symlink:
    - name: {{ pillar['imgur_display_location'] }}/current/log
    - target: {{ pillar['imgur_display_location'] }}/shared/log
    - require:
      - git: imgur-display-codebase
      - file: {{ pillar['imgur_display_location'] }}/shared/log

# Install the bundle
bundle-install:
  cmd.run:
    - name: bundle install --deployment --path {{ pillar['imgur_display_location'] }}
    - user: deploy
    - cwd: {{ pillar['imgur_display_location'] }}/current
    - require:
      - cmd: bundler
      - file: /usr/local/bin/bundle
      - git: imgur-display-codebase
      - user: deploy

# Restart the imgur-display application if the codebase or virtual host change
extend:
  nginx:
    service:
      - watch:
        - git: imgur-display-codebase
        - file: imgur-display-vhost
