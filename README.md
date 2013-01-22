Hermes - Manage NGiNX Vhost
===========================

Goal
----

Hermes is a CLI tool aimed to manage nginx vhosts with informations stored on database. It will reload nginx after changes.

Usage:
  hermes COMMAND APP [--vhost-dir PATH]

List of commands
  create    # Create a new vhost for the given application. If the vhost already exist, do nothing.
  destroy   # Destroy the app vhost if exist.
  update    # Destroy and create a new vhost for the given application with updated datas.
