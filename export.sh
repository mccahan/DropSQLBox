#!/bin/bash

databases=`/usr/bin/mysql --user=root -proot -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql)"`

for db in $databases; do
  /usr/bin/mysqldump --force --opt --user=root -proot --databases $db > "/vagrant_data/$db.sql"
done

mysql -u root -proot -BNe "select concat('\'',user,'\'@\'',host,'\'') from mysql.user where user != 'root' AND user != 'debian-sys-maint'" | while read uh; do mysql -u root -proot -BNe "show grants for $uh" | sed 's/$/;/; s/\\\\/\\/g'; done > /vagrant_data/zz_grants.sql
echo "FLUSH PRIVILEGES;" >> /vagrant_data/zz_grants.sql
