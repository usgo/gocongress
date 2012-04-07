find . -name '*.rb' | \
egrep -v '_(spec|test).rb$' | \
egrep -v 'migrate' | \
xargs wc -l | sort
