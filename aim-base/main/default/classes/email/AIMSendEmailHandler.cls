/**
 * AIMSendEmailHandler Handler class for queuing email. Has logic to choose the right async apex for queing emails
 *
 */
public with sharing class AIMSendEmailHandler {
  /**
   * queueEmails method to queue email using async apex
   *
   * @param emailRequest (AIMEmailRequest): Content of email
   * @param recipients (List<Contact>): list of recipients contact
   *
   * @return Boolean: indicates if emails were queued successfully
   */
  public static Boolean queueEmails(
    AIMEmailRequest emailRequest,
    List<Contact> recipients
  ) {
    AIMEmailUtility.createTrackingTask(emailRequest);

    // Get current flex queue size
    Integer flexQueueSize = [
      SELECT COUNT()
      FROM AsyncApexJob
      WHERE Status = 'Holding'
    ];

    // Use Batch Apex if there are more batches or flex queue is not close to full(limit = 100) Otherwise, use Queueable Apex
    if (
      recipients.size() / emailRequest.getBatchSize() >=
      AIMConstants.APEX_QUEUEABLE_BATCH_COUNT_THRESHOLD &&
      flexQueueSize < AIMConstants.BATCH_APEX_FLEX_QUEUE_THRESHOLD
    ) {
      AIMBatchEmailer batchEmailer = new AIMBatchEmailer(
        emailRequest,
        recipients
      );
      // can only run 1 batch in Test context
      if (Test.isRunningTest()) {
        Database.executeBatch(batchEmailer, recipients.size());
      } else {
        Database.executeBatch(batchEmailer, emailRequest.getBatchSize());
      }
    } else {
      AIMAsyncEmailer asyncEmailer = new AIMAsyncEmailer(
        emailRequest,
        recipients
      );
      System.enqueueJob(asyncEmailer);
    }
    return true;
  }
}
