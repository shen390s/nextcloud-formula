# Notes:
# - Changing data directory after installation is not officially supported.
#   (see https://github.com/nextcloud/documentation/pull/955/files)
# - Nextcloud forbid symlinks for the data directory

nextcloud:
  php_version: php73
  root: /usr/local/www/nextcloud/
  data: /data/nextcloud
  cron_type: cron
  url: https://nextcloud.xxx.org
  domain: nextcloud.xxx.org
  db_type: pgsql
  db_name: nextcloud
  db_host: my.pghost.lan
  db_user: nextcloud
  admin_user: admin
  admin_password: admin
  mail_smtphost: smtp.xxx.org
  mail_domain: xxx.org
  config:
    system:
     - key: redis host
       value: localhost
     - key: redis port
       value: 6379
       type: integer
     - key: overwrite.cli.url
       value: https://nextcloud.xxx.org
     - key: trusted_domains 0
       value: nextcloud.xxx.org
     - key: mail_smtphost
       value: smtp.xxx.org
     - key: mail_domain
       value: xxx.org
     - key: mail_smtpmode
       value: smtp
     - key: datadirectory
       value: /data/nextcloud/data
     - key: apps_paths 0 path
       value: /data/nextcloud/apps
     - key: apps_paths 0 writable 
       value: true
       type: boolean
     - key: apps_paths 0 url
       value: /apps
     - key: apps_paths 1 path
       value: /usr/local/www/nextcloud/apps-pkg
     - key: apps_paths 1 writable
       value: false
       type: boolean
     - key: apps_paths 1 url
       value: /apps-pkg
     - key: memcache.distributed
       value: \OC\Memcache\Redis
     - key: memcache.locking
       value: \OC\Memcache\Redis
     - key: memcache.local
       value: \OC\Memcache\Redis
     - key: filelocking.enabled
       value: true
       type: boolean
