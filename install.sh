# Installer script for sysconf "sysconf.gitolite"  -*- shell-script -*-

. /usr/lib/sysconf.base/common.sh

INSTALL_CGIT_URL=git://hjemli.net/pub/git/cgit

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
gitolite_repositories=/var/lib/git/repositories

sysconf_require_packages lighttpd

if true; then
    # Install cgit
    if [ ! -f /usr/share/cgit/cgit.cgi ]; then
        nef_log "Building cgit from: $INSTALL_CGIT_URL"
        sysconf_require_packages libssl-dev gcc make
        tmp_dir=$(mktemp -d)
        git clone $INSTALL_CGIT_URL $tmp_dir
        cd $tmp_dir
        make get-git
        make
        mkdir /usr/share/cgit
        cp cgit.css cgit.png /usr/share/cgit
        cp cgit /usr/share/cgit/cgit.cgi
        cd /
        rm -rf $tmp_dir
        apt-get remove --yes libssl-dev gcc make
        apt-get autoremove --yes

        cat <<EOF >/etc/cgitrc.d/generated.cgitrc
root-title=Local Git repositories on $(hostname)
root-desc=managed by Gitted/gitolite in $gitolite_repositories
scan-path=$gitolite_repositories
EOF
        sysconf-etc.d update cgitrc
        rm -f /etc/lighttpd/lighttpd.conf
        ln -s cgit.lighttpd.conf /etc/lighttpd/lighttpd.conf
        service lighttpd restart
    fi
fi
