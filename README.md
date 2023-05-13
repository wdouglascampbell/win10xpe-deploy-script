# win10xpe-deploy-script
A script for reliably deploying the current release of the [Win10XPE](https://github.com/ChrisRfr/Win10XPE) project.

Run **deploy.cmd**.

It will then escalate privileges to provide an Admin shell and execute **win10xpe.ps1**.

**win10xpe.ps1** will do the following:
1. Create a build directory (C:\Win10XPE_Build_Area)
2. Exclude the build directory from Windows Defender scanning
3. Download the current release of Win10XPE
4. Extract the Win10XPE files to C:\Win10XPE_Build_Area\Win10XPE

Once deployed you can begin using [Win10XPE](https://github.com/ChrisRfr/Win10XPE) by using File Explorer to navigate to C:\Win10XPE_Build_Area and double-click **deploy.cmd**.

