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

    SendEmailRequest sendEmailRequest = sendEmailRequests.get(0);

    List<Contact> validContacts = AIMSendEmailHandler.filterValidContacts(sendEmailRequest.contacts);

    SendEmailResult sendEmailResult = new SendEmailResult();
    Boolean areEmailsQueued = false;

    if(!validContacts.isEmpty())
    {
    AIMEmailRequest emailRequest = new AIMEmailRequest();
    emailRequest.subject = sendEmailRequest.subject;
    emailRequest.body = sendEmailRequest.body;
    emailRequest.templateId = sendEmailRequest.templateId;
    emailRequest.whatId = sendEmailRequest.whatId;
    SaveAsActivityEnum saveAsActivity = AIMEmailUtility.VALUE_BY_SAVE_AS_ACTIVITY_ENUM.get(sendEmailRequest.saveAsActivityMethod);
    emailRequest.saveAsActivityMethod = (saveAsActivity == null) ? SaveAsActivityEnum.AUTO : saveAsActivity;
    emailRequest.batchSize = sendEmailRequest.batchSize;
    emailRequest.totalRecipients = validContacts.size();

    AIMEmailUtility.setOrgWideEmailAddress(emailRequest, sendEmailRequest.orgWideEmailAddressId);

    areEmailsQueued = AIMSendEmailHandler.queueEmails(emailRequest, validContacts);
    }
    
    sendEmailResult.totalSuccessEmails = (areEmailsQueued) ? validContacts.size() : 0;
    sendEmailResult.totalFailedEmails = sendEmailRequest.contacts.size() - sendEmailResult.totalSuccessEmails;

    sendEmailResults.add(sendEmailResult);
    
    return sendEmailResults;
  }
  

  /**
   * SendEmailResult: Inner Wrapper with Invocable variable for email content
   */
  public class SendEmailResult {
    @InvocableVariable(
      label='Total Emails Successfully Sent'
      description='Number of emails that were sent successfully'
    )
    public Integer totalSuccessEmails;

    @InvocableVariable(
      label='Total Emails Failed'
      description='Number of emails that were not sent successfully'
    )
    public Integer totalFailedEmails;

    @InvocableVariable(
      label='Failed Contact IDs'
      description='List of Contact Ids for which email were not sent'
    )
    public List<Id> failedContactIds;

    @InvocableVariable(
      label='Failure Messages'
      description='Cause of the send email failure'
    )
    public List<String> failureMessages;
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
