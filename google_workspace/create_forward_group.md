# Creating a forwarder group for a Google Account
* Some times there's a situation for needing to get rid of a Google Account, but the emails should be still be forwarded. One can create a Google Group for forwarding the emails to another email address. By default the emails are saved in the Google Group, but one can turn conversation history off.

1. Create a new Google Group:
    * These settings are designed if the account is external.
      ~~~
      Access settings: Group Owners
      Contact owners: Group Owners
      View members: Group Owners
      View conversations: Group Owners
      Publish posts: External

      Membership settings: Nobody

      Who can join the group: Only invited users
      Allow members outside your organization: on (or off if the email address is in the organization)
      ~~~
1. Add member (tested with testuser@gmail.com)
1. Go to group's Advanced settings and configure
    * Conversation history: OFF
    * Subject prefix: [group-name]
    * Set Auto replies:
        ~~~
        Dear emailer, 

        This is an automatic reply.
        This email address is forwarded to xxx.
        Please use email address xxx from now on.

        Thank you!
        ~~~
