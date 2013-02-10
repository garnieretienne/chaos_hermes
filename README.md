Hermes - Manage NGiNX Routes
============================

Goal
----

Hermes is a CLI tool aimed to manage nginx routes with informations passed on command line. It will write configuration file and reload nginx after changes.

Installation
------------

* Production: 
  `gem install hermes`

* Development: 
	```
	git clone HERMES_GIT_URL
	cd hermes
	gem build hermes.gemspec
	gem install ./hermes-x.x.x.gem
	```

Usage
-----

```
$> hermes help
Description:
  CLI tool to manage NGINX route.

Usage:
  hermes COMMAND APP [OPTIONS]

Commands:
  help              # Display help. For displayinh specific command help, use hermes help COMMAND
  create            # Create a new route stored in a config file and reload nginx
  update            # Update a route configuration and reload nginx
  destroy           # Destroy a route and reload nginx

Options:
  --vhost-dir PATH  # Directory where vhosts are stored. DEFAULT: /etc/nginx/site-enabled
```

```
$> hermes help create
Description:
  Create a new route stored in a config file and reload nginx.
  DO NOT DO ANYTHING IF CONFIG FILE ALREADY EXIST.

Usage:
  hermes create APP [OPTIONS]

Options:
  --vhost-dir PATH              # Directory where vhosts are stored. DEFAULT: /etc/nginx/site-enabled
  --redirect DOMAIN[,DOMAIN]    # Add a redirection directive for these domains
  --alias DOMAIN[,DOMAIN]       # Add domain aliases
  --upstream ADDRESS[,ADDRESS]  # Add backend server to proxy to

Example:
  hermes create comit comit.io --redirect www.comit.io --alias app.comit.io --vhost-dir /var/http/routes --upstream 192.168.1.12:8080,192.168.1.12:8081

```

```
$> hermes help update
Description:
  Update a route configuration and reload nginx. 
  All route parameters must be present, parameters stored in the old config file will not be used.
  DO NOT DO ANYTHING IF CONFIG FILE DOES NOT EXIST.

Usage:
  hermes update APP [OPTIONS]

Options:
  --vhost-dir PATH              # Directory where vhosts are stored. DEFAULT: /etc/nginx/site-enabled
  --redirect DOMAIN[,DOMAIN]    # Add a redirection directive for these domains
  --alias DOMAIN[,DOMAIN]       # Add domain aliases
  --upstream ADDRESS[,ADDRESS]  # Add backend server to proxy to

Example:
  hermes update comit comit.io --redirect www.comit.io --alias app.comit.io --vhost-dir /var/http/routes --upstream 192.168.1.12:8080,192.168.1.12:8081
```

```
$> hermes help destroy
Description:
  Destroy a route and reload nginx.

Usage:
  hermes destroy APP [OPTIONS]

Options:
--vhost-dir PATH  # Directory where vhosts are stored. DEFAULT: /etc/nginx/site-enabled

Example:
  hermes destroy comit --vhost-dir /var/http/routes
```