public with sharing class AIMSendEmailHandler {
  public AIMSendEmailHandler() {
  }

  public static List<Contact> filterValidContacts(List<Contact> allContacts) {
    List<Contact> validContacts = new List<Contact>();
    for (Contact contact : allContacts) {
      if (!contact.HasOptedOutOfEmail && !String.isBlank(contact.Email)) {
        validContacts.add(contact);
      }
    }
    return validContacts;
  }

  public static Boolean queueEmails(AIMEmailRequest emailRequest, List<Contact> recipients) {
    AIMEmailUtility.setTrackingTask(emailRequest);

    // Get current flex queue size
    Integer flexQueueSize = [
      SELECT COUNT()
      FROM AsyncApexJob
      WHERE Status = 'Holding'
    ];

    // Use Batch Apex if there are more batches or flex queue is not close to full(limit = 100) Otherwise, use Queueable Apex
    if (
        recipients.size() / emailRequest.batchSize >= 5 &&
      flexQueueSize < 95
    ) {
      AIMBatchEmailer batchEmailer = new AIMBatchEmailer(emailRequest, recipients);
      Database.executeBatch(batchEmailer, emailRequest.batchSize);
    } else {
      AsyncEmailer asyncEmailer = new AsyncEmailer(emailRequest, recipients);
      System.enqueueJob(asyncEmailer);
    }
    return true;
  }
}
