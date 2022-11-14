public with sharing class AsyncEmailer implements Queueable {
  private AIMEmailRequest request;
  private List<Contact> recipients;

  public AsyncEmailer(AIMEmailRequest request, List<Contact> recipients) {
    this.request = request;
    this.recipients = recipients;
  }

  public void execute(QueueableContext context) {
    try
        {
          List<Contact> currentRecipients = AIMEmailUtility.spliceList(recipients, request.batchSize);

          // pre-flight check if emails can be sent without hitting the daily limit
            Messaging.reserveSingleEmailCapacity(currentRecipients.size());

            AIMEmailUtility.sendEmail(currentRecipients, request);
            if(!recipients.isEmpty())
            {
              AsyncEmailer asyncEmailer = new AsyncEmailer(request, recipients);
              System.enqueueJob(asyncEmailer);
            }
        }
        catch(System.HandledException limitException)
        {
          request.totalFailed += (request.totalRecipients - request.totalSent);
        }
        finally {
            AIMEmailUtility.updateTrackingTask(request);
        }
  }
}
