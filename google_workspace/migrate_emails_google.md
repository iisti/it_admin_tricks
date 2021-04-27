# Migrating emails from Google account to another Google account

* Google Workspace account test.user@domain.com was migrated to another Google Workspace account destination.user@anotherdomain.com
* Source 1: Check emails from other accounts
  * https://support.google.com/mail/answer/21289?co=GENIE.Platform%3DDesktop&hl=en
* Source 2: Read Gmail messages on other email clients using POP
  * https://support.google.com/mail/answer/7104828?hl=en

## Migrating emails
1. On **SOURCE** account test.user@domain.com turn on these settings on the account.
    * Gmail -> Settings -> Forwading and POP/IMAP
        * **Enable POP for all mail**, check that keep copy is selected.
    * Manage your Google Account Security https://myaccount.google.com/security
        * There should be section to enable **Less secure app access**. If one is using 2FA, an App password needs to be created.
          * Enable **Less secure app access**
1. On **DESTINATION** account destination.user@anotherdomain.com
    * **Gmail settings** -> **Accounts** -> **Check mail from other accounts**, Add a mail account
        * Settings:
          ~~~
          Email address: test.user@domain.com
          Username: test.user@domain.com
          Password: xxx
          POP Server: pop.gmail.com
          Port: 995

          Uncheck, Leave a copy of retrieved message on the server. If checked, there's error "pop.gmail.com does not support leaving messages on the server".
          Check, Always use a secure connection (SSL) when retrieving mail.
          Check, Label incoming messages: <whatever one chooses>
          Uncheck, Archive incoming messages (Skip the Inbox)
          ~~~
    * There will be a question if you want to be able to send as *test.user@domain.com*. You can select no, if the account is just being migrated.
1. One can check on DESTINATION account from **Gmail settings** -> **Accounts** -> **Check mail from other accounts** that the added account is showing.
    * The status should be something like:
        * Checking emails...
        * Last checked: 2 minutes ago. No mails fetched. View history Check mail now  
