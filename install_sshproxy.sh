#!/bin/bash

tee /usr/local/bin/proxy-wrapper <<EOF
#!/bin/bash
nc -x192.168.1.21:1083 -X5 \$*
EOF

chmod +x /usr/local/bin/proxy-wrapper

tee ~/.ssh/config <<EOF
Host github github.com mritd.me
#Hostname github.com
#User git
ProxyCommand /usr/local/bin/proxy-wrapper '%h %p'
EOF
