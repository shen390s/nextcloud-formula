include:
  - nextcloud.install

{% set nextcloud = salt.pillar.get('nextcloud') %}

{% for key, value in nextcloud.config.system.items() %}

nextcloud_config_{{ key }}:
  cmd.run:
    - name: php occ config:system:set {{ key }}
        {%- if value.type is defined %}
        --type="{{ value.type }}"
        --value="{{ value.value }}"
        {%- else %}
        --value="{{ value }}"
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
