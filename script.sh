    #!/bin/bash
    ### BACKUP THE CURRENT RULESET FIRST
    /sbin/iptables-save > /backup/iptables-last.txt

    ### chan tat ca cac nuoc khac vao website thong qua IPtable ###
    ISO="us af au al dz aq br ar cn lb my ly lr la jp jm jo kz ke hk ml mx fm md mc mn ms ma mz mm nr na np nl an nc nz ni ne ng nu nf mp no om pk pw pa pg py pe ph pn pl pt pr qa re ro ru rw kn lc vc ws sm st sn sa sc sl sg sk si sb so za gs es lk sh pm sd sr sj sz se ch sy tw tj tz th tg tk to tt tn tr tm tc tv ug ua ae gb um uy uz vu ve vg vi wf eh ye yu zm zw ie in il ir hn"

    ### Set PATH ###
    IPT=/sbin/iptables
    WGET=/usr/bin/wget
    EGREP=/bin/egrep

    ### No editing below ###
    SPAMLIST="countrydrop"
    ZONEROOT="/etc/sysconfig/iptables-countrydrop"
    DLROOT="http://www.ipdeny.com/ipblocks/data/countries"

    cleanOldRules(){
    $IPT -F
    $IPT -X
    $IPT -t nat -F
    $IPT -t nat -X
    $IPT -t mangle -F
    $IPT -t mangle -X
    $IPT -P INPUT ACCEPT
    $IPT -P OUTPUT ACCEPT
    $IPT -P FORWARD ACCEPT
    }

    # create a dir
    [ ! -d $ZONEROOT ] && /bin/mkdir -p $ZONEROOT

    # clean old rules
    cleanOldRules

    # create a new iptables list
    $IPT -N $SPAMLIST

    for c  in $ISO
    do
    # local zone file
    tDB=$ZONEROOT/$c.zone

    # get fresh zone file
    $WGET -O $tDB $DLROOT/$c.zone

    # country specific log message
    SPAMDROPMSG="$c Country Drop"

    # get
    BADIPS=$(egrep -v "^#|^$" $tDB)
    for ipblock in $BADIPS
    do
    $IPT -A $SPAMLIST -s $ipblock -j LOG --log-prefix "$SPAMDROPMSG"
    $IPT -A $SPAMLIST -s $ipblock -j DROP
    done
    done

    # Drop everything
    $IPT -I INPUT -j $SPAMLIST
    $IPT -I OUTPUT -j $SPAMLIST
    $IPT -I FORWARD -j $SPAMLIST

    ### ADD IN OTHER IMPORTANT RULESETS
    /sbin/iptables-restore < /etc/sysconfig/iptables-static-rules.conf

    exit 0
