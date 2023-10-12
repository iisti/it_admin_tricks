# Send an email notification when Form is submitted
* These instructions will show how to send an email notification when a Form is submitted.
* Create a from and connect it into Sheet.
  * The sheet has these columns which are filled in the Form or actually only Item is filled in the Form. Timestamp and Email Address are filled automatically by the form.
    * Timestamp
    * Email Address
    * Item
* Open the response Sheet -> Tools -> Script Editor
    * In the Editor <>
      ~~~
      function ItemRequestSendMailNotification(e) {
        var gSheet = "https://docs.google.com/spreadsheets/d/xxx";
        var gForm = "https://docs.google.com/forms/d/yyy";
        var gGroup = "item-request-form@mydomain.com";
        // This variable is the index/column which data will retrieved
        var i_count = 0
        // These need to be in the same order as the colums are in Google Sheet
        var timestamp = e.values[i_count++];
        var userEmail = e.values[i_count++];
        var item = e.values[i_count++];
        var subject = "Form: " + userEmail + " has created a request on " + timestamp;
        var message = "Request Form has been filled with information below:"
            + "\n"
            + "\nTimestamp: " + timestamp
            + "\nEmail Address: " + userEmail
            + "\nItem: " + item
            + "\n"
            + "\n"
            + "\nThis message is automatically sent to Google Group: " + gGroup
            + "\nURL to the Google Form: " + gForm
            + "\nThe request form information is automatically written in Google Sheet: " + gSheet
            + "\nThe person who filled the Form is automatically sent a copy of the filled information when the Form is submitted.";

        MailApp.sendEmail(gInvestmentGroup, subject, message);
      }
      ~~~
    *  Select from the left clock sign (Triggers) -> + Add Trigger
        ~~~
        Choose which function to run:       InvestmentRequestSendMailNotification
        Choose which deployemtn should run: Head
        Select event source:                From spreadsheet
        Select event type:                  On form submit
        Failure notification settings:      Notify me immediately
        ~~~
    * If you want to send as a group alias, use this script.
        * Source for sending via alias https://stackoverflow.com/questions/50148904/how-to-use-google-script-send-email-with-group-account
        ~~~
        function ItemRequestSendMailNotification(e) {
          var alias = GmailApp.getAliases();
          var num = alias.length-1;

          if (num<0) { return false }
          else
          {
            for (var i = 0;i <= num;i++) {
              if (alias[i] == "item-request-form@mydomain.com") {
                var gInvestmentGroup=alias[i];
                break;
              }
            }
          }

          var gSheet = "https://docs.google.com/spreadsheets/d/xxx";
          var gForm = "https://docs.google.com/forms/d/yyy";
          // This variable is the index/column which data will retrieved
          var i_count = 0
          // These need to be in the same order as the colums are in Google Sheet
          var timestamp = e.values[i_count++];
          var userEmail = e.values[i_count++];
          var item = e.values[i_count++];
          var subject = "Form: " + userEmail + " has created a request on " + timestamp;
          var message = "Request Form has been filled with information below:"
              + "\n"
              + "\nTimestamp: " + timestamp
              + "\nEmail Address: " + userEmail
              + "\nItem: " + item
              + "\n"
              + "\n"
              + "\nThis message is automatically sent to Google Group: " + gGroup
              + "\nURL to the Google Form: " + gForm
              + "\nThe request form information is automatically written in Google Sheet: " + gSheet
              + "\nThe person who filled the Form is automatically sent a copy of the filled information when the Form is submitted.";

          if (gInvestmentGroup != "item-request-form@mydomain.com") { return false }
          else {
            GmailApp.sendEmail(gInvestmentGroup, subject, message,{from : gInvestmentGroup});
          }
        }
        ~~~
