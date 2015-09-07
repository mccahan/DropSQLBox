#!/usr/bin/env bash

shopt -s nullglob
for f in /vagrant_data/*.sql
do
  /usr/bin/mysql -u root -proot < $f
done
