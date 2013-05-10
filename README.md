couchdb-tools
=============

Scripts for managing CouchDB

Usage
=============

Couchdb-tools is json driven. Edit the config.json file and pass it to the command line.

Example:
```json
{
  "configuration": {
  "source_host": "http://source.com",
  "dest_host": "http://destination.com",
  "username": "foo",
  "password": "bar",
  "email_to": "example@example.com",
  "email_from": "couch@example.com",
  "graphite_host": "graphite_host:port"
  },
  "logger": {
   "log_file": "/var/log/couch_replication.log",
   "log_level": "info"
  },
  "scheduler": {
    "status_timer": "",
    "test_timer": ""
}
```
Now execute:
```
couchdb-tools config.json
```
Check the log for updates. 


