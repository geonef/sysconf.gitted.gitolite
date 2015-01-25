## A Sysconf profile

This is a [SYSCONF](https://github.com/geonef/sysconf.base)
profile. SYSCONF is a method and tool to manage custom system files
for easy install, backup and sync.

This profile provides 2 services: [Gitolite](http://gitolite.com/) and [cgit](http://git.zx2c4.com/cgit/about/).

* *Gitolite* allows you to setup git hosting on a central server, with fine-grained access control and many more powerful features.

* *cgit* is a web interface (cgi) for Git repositories, written in C.



```
# netstat -tlpn
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      - (lighttpd)
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      16291/sshd
tcp6       0      0 :::22                   :::*                    LISTEN      16291/sshd
```


## Gitted import/export

This profile will import a branch ```gitolite-admin``` that it
synchronises with the ```master``` branch of
[the special ```gitolite-admin``` repository of Gitolite](http://gitolite.com/gitolite/concepts.html).


But its dependencies:
* sysconf.gitted [provides import/export](https://github.com/geonef/sysconf.gitted/tree/master/tree/etc/gitted/sync) of the ```sysconf/``` directory


## Gitted integration

* To create a new Gitted repository, follow the instructions at
  [How to setup Gitted for an application](https://github.com/geonef/sysconf.gitted/blob/master/doc/howto-create-new.md)

* Then add this Sysconf profile:
```
git subtree add -P sysconf/sysconf.gitted.gitolite git@github.com:geonef/sysconf.gitted.gitolite.git master
```

* Integrate it in the dependency chain, for example:
```
echo sysconf.gitted.gitolite >sysconf/actual/deps
```

* Then push it to the container:
```
sysconf/gitted-client register
sysconf/gitted-client add <name>   # if needed
git push <name> master
```


## Authors

Written by Jean-Francois Gigand <jf@geonef.fr>. Feel free to contact me!
