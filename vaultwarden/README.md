# Vaultwarden backup

## Create Image For Backups

Vaultwarden image doesn't ship with sqlite3 binary, so an image needs to be created.

1. Build image

    ~~~sh
    docker build -t sqlite3-deb -f Dockerfile.backup .
    ~~~

1. Check version

    ~~~sh
    docker run --rm -it sqlite3-deb sqlite3 --version
        3.40.1 2022-12-28 14:03:47 df5c253c0b3dd24916e4ec7cf77d3db5294cc9fd45ae7b9c5e82ad8197f3alt1
    ~~~

## Set configuration in configuration file

~~~sh
cp config_template.conf config.conf
vim config.conf
~~~

## Create GPG encryption key

Encryption process could be changed like in [GPG Encryption section](../security/gpg_encrypt_decrypt.md)
