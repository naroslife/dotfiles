#alias:new retek1ssh ssh root@192.168.1.100 -t /tmp/SD1/retek2/bin/bash.sh
edit:add-var retek1ssh~ {|@_args|  ssh root@192.168.1.100 -t /tmp/SD1/retek2/bin/bash.sh $@_args }
