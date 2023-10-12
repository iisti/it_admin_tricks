# Tricks for Google Sheets
* Split text to columns when pasting
  * https://webapps.stackexchange.com/a/130618
### How to trim domain part from email address
* In Sheet C3 is an email address or it can be empty
  ~~~
  =IF(not(isblank(C2)),RIGHT(C:C, LEN(C:C)-FIND("@",C:C,1)),"")
  ~~~
      
  | Username | Some info | Email | Email domain |
  |----------|-----------|-------|--------------|
  |user|info|user@domain.com|domain.com|
  |user2|info2|||

### How to trim user name part from email address
* In Sheet C3 is an email address or it can be empty
  ~~~
  =IF(not(isblank(C2)),LEFT(C:C, FIND("@",C:C,1)-1),"")
  ~~~
      
  | Username | Some info | Email | Email domain | Email user |
  |----------|-----------|-------|--------------|------------|
  |user|info|user.name@domain.com|domain.com|user.name|
  |user2|info2||||


### How to search for a pattern and pick a result from another cell

  * There are 2 sheets/tabs. On one sheet there is a list of users with information without user's company. On the second sheet there are username and user's company information.
  * The function below returns company name and if not found, doesn't add anything.
    ~~~
    =IFERROR(INDEX('user-company'!$B$1:$B$20,MATCH(A2,'user-company'!$A$1:$A$20,0)))
    ~~~

    * MATCH: Returns the relative position of an item in a range that matches a specified value.
        * https://support.google.com/docs/answer/3093378?hl=en
        * Search for cell A2, from range $A$1:$A$20, 0 means that the pattern must be exact, returns relative cell number from top of the search.
    * INDEX: Returns the content of a cell, specified by row and column offset.
        * https://support.google.com/docs/answer/3098242?hl=en
        * From range $B$1:$B$20 return the cell content from row defined by offset given from the Match function.
    * IFERROR: Prevents that there's no error popping up if the user is not found from the user-company sheet.
        * https://support.google.com/docs/answer/3093304?hl=en

  * Main sheet

  | Username | Some info | Email | Email domain | User Company |
  |----------|-----------|-------|--------------|--------------|
  |user|info|user@domain.com|domain.com|company01|
  |user2|info2|||company02|
  |user4|info3||||
  
  * user-company sheet

  | Username | User Company |
  |----------|--------------|
  |user2|company02|
  |user3|company01|
  |user|company01|

### How to check one cell and highlight another cell with Conditional formatting

* Principle: check one cell's value, highlight another
* Conditional format rules (for example)
  * Apply to range: V2:V700
    * These cells get highlighted
  * Format rules:
    * Custom formula is
    * `=Target_Cell="match text"`
      * e.g. `=L2="yes"`
