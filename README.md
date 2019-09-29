# What is this?
A PowerShell project for copying lots of filesystem content from one place to another.

The main feature is to be able to abort the copy and zipping operations and be able to resume where you left off at a later time.

Also does zipping, unzipping, encryption and decryption of the files being copied.

![Sketch](/_Docs/Sketch.png?raw=true "Sketch")

# Dependencies
- 7zip command line.

Either get it here: https://www.7-zip.org/download.html

Or if you're a chocolatey user:

```choco install 7zip.commandline```

# How to use
1. Download the folder "dist"
2. Setup file paths and settings by editing the Config.xml file

Use Send.bat to Zip, encrypt and copy files

Use Receive.bat to Copy files, decrypt and unzip

# How to develop
1. Make a directory at C:\\_Code and clone the project from there
2. Run PowerShell as administrator
3. Got to the cloned folder and run "_999_TestAll.ps1". When the script has finished running it should present some green text in the console.
4. Code.
5. Repeat step 3.
6. Follow the steps in "How to push to GitHub" below.

# How to push to GitHub
The project needs a large file for running tests and GitHub won't allow uploading large files, so before pushing anything to GitHub follow these steps:
1. Run PowerShell as administrator
2. Got to the cloned folder and run "_1000_Package.ps1". This will clear all of the testdata in the project and place a build in the "dist" folder.
3. Now you can add, commit and push

# TODO (Low)
- Add progress to the Progress files created during each operation
- Support for FTP/SFTP
- Support for OneDrive
- Support for Dropbox
- Support for SharePoint OnPrem
- Support for SharePoint Online
