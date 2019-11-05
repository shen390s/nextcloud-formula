include:
  - nextcloud.install

{% set nextcloud = salt.pillar.get('nextcloud') %}

{% for cfg in nextcloud.config.system %}

nextcloud_config_{{ cfg.key }}:
  cmd.run:
    - name: php occ config:system:set {{ cfg.key }}
        {%- if cfg.type is defined %}
        --type="{{ cfg.type }}"
        --value="{{ cfg.value }}"
        {%- else %}
        --value="{{ cfg.value }}"
        {%- endif %}
    - runas: www
    - cwd: {{ nextcloud.root }}
    - watch:
      - pkg: nextcloud_pkg

{% endfor %}

nextcloud_fix_htaccess_perm:
  file.managed:
    - name: {{ nextcloud.root | path_join('.htaccess') }}
    - user: www
    - mode: 640
    - watch:
      - pkg: nextcloud_pkg

nextcloud_update_htaccess:
  cmd.run:
    - name: php occ maintenance:update:htaccess
    - runas: www
    - cwd: {{ nextcloud.root }}
    - require:
      - file: nextcloud_fix_htaccess_perm
