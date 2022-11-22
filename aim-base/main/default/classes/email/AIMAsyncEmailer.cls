/**
 * AIMAsyncEmailer Queueable apex to chain sending email functionality
 */
public with sharing class AIMAsyncEmailer implements Queueable {
  private AIMEmailRequest request;
  private List<Contact> recipients;

  public AIMAsyncEmailer(AIMEmailRequest request, List<Contact> recipients) {
    this.request = request;
    this.recipients = recipients;
  }

  /**
   * execute method to execute queueable job
   *
   * @param context (QueueableContext): Queueable context
   */
  public void execute(QueueableContext context) {
    try {
      // populate recipients for current execution and remove from all recipient list
      List<Contact> currentRecipients = AIMEmailUtility.spliceContactList(
        recipients,
        request.getBatchSize()
      );

      // pre-flight check if emails can be sent without hitting the daily limit
      Messaging.reserveSingleEmailCapacity(currentRecipients.size());

      AIMEmailUtility.sendEmail(currentRecipients, request);
      if (!recipients.isEmpty() && !Test.isRunningTest()) {
        AIMAsyncEmailer asyncEmailer = new AIMAsyncEmailer(request, recipients);
        System.enqueueJob(asyncEmailer);
      }
    } catch (Exception e) {
      // includes exception for hittig pre-flight limits
      calculateFailedEmailsForExceptions(request);
    } finally {
      AIMEmailUtility.updateTrackingTask(request);
    }
  }

  /**
   * calculateFailedEmailsForExceptions method to calculate failed email count on exception
   *
   * @param request (AIMEmailRequest): Email content
   */
  private static void calculateFailedEmailsForExceptions(
    AIMEmailRequest request
  ) {
    Integer totalFailed =
      request.getTotalFailed() +
      (request.getTotalRecipients() - request.getTotalSent());
    request.setTotalFailed(totalFailed);
  }
}
