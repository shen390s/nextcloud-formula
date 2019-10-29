# Recommended PHP modules
# See https://docs.nextcloud.com/server/16/admin_manual/installation/source_installation.html#prerequisites-for-manual-installation

{% set nextcloud = salt.pillar.get('nextcloud') %}

{% set required_modules = ('ctype', 'curl', 'dom', 'gd', 'iconv', 'json', 'xml', 'mbstring', 'openssl', 'posix', 'session', 'simplexml', 'xmlreader', 'xmlwriter', 'zip', 'zlib') %}

{% set recommended_modules = ('fileinfo', 'bz2', 'intl') %}

{% set db_module = {
    'pgsql' : 'pdo_pgsql',
    'mysql' : 'pdo_mysql',
    'sqlite': 'pdo_sqlite'
  }
%}

# Install PHP
{{ nextcloud.php_version }}_pkg:
  pkg.installed:
    - name: {{ nextcloud.php_version }}

{{ nextcloud.php_version}}_php_ini:
  file.symlink:
    - name: /usr/local/etc/php.ini
    - target: /usr/local/etc/php.ini-production
    - require:
      - pkg: {{ nextcloud.php_version }}_pkg

# Install required PHP modules
{% for module in required_modules %}
php_{{ module }}_module:
  pkg.installed:
    - name: {{ nextcloud.php_version }}-{{ module }}
    - require:
      - pkg: {{ nextcloud.php_version }}_pkg
{% endfor %}

# Install recommended PHP modules
{% for module in recommended_modules %}
php_{{ module }}_module:
  pkg.installed:
    - name: {{ nextcloud.php_version }}-{{ module }}
    - require:
      - pkg: {{ nextcloud.php_version }}_pkg
{% endfor %}

# Install database module
php_{{ db_module[nextcloud.db_type] }}_module:
  pkg.installed:
    - name: {{ nextcloud.php_version }}-{{ db_module[nextcloud.db_type] }}
    - require:
      - pkg: {{ nextcloud.php_version }}_pkg


