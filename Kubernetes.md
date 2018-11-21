# Win 2016  
- Install Hyper-V  
- Install minikube  
    - https://github.com/kubernetes/minikube/releases  
    - Run the exe for windows  
- Install kubectl ``Not needed???``  
    - Find latest version:
        - https://storage.googleapis.com/kubernetes-release/release/stable.txt
    - Powershell  
        - > **NOTE:** No SSL bypass working at this time  
        - `Install-Script -Name install-kubectl -Scope CurrentUser -Force`
        - `install-kubectl.ps1 -downloadlocation $env:USERPROFILE\Downloads`  
    - Not really sure how to install this...didn't really work on the CLI...  
## Installing Chocolatey  
`Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))`  


## Hyper-V  
- Open Hyper-V Manager  
- Select hyper-v(hostname)  
- Select virtual switch manager  
    - Name: "Primary Network"  
        - Leave on External Network  
    - Select Apply  
- Select the auto created virtual network and copy the name
    - Ex. "vmxnet3 Ethernet Adapter - Virtual Switch"  


1. `minikube start --vm-driver hyperv --hyperv-virtual-switch "Primary Virtual Switch"`