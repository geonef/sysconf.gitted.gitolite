# Installer script for sysconf "sysconf.gitolite"  -*- shell-script -*-

. /usr/lib/sysconf.base/common.sh

#INSTALL_CGIT_URL=git://hjemli.net/pub/git/cgit
INSTALL_CGIT_URL=git://git.zx2c4.com/cgit
INSTALL_CGIT_REF=v0.10.2

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
    pubfile=/tmp/admin.pub
    # This is a dumb public key -- the private key was long forgotten
    # Anyway, gitolite needs a key to setup, so we provide this, as an example also.
    echo ssh-dss AAAAB3NzaC1kc3MAAACBAPK7tv8lmSe7fO0aJ6YPBWIwewyvBREznIehD8+WJ15DcBwxaqTEeWJ9t3deweEWFWAXeoWVjgQhb1FQFjbKbybbgDEbXmilkPTTCJUtko8szeypQmTHiZUqUsnGNFLgmlvu16oyL8lupcLnjdfZNJcp6TCHlJ7Rsuu/sbU2vkQZAAAAFQDtn6TG7Rhsn8cuYNfoEtWTagIhzQAAAIEAxdSuFRGHq5ad3J4VSc1b0am7hb+FhtuaNeJ60ZAJXhC4lg/VKCeL5M8Gckb7APfZp7grf1dhXwxNDoydpFl3X3B2OJpHcSrV5CnXQVoVlcwr6rDTvQ6pFGX1mvWFU05xzHOcsr5DzVIDwT9kgwwD4/6OKrajmkQ8ORwP83hq3AgAAACBAOyUMuG0z8ks+IS0mGVJRtc9YGiYwqiUmav2NOvzLfxJGf0EfYmoeLd5bqp7TzYLaHrkbICa8OssexuuxppBE0ivgVBrs7wFsSUDLpb6ZAVYAr/mG/fRIpUWtbc7djW0x9Ffrx+uoJDqgrxmgjnrVkQfuAC5rlV7zFO0bVNjIEYS root@ubuntu >$pubfile

    sudo -u git gitolite setup -pk $pubfile
    rm $pubfile
}
gitolite_repositories=/var/lib/git/repositories

sysconf_require_packages lighttpd

if true; then
    # Install cgit
    if [ ! -f /usr/share/cgit/cgit.cgi ]; then
        nef_log "Building cgit from: $INSTALL_CGIT_URL"
        sysconf_require_packages libssl-dev gcc make
        tmp_dir=$(mktemp -d)
        git clone -b $INSTALL_CGIT_REF $INSTALL_CGIT_URL $tmp_dir
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
