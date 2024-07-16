# Personal Tracking Board Application

A Flutter project for saving and tracking tasks in to-do list style, connected to firebase and firestore databases for handling several data managment and users information.

## Pages
The application contains several pages that the user can navigate to:
- Login page
- Sign up page
- User's personal daily tasks page.
- User's progress page.
- User's adding task page.
- Sign out and delete user page.

## Description
User can create new account, new accounts saved in database. After creating account a user can login into the account where he can add new tasks for specific day that the user can choose by day,month and year. New task can contain a description to define the task, tasks are saved in database. For each day user can see the tasks he set himself to do in that specific day, user can choose any day in the future, past and current day to display the tasks he completed and yet to be completed. User can mark tasks as completed and update completed tasks. User can see the progress of the tasks completed in Progress page; the page contains a progress bar which shows the progress of completed tasks of all tasks from the begining of the year till the current day, also contains a chart graph shows the progress of each month by that year, user also have daily progress bar of completed tasks.

## Features
- All users data and information are stored in database.
- User can delete the account and remove all related data from database.
- Application shows messages when internet connection lost or restored.
- Tasks data that is changed while internet is off is updated after the connection is restored, and app continues to work as normal without internet.
- Tasks in the past (past the current date) cant be changed to completed.
- Signing up new user with wrong format information shows the right message for the problem, helping the user to fix the input to create the account.
- Colors used to make it more easy for user to track the problems, such as red message for connection lost, mark the test box with wrong format input with red, and green connection restored message.

## Limitations
- User cant choose a nickname shorter than 3 letters and longer than 8 letters (for the matrix led display limitation).
- User cant delete user when internet is off (message appears for user to indicate the problem).
