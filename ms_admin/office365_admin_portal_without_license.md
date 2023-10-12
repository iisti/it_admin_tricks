#How to become an admin in Office365 without a license

* Source https://techcommunity.microsoft.com/t5/microsoft-teams/need-to-find-who-organization-admin-is/m-p/1002067

### To become an Admin / takeover:
1. First, go to https://powerbi.microsoft.com/en-us and towards the bottom click the Try Free button under Share with Power BI Pro.
1. Sign up using your email address @the domain you wish to take over.
1. Once you sign up for Power BI, sign in at https://portal.office.com using the same credentials.
1. After logging into the portal, click on the app picker square in the upper-left hand corner and select the Admin icon app.
    * If the Admin icon is not displayed right away, click the View all my apps icon and see if it's there. If it still doesn't show up then there's already an admin for the tenant and you need to find out who that is or contact Microsoft Support to find another way to do this. Power BI support was able to confirm that my tenant had no global admins, so we knew this would work.
3. After selecting the Admin icon you should have the Become an Administrator option. 
4. Choose that option to start the process. It will give you the information you need in order to create a specific TXT record in the DNS for this domain. After creating that record and clicking the Verify button in this wizard your account should be elevated to a Global Admin for the tenant.

* Per the email, the Power BI admin takeover instructions are also found here:
    * https://docs.microsoft.com/en-us/microsoft-365/admin/misc/become-the-admin
