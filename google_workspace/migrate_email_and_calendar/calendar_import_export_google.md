# Export and import calendar in Google Workspace
* This instrcutions shows how to export a calendar from one Google Workspace user to another Google Workspace user.

## On SOURCE user, export calendar
1. Login into https://gmail.com with the source user and open settings.  
    ![Go to Gmail settings](./images/calendar/calendar-001-source-calendar-event-go-to-settings.png)
1. Click Import & Export  
    ![Click Import & Export](./images/calendar/calendar-002-source-export-import-setting.png)
1. Click Export and Save File
    * By default the file should be saved to **Downloads** folder.  
    ![Export file](./images/calendar/calendar-003-source-export-calendar.png)
1. Go to the folder where the file was saved and extract the Zip file.  
    ![Extract the zip](./images/calendar/calendar-004-destination-calendar-exract-zip.png)
    * By default the file is extracted as a new folder besides the original Zip file.  
        ![Choose extraction destination](./images/calendar/calendar-004-destination-calendar-exract-zip-2.png)
    * There should be now your personal calendar (and any other calendars).  
        ![Your calendar](./images/calendar/calendar-004-destination-calendar-exract-zip-3.png)

## On DESTINATION user, import calendar
1. Login into https://gmail.com with the destination user and open settings.  
    ![Go to Gmail settings](./images/calendar/calendar-005-destination-import-calendar-settings.png)
1. Click Import & Export  
    ![Click Import & Export](./images/calendar/calendar-006-destination-settings.png)
1. Click **Select file from your computer** and select your personal calendar  
    ![Select file from your computer](./images/calendar/calendar-007-destination-import-select-file.png)
1. Click Import  
    ![Click Import](./images/calendar/calendar-008-destination-import-click-import.png)
1. There should be notification of imported events  
    ![Imported events notification](./images/calendar/calendar-009-destination-imported-events.png)
1. Events should show up in the destination user's calendar
    ![Events show up](./images/calendar/calendar-010-destination-event-shows-up.png)

## Automatically decline meetings
* Additionally one can create an automatic decliner for the source user for new
  meetings and add a message to invite the destination user instead.  
    ![Automatically decline](./images/calendar/calendar-011-calendar-souce-create-automatic-decline-with-message-informing-about-the-new-email.png)
