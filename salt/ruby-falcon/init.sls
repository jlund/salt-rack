# Install Ruby dependencies
ruby-dependencies:
  pkg.installed:
    - pkgs:
      - autoconf
      - build-essential
      - libreadline-dev 
      - libssl-dev 
      - libyaml-dev
      - zlib1g-dev 

# Download the Falcon patch
ruby-falcon-patch:
  file.managed:
    - name: /usr/local/src/p385...p385_falcon_gc.diff
    - source: https://github.com/funny-falcon/ruby/compare/p385...p385_falcon_gc.diff
    - source_hash: sha256=480c8ae3d2c6f24c20efec5a5d5855904f80e7c32fa4cef16a3c752d56b24e78

# Download the Ruby source code
ruby-source:
  file.managed:
    - name: /usr/local/src/ruby-1.9.3-p385.tar.gz
    - source: http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p385.tar.gz
    - source_hash: sha256=4b15df007f5935ec9696d427d8d6265b121d944d237a2342d5beeeba9b8309d0

# Run the Ruby install script
ruby:
  cmd.script:
    - name: salt://ruby-falcon/install.sh
    - unless: {{ pillar['ruby_location'] }}/bin/ruby -v | grep p385
    - template: jinja
    - require:
      - pkg: ruby-dependencies
      - file: ruby-falcon-patch
      - file: ruby-source

# Generate the wrapper script that contains GC settings
/usr/local/bin/ruby-falcon-wrapper:
  file.managed:
    - source: salt://ruby-falcon/ruby-falcon-wrapper
    - template: jinja
    - mode: 755
    - require:
      - cmd: ruby

# Install Bundler
bundler:
  cmd.run:
    - name: {{ pillar['ruby_location'] }}/bin/gem install bundler
    - unless: {{ pillar['ruby_location'] }}/bin/gem list | grep bundler
    - require:
      - cmd: ruby

# Make symlinks
{% for binary in 'bundle', 'erb', 'gem', 'irb', 'rake', 'rdoc', 'ri', 'ruby' %}
/usr/local/bin/{{ binary }}:
  file.symlink:
    - target: {{ pillar['ruby_location'] }}/bin/{{ binary }}
    - require:
      - cmd: ruby
{% endfor %}
