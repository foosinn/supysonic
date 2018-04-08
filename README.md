# Supysonic docker container

Just a simple Docker container that gets rebuild on every python update.

Currently only supports local sqlite as storage.

## Attention

* Be sure to add /var/lib/supysonic as a volume to store passwords and your music databse
* You can specify a own password by using a docker secred named `supysonic`
* If you do not specify a secret you will see one in the logs

