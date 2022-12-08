# Flow Automation for Incident Management
The Flow Automation for Incident Management pack aims to deliver automation at each stage of Incident Management from detecting an Incident to the closure of an Incident. This is done by creating an automation layer on top of the Incident Management product(Service Cloud) using Salesforce platform products like Apex, Flows, Orchestrator, LWC, etc.

## AppExchange Listings
* [Flow Automation for Incident Management](https://appexchange.salesforce.com/listingDetail?listingId=a0N4V00000J6AGlUAN)

### Optional Packs
* [Flow Automation for Incident Management with Messaging](https://appexchange.salesforce.com/listingDetail?listingId=a0N4V00000J6AH0UAN)
* [Flow Automation for Incident Management with Slack](https://appexchange.salesforce.com/listingDetail?listingId=a0N4V00000J6AGvUAN)

## Set up
Before development, install the below tools:
* [Salesforce CLI](https://developer.salesforce.com/tools/sfdxcli).
* [CCI](https://cumulusci.readthedocs.io/en/latest/get_started.html#on-macos)
* [Visual Studio Code](https://code.visualstudio.com/)
* [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)

## Developing in your dev scratch org.

* Open your VS code terminal
* Run `cci service list`, make sure github is connected. If it is not, run `cci service connect github`, with your user name and personal access token, you can get your personal access token follow this [section](https://salesforce.quip.com/vscdAl4Q3vIk#XaNACAhT9I5)
* Run `sfdx force:auth:web:login --setdefaultdevhubusername --setalias Lab1449DevHub` to connect to your dev hub(use your Lab1449 devhub username to log in). This will link your Lab1449 devhub. Run `cci service connect devhub Lab1449DevHub` and give `Lab1449DevHub` as an alias to connect with CCI.
* Create a scratch dev org `cci org info dev`
* Set it as default `cci org default dev`
* Push the existing metadata to your dev org `cci flow run dev_org --org dev`
* Open dev org `cci org browser dev`
* Retrieve changes in your org cci task run retrieve_changes --org dev to your local repository.