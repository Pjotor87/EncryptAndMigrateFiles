# Status
Works for files and files directly under one folder. Recursive archiving is in progress.

# What is this?
A PowerShell project for copying lots of filesystem content from one place to another.

The main feature is to be able to abort the copy and zipping operations and be able to resume where you left off at a later time.

Also does zipping, unzipping, encryption and decryption of the files being copied.

![Sketch](/_Docs/Sketch.png?raw=true "Sketch")

# Dependencies
PowerShell version 5 or higher
Uses the PowerShell module "7zip4PowerShell" to do unzip operations (PowerShell will prompt for installation of this module when running)
7zip command line

# How to use
1. Clone the project
2. Go to the "dist" folder
3. Setup file paths and settings by editing the Config.xml file

Use Send.bat to Zip, encrypt and copy files

Use Receive.bat to Copy files, decrypt and unzip

# How to run tests
1. Make a directory at C:\\_Code and clone the project from there
2. Run PowerShell as administrator
3. Got to the cloned folder and run "_999_TestAll.ps1"

# How to package for GitHub
The project needs a large file for running tests and GitHub won't allow uploading large files, so before pushing anything to GitHub follow these steps:
1. Run PowerShell as administrator
2. Got to the cloned folder and run "_1000_Package.ps1"
3. Now you can add, commit and push

# TODO (Medium)
- Remove Try/Catch for when BitsTransfer module fails to import and replace with a test for PowerShell version
- Add switches in Config.xml file to select which processes to run or skip
- Remove dependency to 7zip4Powershell

# TODO (Low)
- Add progress to the Progress files created during each operation
- Support for FTP/SFTP
- Support for OneDrive
- Support for Dropbox
- Support for SharePoint OnPrem
- Support for SharePoint Online
