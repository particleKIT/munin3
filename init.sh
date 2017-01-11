#!/bin/bash

# configure and start munin node
/usr/local/bin/munin-node-configure --suggest --shell|sh
ln -s /usr/local/share/munin/plugins/munin_update /usr/local/etc/munin/plugins/munin_update
ln -s /usr/local/share/munin/plugins/munin_stats /usr/local/etc/munin/plugins/munin_stats
/usr/local/bin/munin-node

# set munin cron
echo "$MUNIN_CRON    /usr/local/bin/munin-cron" >> cronlist

# configure inventory fetcher
if [ "$HOSTS_URL" != "" ]
then
    echo "*/45 * * * *    /usr/local/bin/fetch_inventory.sh $HOSTS_URL" >> cronlist
    /usr/local/bin/fetch_inventory.sh "$HOSTS_URL"
fi

#start cron
/usr/sbin/crond

# set crontab from cronlist file
/usr/bin/crontab -u munin cronlist
rm cronlist

# configure munin for notifications
echo -e "account default\nfrom $NOTIFICATION_FROM\nhost $NOTIFICATION_RELAY" > /var/lib/munin/.msmtprc
echo -e "contact.$NOTIFICATION_NAME.command mail -s 'Munin notification' $NOTIFICATION_TO" > /usr/local/etc/munin/munin-conf.d/notification

# set munin.conf parameters from envs
sed -i "s/{WORKERS}/$MUNIN_WORKERS/g" /usr/local/etc/munin/munin.conf
sed -i "s/{TIMEOUT}/$MUNIN_TIMEOUT/g" /usr/local/etc/munin/munin.conf

# make munin own the rrds
chown -R munin:munin /var/lib/munin

#run munin-cron for the first time
su - munin -s /bin/bash -c "/usr/local/bin/munin-update --verbose --screen --debug --host localhost"

exec $@
