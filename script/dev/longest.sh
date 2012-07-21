find . -name '*.rb' | \
egrep -v '_(spec|test).rb$' | \
egrep -v 'migrate' | \
xargs wc -l | sort | tail -n 11 | head -n 10
