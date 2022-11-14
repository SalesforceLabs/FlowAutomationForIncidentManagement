public with sharing class AIMBatchEmailer implements Database.Batchable<sObject>, Database.Stateful {
    private AIMEmailRequest request;
    private List<Contact> recipients;


    public AIMBatchEmailer(AIMEmailRequest request, List<Contact> recipients) {
        this.request = request;
        this.recipients = recipients;
    }

    public Database.QueryLocator start(Database.BatchableContext info){ 
        return Database.getQueryLocator([SELECT Id, Email FROM Contact WHERE Id IN :recipients]);
    }     
    public void execute(Database.BatchableContext info, List<Contact> currentRecipients){
        try
        {
          // pre-flight check if emails can be sent without hitting the daily limit
          Messaging.reserveSingleEmailCapacity(currentRecipients.size());

            AIMEmailUtility.sendEmail(currentRecipients, request);

        }
        catch(System.HandledException limitException)
        {
          request.totalFailed += (request.totalRecipients - request.totalSent);
            System.abortJob(info.getJobId());
        }
        finally {
            AIMEmailUtility.updateTrackingTask(request);
        }
    }     
    public void finish(Database.BatchableContext info){     
        //AIMEmailUtility.updateTrackingTask(request);
    } 
}
