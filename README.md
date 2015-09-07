# DropSQLBox

DropSQLBox is a quick-and-dirty implementation of a Vagrant-based MySQL server for local development, with functionality to automatically import and export its local databases to SQL files when started and stopped.

When developing websites locally on my OS X machine, I find myself frequently creating MySQL databases under MAMP Pro for convenience, but this creates issues in portability when I want to move to a new machine or restore backups. To solve this issue, I've created a local MySQL Vagrant server which imports databases from SQL files stored in a Dropbox (or anywhere, I suppose) when started, and exports all databases to SQL files again when it is shut down. The use of Dropbox as a storage platform also allows simple version control for databases that aren't worth implementing migrations on, but for which a version history restore might come in handy.

## Initial Setup

* Download a copy of the repository and navigate there
* Execute a `vagrant up` (you must already have [Vagrant](https://www.vagrantup.com/) installed)
* Once the command completes, you may connect to the server with the following MySQL details:

**MySQL Server**: 127.0.0.1  
**MySQL Port**: 33060  
**MySQL User**: root  
**MySQL Password**: root  

## Storage

DropSQLBox assumes that your files are stored in `~/Dropbox/Projects/DropSQLBox/` on your OS X machine, just because that's where I keep mine. This setting can be adjusted in the `Vagrantfile` to change the local share to point to another location.

## Saving and Restoring

To restore databases from the `.sql` files stored on Dropbox, you can either perform a `vagrant up` or use `vagrant ssh` to connect to the machine and perform a `sudo mysql start`. An Upstart task installed on the initial device provision in `/etc/init/mysql-up` automatically checks the locally-mapped copy of the Dropbox folder for `*.sql` files and loads them.

Databases are saved to the local shared copy of the Dropbox folder whenever the MySQL server is shut down, either by connecting with `vagrant ssh` and issuing a `sudo service mysql stop` (or `sudo service mysql restart`), or when executing a `vagrant halt`.

N.B.: If you perform a `vagrant destroy` without stopping the MySQL server manually, **all your changes will be lost**. The destroy command does not gracefully shutdown the MySQL server to give it the opportunity to save its data. If you want to save your data, always execute `vagrant halt` before running the destroy command.
