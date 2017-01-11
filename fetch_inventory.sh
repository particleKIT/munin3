#!/bin/bash
wget -qO /usr/local/etc/munin/munin-conf.d/inventory $1
echo -e "[localhost]\naddress localhost\nuse_node_name yes" >> /usr/local/etc/munin/munin-conf.d/inventory
