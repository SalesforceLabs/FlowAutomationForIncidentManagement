/**
 * AIM_SendEmailAction: Invocable class for sending core emails
 */
public with sharing class AIM_SendEmailAction {
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
    for (SendEmailRequest sendEmailRequest : sendEmailRequests) {
      List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
      SendEmailResult sendEmailResult = new SendEmailResult();
      sendEmailResult.totalSuccessEmails = 0;
      sendEmailResult.totalFailedEmails = 0;
      sendEmailResult.failedContactIds = new List<Id>();
      sendEmailResult.failureMessages = new List<String>();

      for (Contact contact : sendEmailRequest.contacts) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(contact.Id);
        email.setTreatTargetObjectAsRecipient(true);
        email.setOrgWideEmailAddressId(sendEmailRequest.orgWideEmailAddressId);
        if (
          String.isNotBlank(sendEmailRequest.subject) &&
          String.isNotBlank(sendEmailRequest.body)
        ) {
          email.setSubject(sendEmailRequest.subject);
          email.setHtmlBody(sendEmailRequest.body);
          email.setTreatBodiesAsTemplate(true);
        } else if (string.isNotBlank(sendEmailRequest.templateId)) {
          email.setTemplateId(sendEmailRequest.templateId);
        }
        email.setSaveAsActivity(sendEmailRequest.shouldSaveAsActivity);
        if (String.isNotBlank(sendEmailRequest.whatId)) {
          email.setWhatId(sendEmailRequest.whatId);
        }
        emails.add(email);
      }

      if (!emails.isEmpty()) {
        //allOrNothing set to false to allows delivery of the messages that don't have errors.
        List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(
          emails,
          false
        );
        for (Messaging.SendEmailResult emailResult : emailResults) {
          if (emailResult.isSuccess()) {
            sendEmailResult.totalSuccessEmails += 1;
          } else {
            sendEmailResult.totalFailedEmails += 1;
            sendEmailResult.failedContactIds.add(
              emailResult.getErrors()[0].getTargetObjectId()
            );
            sendEmailResult.failureMessages.add(
              emailResult.getErrors()[0].getMessage()
            );
          }
        }
      }
      sendEmailResults.add(sendEmailResult);
    }
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
    public string orgWideEmailAddressId;

    @InvocableVariable(
      label='Email Template Id'
      description='Id of Email Template'
    )
    public string templateId;

    @InvocableVariable(label='Email Subject' description='Email Subject')
    public string subject;

    @InvocableVariable(label='Email Body' description='Body of the Email')
    public string body;

    @InvocableVariable(
      label='What Id'
      description='Id of Incident for which Email is being sent'
    )
    public string whatId;

    @InvocableVariable(
      label='Save as Activity?'
      description='Flag for saving Email as an Activity'
    )
    public boolean shouldSaveAsActivity;
  }
}
