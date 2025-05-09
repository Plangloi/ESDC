#ESDC_Setup_Mixer_V1.ps1
#===================================================================

# This script automates the installation of Voicemeeter Banana and configuration for a user named "skype".
# It downloads the Voicemeeter setup zip file, extracts it, installs Voicemeeter Banana silently,
# and sets up the necessary configuration files for the user "skype".
# It also ensures that the required folders exist and sets the necessary permissions on the .bat file.
# Requires admin privileges

#===================================================================

# Check if the script is running with admin privileges
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}


#If needed!
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned


#-----------------------------------------------------------------


# Variables File 
$zipURL = "https://download.vb-audio.com/Download_CABLE/VoicemeeterSetup_v2119.zip"
$zipPath = "C:\Users\$env:USERNAME\Downloads\VoicemeeterSetup.zip"
$extractPath = "C:\Users\$env:USERNAME\Downloads\VoicemeeterSetup"
$installerExe = "C:\Users\$env:USERNAME\Downloads\VoicemeeterSetup\voicemeeterprosetup.exe"

$batSource = "C:\Users\$env:USERNAME\Downloads\@ESDC_Boot_V3.bat"
$batDest = "C:\Users\skype\Documents\@ESDC_Boot_V3.bat"
$xmlSchedulerFile = "C:\Users\$env:USERNAME\Downloads\Run_bin_file_scheduler.xml"
$vmDefaultConfig = "C:\Users\$env:USERNAME\Downloads\VoiceMeeterBananaDefault.xml"
$vmDestConfig = "C:\Users\skype\AppData\Roaming\VoiceMeeterBananaDefault.xml"
$vmDestConfig_IpEvo = "C:\Users\Skype\Documents\VoicemeeterBanana_LastSettings_IPEVO.xml"
$vmDestConfig_S40 = "C:\Users\Skype\Documents\VoicemeeterBanana_LastSettings_S40.xml"

# Get file from Gihub
$githubURL = "https://github.com/Plangloi/ESDC/"
$githubFile_ESDC_Boot_V3 = "https://raw.githubusercontent.com/Plangloi/ESDC/refs/heads/main/%40ESDC_Boot_V3.bat"
$githubFile_Run_bin_file_scheduler = "https://raw.githubusercontent.com/Plangloi/ESDC/refs/heads/main/Run_bin_file_scheduler.xml"
$githubFile_VoiceMeeterBananaDefault = "https://raw.githubusercontent.com/Plangloi/ESDC/refs/heads/main/VoiceMeeterBananaDefault.xml"
$githubFile_VoiceMeeterBanana_IpEvo = "https://raw.githubusercontent.com/Plangloi/ESDC/refs/heads/main/VoicemeeterBanana_LastSettings_IPEVO.xml"
$githubFile_VoiceMeeterBanana_S40 = "https://raw.githubusercontent.com/Plangloi/ESDC/refs/heads/main/VoicemeeterBanana_LastSettings_S40.xml"



#-----------------------------------------------------------------

#download the files from GitHub if they don't exist 

#Check if the batch file already exists
if (-Not (Test-Path $batSource)) {
    Write-Host "Downloading @ESDC_Boot_V3.bat from GitHub..."
    Invoke-WebRequest -Uri $githubFile_ESDC_Boot_V3 -OutFile $batSource
} else {
    Write-Host "@ESDC_Boot_V3.bat already exists. Skipping download."
}



# Check if the XML file already exists
if (-Not (Test-Path $xmlSchedulerFile)) {
    Write-Host "Downloading Run_bin_file_scheduler.xml from GitHub..."
    Invoke-WebRequest -Uri $githubFile_Run_bin_file_scheduler -OutFile $xmlSchedulerFile
} else {
    Write-Host "Run_bin_file_scheduler.xml already exists. Skipping download."
}



# Check if the VoicemeeterBanana_IpEvo.xml file already exists
if (-Not (Test-Path $vmDestConfig)) {
    Write-Host "Downloading VoiceMeeterBanana_IpEvo.xml from GitHub..."
    Invoke-WebRequest -Uri $githubFile_VoiceMeeterBanana_IpEvo -OutFile $vmDestConfig_IpEvo
} else {
    Write-Host "VoiceMeeterBanana_IpEvo.xml already exists. Skipping download."
}

# Check if the VoicemeeterBanana_S40.xml file already exists
if (-Not (Test-Path $vmDestConfig)) {
    Write-Host "Downloading VoiceMeeterBanana_S40.xml from GitHub..."
    Invoke-WebRequest -Uri $githubFile_VoiceMeeterBanana_S40 -OutFile $vmDestConfig_S40
} else {
    Write-Host "VoiceMeeterBanana_S40.xml already exists. Skipping download."
}


#------------------Move Files-------------------------
# Step Copy configuration files to the user's Documents
Copy-Item -Path $batSource -Destination $batDest -Force

# copy and change rename to "test123".xml file to the user's Documents
Copy-Item -Path $xmlSchedulerFile -Destination "C:\Users\skype\Documents\Run_bin_file_scheduler.xml" -Force
Copy-Item -Path $vmDefaultConfig -Destination "C:\Users\skype\AppData\Roaming\VoiceMeeterBananaDefault.xml" -Force
#-----------------------------------------------------------------

# Step 1: Download Voicemeeter zip if it doesn't exist
# Check if the zip file already exists
if (-Not (Test-Path $zipPath))
    {
        Write-Host "Downloading Voicemeeter zip..."
        Invoke-WebRequest -Uri $zipURL -OutFile $zipPath
    }
else
    {
        Write-Host "Voicemeeter zip already exists. Skipping download."
    }


# Check if the download was successful
if (Test-Path $zipPath)
    {
        Write-Host "Download completed successfully."
    }
    else
    {
        Write-Host "Download failed. Exiting script......"
        Start-Sleep -Seconds 5
        
        Exit
    }

# Step 2: Extract Voicemeeter zip
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force 

# Check if the extraction was successful
if (Test-Path $extractPath)
    {
        Write-Host "Extraction completed successfully."
    }
    else
    {
        Write-Host "Extraction failed. Exiting script."
        # Pause for 5 seconds before exiting
        Start-Sleep -Seconds 5
        
        Exit
        
    }

#-----------------------Install---------------------------------

# Step 3.1: Check if Voicemeeter is already installed
$voicemeeterInstalled = Get-ChildItem "C:\Program Files (x86)\VB\Voicemeeter" -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq "Voicemeeter.exe" }
if ($voicemeeterInstalled) {
    Write-Host "Voicemeeter is already installed."
}
    
    else {
        Write-Host "Voicemeeter is not installed. Proceeding with installation."
        Write-Host "Installing Voicemeeter Banana silently..."
        Start-Process -FilePath $installerExe -ArgumentList "/S" -Wait -NoNewWindow
    }

# Check if the installation was successful
if (Test-Path "C:\Program Files (x86)\VB\Voicemeeter\Voicemeeter.exe")
    {
        Write-Host "Installation completed successfully."
    }
    else
    {
        Write-Host "Installation failed. Exiting script."
        Exit
    }

#-----------------------------------------------------------------

# Step 7:Ask user to reboot
Write-Host "Voicemeeter installation and configuration completed."


# Ask user if they want to reboot now
$reboot = Read-Host "Do you want to reboot now? (Y/N)"
if ($reboot -eq "Y" -or $reboot -eq "y") {
    Restart-Computer -Force
    
} else {
    Write-Host "You chose not to reboot now. Please remember to reboot later."
}
