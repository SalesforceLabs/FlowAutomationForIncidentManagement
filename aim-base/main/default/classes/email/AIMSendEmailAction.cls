/**
 * AIMSendEmailAction: Invocable class for sending core emails
 */
public with sharing class AIMSendEmailAction {
  /**
   * sendEmail: Invocable method to send emails to contacts
   *
   * @param sendEmailRequests (List<SendEmailRequest>): wrapper for storing email content
   *
   * @return List<SendEmailResult>: response wrapper for email result
   *
   * @throws Class AIMBaseException Generic exception
   */
  @InvocableMethod(
    label='Send Emails'
    description='Send Core Emails to the Contacts'
    category='AIM'
  )
  public static List<SendEmailResult> sendEmail(
    List<SendEmailRequest> sendEmailRequests
  ) {
    List<SendEmailResult> sendEmailResults = new List<SendEmailResult>();
    try {
      SendEmailRequest sendEmailRequest = sendEmailRequests.get(0);

      List<List<Contact>> processedContacts = AIMEmailUtility.filterValidContacts(
        sendEmailRequest.contacts
      );

      SendEmailResult sendEmailResult = new SendEmailResult();

      if (!processedContacts.isEmpty()) {
        Boolean areEmailsQueued = false;
        List<Contact> validContacts = processedContacts.get(0);
        if (!validContacts.isEmpty()) {
          AIMEmailRequest emailRequest = new AIMEmailRequest();
          emailRequest.setSubject(sendEmailRequest.subject);
          emailRequest.setBody(sendEmailRequest.body);
          emailRequest.setTemplateId(sendEmailRequest.templateId);
          emailRequest.setWhatId(sendEmailRequest.whatId);

          SaveAsActivityEnum saveAsActivity = AIMEmailUtility.VALUE_BY_SAVE_AS_ACTIVITY_ENUM.get(
            sendEmailRequest.saveAsActivityMethod
          );
          emailRequest.setSaveAsActivityMethod(
            (saveAsActivity == null) ? SaveAsActivityEnum.AUTO : saveAsActivity
          );

          if (
            sendEmailRequest.batchSize != null &&
            sendEmailRequest.batchSize > 0
          ) {
            emailRequest.setBatchSize(sendEmailRequest.batchSize);
          }
          emailRequest.setTotalRecipients(validContacts.size());

          AIMEmailUtility.setOrgWideEmailAddress(
            emailRequest,
            sendEmailRequest.orgWideEmailAddressId
          );

          areEmailsQueued = AIMSendEmailHandler.queueEmails(
            emailRequest,
            validContacts
          );
        }

        sendEmailResult.totalSuccessQueuedEmails = (areEmailsQueued)
          ? validContacts.size()
          : 0;
        sendEmailResult.totalFailedEmails =
          sendEmailRequest.contacts.size() -
          sendEmailResult.totalSuccessQueuedEmails;
        sendEmailResult.failedContactIds = new List<Id>();
        for (Contact contact : processedContacts.get(1)) {
          sendEmailResult.failedContactIds.add(contact.Id);
          sendEmailResult.failureMessage = 'Contacts does not have an email address or has opted out of Email.';
        }
      }
      sendEmailResults.add(sendEmailResult);
    } catch (Exception e) {
      throw new AIMBaseException(System.Label.AIM_Generic_Error, e);
    }
    return sendEmailResults;
  }

  /**
   * SendEmailResult: Inner Wrapper with Invocable variable for email content
   */
  public class SendEmailResult {
    @InvocableVariable(
      label='Total Emails Successfully Queued'
      description='Number of emails that were queued successfully'
    )
    public Integer totalSuccessQueuedEmails;

    @InvocableVariable(
      label='Total Emails Failed'
      description='Number of emails that were not queued successfully'
    )
    public Integer totalFailedEmails;

    @InvocableVariable(
      label='Failed Contact IDs'
      description='List of Contact Ids for which email were not queued'
    )
    public List<Id> failedContactIds;

    @InvocableVariable(
      label='Failure Message'
      description='Cause of the send email failure'
    )
    public String failureMessage;
  }

  /**
   * SendEmailRequest: Inner Wrapper with Invocable variable for Send email result
   */
  public class SendEmailRequest {
    @InvocableVariable(
      label='Contact Object Collection'
      required=true
      description='List of Contacts record for sending emails'
    )
    public List<Contact> contacts;

    @InvocableVariable(
      label='Org Wide Email Address ID'
      required=true
      description='Org-Wide Email Address Id'
    )
    public String orgWideEmailAddressId;

    @InvocableVariable(
      label='Email Template Id'
      description='Id of Email Template'
    )
    public String templateId;

    @InvocableVariable(label='Email Subject' description='Email Subject')
    public String subject;

    @InvocableVariable(label='Email Body' description='Body of the Email')
    public String body;

    @InvocableVariable(
      label='What Id'
      description='Id of Incident for which Email is being sent'
    )
    public String whatId;

    @InvocableVariable(
      label='Save as Activity'
      description='Method to log the sent Emails'
    )
    public Integer saveAsActivityMethod;

    @InvocableVariable(
      label='Batch Size'
      description='Number of Emails to be sent in a batch'
    )
    public Integer batchSize;
  }
}
