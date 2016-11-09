#!/bin/bash

tee /usr/local/bin/proxy-wrapper <<EOF
#!/bin/bash
nc -x127.0.0.1:1080 -X5 $*
EOF

chmod +x /usr/local/bin/proxy-wrapper

tee ~/.ssh/config <<EOF
Host github github.com
Hostname github.com
User git
ProxyCommand /usr/local/bin/proxy-wrapper '%h %p'
EOF
