#!/bin/sh
# Install V2/X2 binary and decompress binary
mkdir /tmp/xray
curl --retry 10 --retry-max-time 60 -L -H "Cache-Control: no-cache" -fsSL github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o /tmp/xray/xray.zip
busybox unzip /tmp/xray/xray.zip -d /tmp/xray
install -m 755 /tmp/xray/xray /usr/local/bin/xray
install -m 755 /tmp/xray/geosite.dat /usr/local/bin/geosite.dat
install -m 755 /tmp/xray/geoip.dat /usr/local/bin/geoip.dat
xray -version
rm -rf /tmp/xray
cat << EOF > /conf/config.json
{
    "log": {
        "loglevel": "none"
    },
    "inbounds": [
        {   
            "listen": "/etc/caddy/vmess,0644",
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "$AUUID"
                    }
                ],
                "disableInsecureEncryption": true
            },
            "streamSettings": {
                "network": "ws",
                "allowInsecure": false,
                "wsSettings": {
                  "path": "/$AUUID-vmess"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        },
        {   
            "listen": "/etc/caddy/vless,0644",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$AUUID",
                        "level": 0,
                        "email": "love@v2fly.org"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "allowInsecure": false,
                "wsSettings": {
                  "path": "/$AUUID-vless"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        },
        {   
            "listen": "127.0.0.1",
            "port": 4324,
            "protocol": "shadowsocks",
            "settings": {
                "email": "love@v2fly.org",
                "method": "chacha20-ietf-poly1305",
                "password":"$AUUID",
                "network": "tcp,udp",
                "ivCheck": true
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "path": "/$AUUID-ss"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        },
        {   
            "listen": "127.0.0.1",
            "port": 5234,
            "protocol": "socks",
            "settings": {
                "auth": "password",
                "accounts": [
                    {
                        "user": "$AUUID",
                        "pass": "$AUUID"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                  "path": "/$AUUID-socks"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        },
        {   
            "listen": "/etc/caddy/trojan,0644",
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password":"$AUUID",
                        "level": 0,
                        "email": "love@v2fly.org"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "allowInsecure": false,
                "wsSettings": {
                  "path": "/$AUUID-trojan"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        }
    ],
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "domainMatcher": "mph",
        "rules": [
           {
              "type": "field",
              "protocol": [
                 "bittorrent"
              ],
              "domains": [
                  "geosite:cn",
                  "geosite:category-ads-all"
              ],
              "outboundTag": "blocked"
           },
           {
              "type": "field",
              "outboundTag":
                  "sockstor",
                  "domains": [
                      "geosite:tor"
                  ]
           },
           {
              "type": "field",
              "outboundTag": "blocked",
              "domains": [
                  "geosite:category-ads-all"
              ]
           }
        ]
    },
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {
                "domainStrategy": "UseIPv4",
                "userLevel": 0
            }
        },
        {
            "protocol": "blackhole",
            "tag": "blocked"
        },
        {
            "protocol": "socks",
            "tag": "sockstor",
            "settings": {
                "servers": [
                    {
                        "address": "127.0.0.1",
                        "port": 9050
                    }
                ]
            }
        }
    ],
    "dns": {
        "servers": [
            {
                "address": "https+local://dns.google/dns-query",
                "address": "https+local://cloudflare-dns.com/dns-query",
                "skipFallback": true
            }
        ],
        "queryStrategy": "UseIPv4",
        "disableCache": true,
        "disableFallbackIfMatch": false
    }
}
EOF

# Make configs
mkdir -p /etc/caddy/ /usr/share/caddy/
unzip  -qo /BlueSimple.zip -d /usr/share/caddy
rm -rf /BlueSimple.zip
cat > /usr/share/caddy/robots.txt << EOF
User-agent: *
Disallow: /
EOF
sed -e "s/\$AUUID/$AUUID/g" /conf/config.json >/usr/local/bin/config.json
sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" /conf/Caddyfile >/etc/caddy/Caddyfile
# Remove temporary directory
rm -rf /conf
# Let's get start
tor & /usr/local/bin/xray -config /usr/local/bin/config.json & /usr/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
