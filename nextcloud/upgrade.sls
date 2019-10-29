include:
  - nextcloud.install

{% set nextcloud = salt.pillar.get('nextcloud') %}

nextcloud_upgrade:
  cmd.run:
    - name: php occ upgrade -n
    - runas: www
    - shell: /bin/sh
    - cwd: {{ nextcloud.root }}
    - unless: test "$(php {{ nextcloud.root | path_join('occ') }} status --no-interaction --no-warnings|awk '/installed:/{print $3}')" = "false"
    - require:
      - pkg: nextcloud_pkg
