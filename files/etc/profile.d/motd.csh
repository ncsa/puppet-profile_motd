# ONLY RUN FOR NORMAL USERS
if ( -x /usr/bin/id ) then
  if ( "`/usr/bin/id -u`" > 1000 ) then
    echo `cat /etc/motd.d/*`
  endif
endif
