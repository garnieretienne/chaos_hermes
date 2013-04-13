Hermes - Manage NGiNX Routes
============================

Description
------------

Hermes is a CLI tool aimed to manage nginx routes with informations passed on command line. It will write configuration files and reload nginx after changes.

Hermes is part of [Chaos Open PaaS](https://github.com/garnieretienne/chaos).

Installation
------------

You must have nginx and sudo installed on the host. Hermes is distributed as a ruby gem, you need a working ruby stack to use it (if you don't have one check [rbenv](https://github.com/sstephenson/rbenv)).

### Install hermes
  
`gem install chaos_hermes`

### Allow an user to reload nginx config without asking for password (required by hermes)

```bash
echo "$(whoami) ALL=NOPASSWD: /usr/sbin/nginx -s reload -c *" > /tmp/hermes
sudo chmod 0440 /tmp/hermes && sudo chown root:root /tmp/hermes 
sudo mv /tmp/hermes /etc/sudoers.d/hermes
```

### Include route directory in nginx conf (default is /var/nginx/routes)

```bash
echo "include /var/nginx/routes/*;" > /tmp/chaos.conf 
sudo mv /tmp/chaos.conf /etc/nginx/conf.d/chaos.conf
```

Usage
-----

```
Tasks:
  hermes create APP_NAME DOMAIN -u, --upstream=ADDRESSES  # Create a new route stored in a config file and reload nginx. Alias for update command. 
  hermes destroy APP_NAME                                 # Delete an existing route config file and reload nginx. 
  hermes help [TASK]                                      # Describe available tasks or one specific task
  hermes list                                             # List all app currently routed. 
  hermes setup                                            # Display hermes requirements
  hermes update APP_NAME DOMAIN -u, --upstream=ADDRESSES  # Update a route re-creating a new config file and reloading nginx. 

Options:
  -n, [--nginx-conf=NGINX_CONF]  # full path to the main nginx config file
                                 # Default: /etc/nginx/nginx.conf
  -d, [--vhost-dir=VHOST_DIR]    # directory where vhosts are stored
                                 # Default: /var/nginx/routes

```

Code documentation: [rubydoc](http://www.rubydoc.info/github/garnieretienne/chaos_hermes/master/frames)

Testing
=======

In order to pass the tests (`rake test`), installation instructions must be completed (nginx installed and sudo configured).

```
git clone git://github.com/garnieretienne/chaos_hermes.git
cd chaos_hermes
bundle install
bundle exec ruby -Ilib bin/hermes #=> run hermes
bundle exec rake test             #=> run tests
```

MIT License
===========

Copyright (C) 2013 Etienne Garnier

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.