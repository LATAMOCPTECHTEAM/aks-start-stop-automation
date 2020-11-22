# AKS Start/Stop Automation

Azure Automation to start/stop AKS cluster using Azure Automation Powershell Script

## How to Use It

### 1. Create an Azure Automation Account

Create an Azure Automation Account through [Azure Portal](https://ms.portal.azure.com/#create/Microsoft.AutomationAccount).

Make sure that the 'Create Azure Run As account' flag is active

### 2. Give the Automation Account the proper permissions

Once your Automation account is created with the flag 'Create Azure Run As account' a new Service Principal will be created with the same name of your Automation Account plus a unique hash.

You should give ```Contributor``` permissions for this Service Principal in the AKS Clusters that you want to start/stop

### 3. Create your Runbooks

Open your newly created Azure Automation account > Go to the Runbooks Tab and create a new 'Powershell Runbook' called ```AKS Start```. In your Runbook details page, click edit to open the editor and paste the contents of the [StartCluster.ps1](https://github.com/LATAMOCPTECHTEAM/aks-start-stop-automation/blob/master/scripts/StartCluster.ps1) file.

In the line 4, change the parameters and fill the values with your AKS Service Name, AKS Service Resource Group and AKS Service Subscription. You can add multiple lines to Start/Stop multiple clusters.

After that, hit Save and Publish.

Next, create a new Runbook called ```AKS Stop``` and do the same process, but this time using the [StopCluster.ps1](https://github.com/LATAMOCPTECHTEAM/aks-start-stop-automation/blob/master/scripts/StopCluster.ps1) file(Don't forget to change the script with your AKS values), then again, hit Save and Publish.


### 4. Test your Script

The next step is to test if the script is running fine, go first to the ```AKS Stop``` Runbok and hit Start, check if any errors are shown in the logs and if your AKS Cluster is now in the Stopped/Stopping State.

Now, go to the ```AKS Start``` Runbook and hit Start, check if any errors are shown in the logs and if your cluster is now on the Running/Starting state.

### 5. Create your Schedules

If you want to create an schedule to automatically Start/Stop your cluster go to the Schedule tab in your Azure Automation Account and [Create a new Schedules](https://docs.microsoft.com/en-us/azure/automation/shared-resources/schedules), after that go to your Runbooks and Link them to your schedules.
