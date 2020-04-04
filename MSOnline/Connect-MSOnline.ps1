# Ensures MSOnline module is installed
try{
    Install-Module MSOnline
}catch{
    Write-Output "MSOnline is already installed..."
}

Import-Module MSOnline

# Connect to MSOnline Service
Connect-MsolService