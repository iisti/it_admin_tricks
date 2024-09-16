# SSH Keys

## How to print encrypted SSH key
* This is required for example pastin unencrypted SSH Key into AWS for retrieving Windows password.
    * The original key is encrypted OPENSSH key which is copied, printed and converted to temporary PEM/RSA key, and then removed.

      ~~~
      key="orig.pem"; cp $key temp.pem && chmod 700 temp.pem && ssh-keygen -p -m pem -f temp.pem && cat temp.pem && rm temp.pem
      ~~~
         * Explanations
         ~~~
         -p      Requests changing the passphrase of a private key file instead of creating a new private key.  The pro‐
                 gram will prompt for the file containing the private key, for the old passphrase, and twice for the new
                 passphrase.
         -m key_format
                Specify a key format for key generation, the -i (import), -e (export) conversion options, and the -p
                change passphrase operation.  The latter may be used to convert between OpenSSH private key and PEM pri‐
                vate key formats.  The supported key formats are: “RFC4716” (RFC 4716/SSH2 public or private key),
                “PKCS8” (PKCS8 public or private key) or “PEM” (PEM public key).  By default OpenSSH will write newly-
                generated private keys in its own format, but when converting public keys for export the default format
                is “RFC4716”.  Setting a format of “PEM” when generating or updating a supported private key type will
                cause the key to be stored in the legacy PEM private key format.
         ~~~
     * Example usage
         1. Enter passphrase to decrypt.
         1. One can just hit enter with empty passphrase for a new passphrase, the file is removed right after printing the content to console.
            ~~~
            key="orig.pem"; cp $key temp.pem && chmod 700 temp.pem && ssh-keygen -p -m pem -f temp.pem && cat temp.pem && rm temp.pem
         
            Enter old passphrase:
            Key has comment ''
            Enter new passphrase (empty for no passphrase):
            Enter same passphrase again:
            Your identification has been saved with the new passphrase.
            -----BEGIN RSA PRIVATE KEY-----
            CENSORED
            -----END RSA PRIVATE KEY-----
            ~~~
