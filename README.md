# Automated Incident Management (AIM)
The Automated Incident Management(AIM) pack aims to deliver automation at each stage of Incident Management from detecting an Incident to the closure of an Incident. This is done by creating an automation layer on top of the Incident Management product(Service Cloud) using Salesforce platform products like Apex, Flows, Orchestrator, LWC, etc.

## Set up
For complete setup steps, please go through [this doc](https://salesforce.quip.com/2TIJAD8G5yNP).

* Install [Salesforce CLI](https://developer.salesforce.com/tools/sfdxcli).
* Install [CCI](https://cumulusci.readthedocs.io/en/latest/get_started.html#on-macos)
* Add [Salesforce Extension](https://developer.salesforce.com/tools/vscode/) to your Visual Studio Code by going to(In VS Code application) Preference → Extension and searching for `Salesforce Extension Pack`

## Developing in your dev scratch org.

* Open your VS code terminal
* Run `cci service list`, make sure github is connected. If it is not, run `cci service connect github`, with your user name and personal access token, you can get your personal access token follow this [section](https://salesforce.quip.com/vscdAl4Q3vIk#XaNACAhT9I5)
* Run `sfdx force:auth:web:login --setdefaultdevhubusername --setalias Lab1449DevHub` to connect to your dev hub(use your Lab1449 devhub username to log in). This will link your Lab1449 devhub. Run `cci service connect devhub Lab1449DevHub` and give `Lab1449DevHub` as an alias to connect with CCI.
* Create a scratch dev org `cci org info dev`
* Set it as default `cci org default dev`
* Push the existing code to your dev org `cci task run dx_push` (Will create a flow to automatically do this in the future)
* Open dev org `cci org browser dev`
* Retrieve changes in your org cci task run retrieve_changes --org dev to your local repository.
* run pmd `./pmdRunner.sh`
* fix prettier `npm ci & npm run prettier:fix`

## Common Commands
* ```cci org remove dev``` remove scratch org
* ```cci org scratch dev``` create scratch org config based on dev
* ```cci org info dev``` create org if not exist, and show login info
* ```cci flow run dev_org --org dev``` main dev flow
* ```cci org browser dev``` open org
* ```cci task run dx_push --org dev``` push local change under force-app to org
* ```cci task run dx_pull --org dev``` pull changes on the org
* ```cci task run run_tests --org dev``` run Apex tests
* ```sfdx force:package:list```  show existing packages
* ```sfdx force:package:version:list``` show existing versions
* ```npm ci``` install node modules
* ```npm run prettier:fix``` fix prettier
* ```./pmdRunner.sh``` check PMD rule
