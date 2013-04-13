Hermes - Manage NGiNX Routes
============================

Introduction
------------

Hermes is a CLI tool aimed to manage nginx routes with informations passed on command line. It will write configuration file and reload nginx after changes.

Installation
------------

* Production: 
  `gem install hermes` # not published yet, name must be changed

* Development: 
  ```
    bundle install
    ruby -Ilib bin/hermes
  ```
  or
	```
	git clone HERMES_GIT_URL
	cd hermes
  bundle install
	gem build hermes.gemspec
	gem install ./hermes-x.x.x.gem
	```

### Allow the user to reload nginx config without asking for password (required by hermes)

### Include route directory in nginx conf

```
echo "$(whoami) ALL=NOPASSWD: /usr/sbin/nginx -s reload -c *" > /tmp/hermes
sudo chmod 0440 /tmp/hermes && sudo chown root:root /tmp/hermes 
sudo mv /tmp/hermes /etc/sudoers.d/hermes
```

Usage
-----

```
$> hermes help
Tasks:
  hermes create APP_NAME DOMAIN -u, --upstream=ADDRESSES  # Create a new route stored in a config file and reload nginx. DO NOT DO ANYTHING IF THE ROUTE CONFIG FILE AL...
  hermes destroy APP_NAME                                 # Delete an existing route config file and reload nginx. 
  hermes help [TASK]                                      # Describe available tasks or one specific task
  hermes list                                             # List all app currently routed. 
  hermes update APP_NAME DOMAIN -u, --upstream=ADDRESSES  # Update a route re-creating a new config file and reloading nginx. DO NOT DO ANYTHING IF THE ROUTE CONFIG FI...

Options:
  -n, [--nginx-conf=NGINX_CONF]  # full path to the main nginx config file
                                 # Default: /etc/nginx/nginx.conf
  -d, [--vhost-dir=VHOST_DIR]    # directory where vhosts are stored
                                 # Default: /var/nginx/routes
```
Licence
=======

Copyright (C) 2013 Etienne Garnier

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.