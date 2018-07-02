# OpensimBackup - backup script for the Opensim VR software (1.0)
Creates a hot backup of your Opensim installation.

Official support sites: [Official Github Repo](https://github.com/fstltna/OpensimBackup) - [Official Forum](https://opensimcity.org/index.php/forum/server-software)


---

1. Edit the settings at the top of opensimbackup.pl if needed
2. create a cron job like this:

        1 1 * * * /root/OpensimBackup/opensimbackup.pl

3. This will back up your Opensim installation at 1:01am each day, and keep the last 5 backups.

If you need more help visit https://OpensimCity.org/
