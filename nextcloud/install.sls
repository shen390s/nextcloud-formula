include:
  - nextcloud.php
  - nextcloud.cron

{% set nextcloud = salt.pillar.get('nextcloud') %}
{% set db_pass = salt.pillar.get('postgresql:roles:{}:password'.format(nextcloud.db_user)) %}

php_ini_adapt_opcache:
  ini.options_present:
    - name: /usr/local/etc/php.ini-production
    - sections:
        PHP:
          memory_limit: 512M
        opcache:
          opcache.enable: 1
          opcache.enable_cli: 1
          opcache.interned_strings_buffer: 8
          opcache.max_accelerated_files: 10000
          opcache.memory_consumption: 128
          opcache.save_comments: 1
          opcache.revalidate_freq: 1
        mail function:
          SMTP: {{ nextcloud.mail_smtphost }}
    - require:
      - sls: nextcloud.php

nextcloud_pkg:
  pkg.installed:
    - name: nextcloud-{{ nextcloud.php_version }}
    - require:
      - sls: nextcloud.php

# Data directories

{% for dir in ('data', 'config', 'apps') %}

nextcloud_{{ dir }}_directory:
  file.directory:
    - name: {{ nextcloud.data | path_join(dir) }}
    - user: www
    - group: www
    {% if dir == 'data' %}
    - mode: 700
    {% else %}
    - mode: 755
    {% endif %}
    - require:
      - pkg: nextcloud_pkg

nextcloud_{{ dir }}_symlink:
  file.symlink:
    - name: {{ nextcloud.root | path_join(dir) }}
    - target: {{ nextcloud.data | path_join(dir) }}
    - force: true
    - require:
      - file: nextcloud_{{ dir }}_directory
    {% if dir == 'data' %}
    # Nextcloud forbid symlinks for the data directory during installation
    - require:
      - cmd: nextcloud_install_db
    {% endif %}

{% endfor %}

nextcloud_data_ocdata:
  file.managed:
    - name: {{ nextcloud.data | path_join('data', '.ocdata') }}
    - user: www
    - group: www
    - mode: 644
    - require:
      - file: nextcloud_data_directory

nextcloud_default_config_file:
  file.copy:
    - name: {{ nextcloud.data | path_join('config', 'config.php') }}
    - source: {{ nextcloud.root | path_join('config', 'config.php') }}
    - user: www
    - group: www
    - mode: 640
    - force: false
    - require_in:
      - file: nextcloud_config_symlink
    - onlyif:
      - test -f {{ nextcloud.root | path_join('config', 'config.php') }} && test ! -f {{ nextcloud.data | path_join('config', 'config.php') }}

# See https://docs.nextcloud.com/server/16/admin_manual/configuration_server/occ_command.html#command-line-installation-label

nextcloud_install_db:
  cmd.run:
    - name: php occ maintenance:install -n --database="{{ nextcloud.db_type }}" --database-name="{{ nextcloud.db_name }}" --database-host="{{ nextcloud.db_host }}" --database-user="{{ nextcloud.db_user }}" --database-pass="{{ db_pass }}" --admin-user="{{ nextcloud.admin_user }}" --admin-pass="{{ nextcloud.admin_password }}"
    - runas: www
    - shell: /bin/sh
    - cwd: {{ nextcloud.root }}
    - unless: test "$(php {{ nextcloud.root | path_join('occ') }} status --no-interaction --no-warnings|awk '/installed:/{print $3}')" = "true"
    - require:
      - file: nextcloud_config_symlink
    - require_in:
      - sls: nextcloud.config
