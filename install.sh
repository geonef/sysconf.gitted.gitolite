# Installer script for sysconf "sysconf.gitolite"  -*- shell-script -*-

. /usr/lib/sysconf.base/common.sh

if grep -q "^AcceptEnv LANG LC_\*$" /etc/ssh/sshd_config; then
    # Avoid the messages like: "perl: warning: Setting locale failed."
    # This is a minimal system, we just need the "C" locale
    sed -i "s/^AcceptEnv LANG LC_\*$//g" /etc/ssh/sshd_config
    /etc/init.d/ssh restart
fi

# "git" UNIX account
grep -q ^git: /etc/passwd || {

    useradd -d /var/lib/git -m git
    chown git:git /var/lib/git
    dir=$(pwd)
    cd /var/lib/git
    sudo -u git gitolite setup -pk $dir/bootstrap.admin.key.pub
}

sysconf_require_packages lighttpd
