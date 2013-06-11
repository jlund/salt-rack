include:
  - ruby-falcon

# Install the libcurl OpenSSL development files that Passenger requires
libcurl4-openssl-dev:
  pkg.installed

# Install Passenger
passenger:
  cmd.run:
    - name: {{ pillar['ruby_location'] }}/bin/gem install passenger -v {{ pillar['passenger_version'] }}
    - unless: {{ pillar['ruby_location'] }}/bin/gem list | grep -e passenger -e {{ pillar['passenger_version'] }}
    - require:
      - cmd: bundler
      - pkg: libcurl4-openssl-dev

# Make Passenger Symlinks
# --
{% for binary in 'passenger-memory-stats', 'passenger-status' %}
/usr/local/bin/{{ binary }}:
  file.symlink:
    - target: {{ pillar['ruby_location'] }}/bin/{{ binary }}
    - require:
      - cmd: passenger
{% endfor %}

# Download the Nginx source code
nginx-source:
  file.managed:
    - name: /usr/local/src/nginx-1.4.1.tar.gz
    - source: http://nginx.org/download/nginx-1.4.1.tar.gz
    - source_hash: sha256=bca5d1e89751ba29406185e1736c390412603a7e6b604f5b4575281f6565d119

# Run the Nginx install script
nginx-install:
  cmd.script:
    - name: salt://nginx-passenger/install.sh
    - unless: /opt/nginx/sbin/nginx -v 2>&1 | grep 1.4.1
    - template: jinja
    - require:
      - file: nginx-source
      - cmd: passenger
      - file: /usr/local/bin/rake
      - file: /usr/local/bin/ruby

# Generate the Nginx configuration file
nginx-configuration:
  file.managed:
    - name: /opt/nginx/conf/nginx.conf
    - source: salt://nginx-passenger/nginx-conf
    - template: jinja
    - require:
      - cmd: nginx-install

# Copy Nginx init script
nginx-init-script:
  file.managed:
    - name: /etc/init.d/nginx
    - source: salt://nginx-passenger/nginx-init
    - mode: 755
    - require:
      - cmd: nginx-install

# Enable the Nginx init script so the service will start at boot
# Watch for changes to the configuration and init script, which will
# trigger a restart
nginx:
  service:
    - running
    - enable: True
    - watch:
      - file: nginx-configuration
      - file: nginx-init-script

# Set up Nginx vhost directories
{% for dir in 'sites-available', 'sites-enabled' %}
/etc/nginx/{{ dir }}:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - require:
      - cmd: nginx-install
{% endfor %}

# Set up log rotation for Nginx and Passenger
{% for rotate_target in 'nginx', 'passenger' %}
/etc/logrotate.d/{{ rotate_target }}:
  file.managed:
    - source: salt://nginx-passenger/{{ rotate_target }}-logrotate
    - require:
      - cmd: nginx-install
      - cmd: passenger
{% endfor %}
