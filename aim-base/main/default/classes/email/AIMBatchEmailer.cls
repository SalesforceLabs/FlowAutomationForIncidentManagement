/**
 * AIMBatchEmailer Batch apex implementation to send emails
 */
public with sharing class AIMBatchEmailer implements Database.Batchable<sObject>, Database.Stateful {
  private AIMEmailRequest request;
  private List<Contact> recipients;

  public AIMBatchEmailer(AIMEmailRequest request, List<Contact> recipients) {
    this.request = request;
    this.recipients = recipients;
  }

  /**
   * start method that executes on batch apex invocable
   *
   * @param info (Database.BatchableContext): batchable context
   *
   * @return Database.QueryLocator: list of recipients
   */
  public Database.QueryLocator start(Database.BatchableContext info) {
    return Database.getQueryLocator(
      [SELECT Id, Email FROM Contact WHERE Id IN :recipients]
    );
  }

  /**
   * execute method to execute batches
   *
   * @param info (Database.BatchableContext): batchable context
   * @param currentRecipients (List<Contact>): list of recipients in current batch
   */
  public void execute(
    Database.BatchableContext info,
    List<Contact> currentRecipients
  ) {
    try {
      // pre-flight check if emails can be sent without hitting the daily limit
      Messaging.reserveSingleEmailCapacity(currentRecipients.size());

      AIMEmailUtility.sendEmail(currentRecipients, request);
    } catch (System.HandledException limitException) {
      Integer totalFailed =
        request.getTotalFailed() +
        (request.getTotalRecipients() - request.getTotalSent());
      request.setTotalFailed(totalFailed);
      System.abortJob(info.getJobId());
    } catch (Exception e) {
      // For unknown exception it is difficult to find exact count as batch size can also vary in some scenarios but this is best attempt considering it is possible that only this batch failed and subsequent ones might execute fine
      Integer totalFailed =
        request.getTotalFailed() +
        Math.mod(
          (request.getTotalRecipients() -
          (request.getTotalFailed() + request.getTotalSent())),
          currentRecipients.size()
        );
      request.setTotalFailed(totalFailed);
    } finally {
      AIMEmailUtility.updateTrackingTask(request);
    }
  }

  /**
   * finish method that execute when batch process finishes
   *
   * @param info (Database.BatchableContext): batchable context
   */
  public void finish(Database.BatchableContext info) {
  }
}
