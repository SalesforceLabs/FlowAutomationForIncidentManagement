public with sharing class AIMEmailUtility {
  public AIMEmailUtility() {
  }

  public static final Map<Integer, SaveAsActivityEnum> VALUE_BY_SAVE_AS_ACTIVITY_ENUM = new Map<Integer, SaveAsActivityEnum>{
    0 => SaveAsActivityEnum.OFF,
    1 => SaveAsActivityEnum.AUTO,
    2 => SaveAsActivityEnum.MANUAL
  };

  public static void sendEmail(
    List<Contact> recipients,
    AIMEmailRequest request
  ) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (Contact contact : recipients) {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setTargetObjectId(contact.Id);
      email.setTreatTargetObjectAsRecipient(true);
      email.setOrgWideEmailAddressId(request.orgWideEmailAddressId);
      if (
        String.isNotBlank(request.subject) && String.isNotBlank(request.body)
      ) {
        email.setSubject(request.subject);
        email.setHtmlBody(request.body);
        email.setTreatBodiesAsTemplate(true);
      } else if (string.isNotBlank(request.templateId)) {
        email.setTemplateId(request.templateId);
      }
      if(request.saveAsActivityMethod == SaveAsActivityEnum.OFF || request.saveAsActivityMethod == SaveAsActivityEnum.MANUAL){
      email.setSaveAsActivity(false);
      }
      if (String.isNotBlank(request.whatId)) {
        email.setWhatId(request.whatId);
      }
      emails.add(email);
    }

    if (!emails.isEmpty()) {
      //allOrNothing set to false to allows delivery of the messages that don't have errors.
    List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails, false);
        logger(emailResults, emails, request);
    }
  }

  private static void logger(
    List<Messaging.SendEmailResult> emailResults, List<Messaging.SingleEmailMessage> emailRequests, AIMEmailRequest request
  ) {
    List<EmailMessage> emailMessages = new List<EmailMessage>();
    for (Integer index = 0; index < emailResults.size(); index++) {
        Messaging.SendEmailResult emailResult = emailResults[index];
      if (emailResult.isSuccess()) {
        request.totalSent += 1;
      if(request.saveAsActivityMethod == SaveAsActivityEnum.MANUAL){
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.status = '3'; // email was sent
        emailMessage.relatedToId = request.whatId;
        emailMessage.EmailTemplateId = request.templateId;
        emailMessage.subject = emailRequests[index].getSubject(); // resolved merge fields
        emailMessage.htmlBody = emailRequests[index].getHtmlBody(); // resolved merge fields
        emailMessage.fromAddress = request.orgWideEmailAddress;
        emailMessage.fromName = request.orgWideEmailAddressName;
        String[] toIds = new List<String>{ emailRequests[index].getTargetObjectId() };
        emailMessage.toIds = toIds;
        emailMessages.add(emailMessage);
      }
      } else {
        request.totalFailed += 1;
      }
    }

    if(!emailMessages.isEmpty()){
    insert emailMessages;

    List<EmailMessageRelation> emailMessageRelations = new List<EmailMessageRelation>();
    for(EmailMessage emailMessage : emailMessages)
    {
    EmailMessageRelation emailMessageRelation = new EmailMessageRelation();
    emailMessageRelation.emailMessageId = emailMessage.id;
    emailMessageRelation.relationId = emailMessage.toIds.get(0);
    emailMessageRelation.relationType = 'ToAddress';
    emailMessageRelations.add(emailMessageRelation);
    }

    insert emailMessageRelations;
}
  }

  public static void updateTrackingTask(AIMEmailRequest request)
  {
    List<Task> trackingTasks = [SELECT Id, Status, Description FROM Task WHERE Id = :request.trackingTaskId LIMIT 1];

    if(!trackingTasks.isEmpty())
    {
        Task trackingTask = trackingTasks.get(0);
        String status = 'Updated';
        if(request.totalRecipients == request.totalSent + request.totalFailed)
        {
            trackingTask.Status = 'Completed';
            status = 'Completed';
        }
        trackingTask.Description += '\n\n ========================= \n' + status + ' At: ' + System.now().format() + '\n Total Emails Sent: ' + request.totalSent + '\n Total Emails Failed: ' + request.totalFailed;
        update trackingTask;
    }
  }

  public static List<Contact> spliceList(List<Contact> unprocessedContacts, Integer batchSize)
  {
    List<Contact> currentBatch = new List<Contact>();
    for (Integer index = 0; index < batchSize; index++)
    {
        if(unprocessedContacts.isEmpty())
        {
            break;
        }
        currentBatch.add(unprocessedContacts.remove(0));
    }
    return currentBatch;
  }

  public static void setOrgWideEmailAddress(AIMEmailRequest emailRequest, String orgWideEmailAddressId)
  {
    List<OrgWideEmailAddress> orgWideEmailAddress = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Id = :orgWideEmailAddressId];
    emailRequest.orgWideEmailAddressId = orgWideEmailAddress.get(0)?.Id;
    emailRequest.orgWideEmailAddress = orgWideEmailAddress.get(0)?.Address;
    emailRequest.orgWideEmailAddressName = orgWideEmailAddress.get(0)?.DisplayName;
  }

  public static void setTrackingTask(AIMEmailRequest emailRequest)
  {
    Task task = new Task();
    task.Subject = 'Send Emails Job Tracker [' + System.now().format() + ']';
    task.Status = 'In Progress';
    task.Type = 'Email';
    task.Description = 'Emails Queued at ' + System.now().format() + '\n Total Emails Queued: ' + emailRequest.totalRecipients;
    task.WhatId = emailRequest.whatId;
    insert task;

    emailRequest.trackingTaskId = task.Id;
  }

}
