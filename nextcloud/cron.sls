include:
  - nextcloud.config

{% set nextcloud = salt.pillar.get('nextcloud') %}
{% set cron_state = 'present' is nextcloud.cron_type == 'cron' else 'absent' %}

# Install or remove crontab
nextcloud_crontab:
  cron.{{ cron_state }}:
    - name: cd / && php -c /usr/local/etc/php.ini-production -f {{ nextcloud.root | path_join('cron.php') }}
    - user: www
    - minute: '*/15'
    - require:
      - sls: nextcloud.config

# Adapt config
nextcloud_config_cron:
  cmd.run:
    - name: php occ background:{{ nextcloud.cron_type }}
    - runas: www
    - cwd: {{ nextcloud.root }}
    - watch:
      - cron: nextcloud_crontab

