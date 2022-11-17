/**
 * AIMEmailUtility Utility class to send, log emails.
 */
public with sharing class AIMEmailUtility {
  /**
   * VALUE_BY_SAVE_AS_ACTIVITY_ENUM Constant to map value from Flow to SaveAsActivity method
   */
  public static final Map<Integer, SaveAsActivityEnum> VALUE_BY_SAVE_AS_ACTIVITY_ENUM = new Map<Integer, SaveAsActivityEnum>{
    0 => SaveAsActivityEnum.OFF,
    1 => SaveAsActivityEnum.AUTO,
    2 => SaveAsActivityEnum.MANUAL
  };

  /**
   * sendEmail method to send email using Messaging class
   *
   * @param recipients (List<Contact>): List of recipient
   * @param request (AIMEmailRequest): Email content
   */
  public static void sendEmail(
    List<Contact> recipients,
    AIMEmailRequest request
  ) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (Contact contact : recipients) {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setTargetObjectId(contact.Id);
      email.setTreatTargetObjectAsRecipient(true);
      email.setOrgWideEmailAddressId(request.getOrgWideEmailAddressId());
      if (
        String.isNotBlank(request.getSubject()) &&
        String.isNotBlank(request.getBody())
      ) {
        email.setSubject(request.getSubject());
        email.setHtmlBody(request.getBody());
        email.setTreatBodiesAsTemplate(true);
      } else if (string.isNotBlank(request.getTemplateId())) {
        email.setTemplateId(request.getTemplateId());
      }
      if (
        request.getSaveAsActivityMethod() == SaveAsActivityEnum.OFF ||
        request.getSaveAsActivityMethod() == SaveAsActivityEnum.MANUAL
      ) {
        email.setSaveAsActivity(false);
      }
      if (String.isNotBlank(request.getWhatId())) {
        email.setWhatId(request.getWhatId());
      }
      emails.add(email);
    }

    if (!emails.isEmpty()) {
      //allOrNothing set to false to allows delivery of the messages that don't have errors.
      List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(
        emails,
        false
      );
      logAsTask(emailResults, emails, request);
    }
  }

  /**
   * logAsEmailMessage method to log emails as EmailMessage that requires Enhanced Emails.
   *
   * @param sendEmailResults (List<Messaging.SendEmailResult>): result of send email
   * @param singleEmailMessages (List<Messaging.SingleEmailMessage>): singleEmailMessage request
   * @param request (AIMEmailRequest): Email Content
   */
  // TODO - Remove based on PM feedback
  /*
  private static void logAsEmailMessage(
    List<Messaging.SendEmailResult> sendEmailResults,
    List<Messaging.SingleEmailMessage> singleEmailMessages,
    AIMEmailRequest request
  ) {
    List<EmailMessage> emailMessages = new List<EmailMessage>();
    List<Task> tasks = new List<Task>();
    for (Integer index = 0; index < sendEmailResults.size(); index++) {
      Messaging.SendEmailResult emailResult = sendEmailResults[index];
      if (emailResult.isSuccess()) {
        request.setTotalSent(request.getTotalSent() + 1);
        if (request.getSaveAsActivityMethod() == SaveAsActivityEnum.MANUAL) {
          EmailMessage emailMessage = new EmailMessage();
          emailMessage.status = '3'; // email was sent
          emailMessage.relatedToId = request.getWhatId();
          emailMessage.EmailTemplateId = request.getTemplateId();
          emailMessage.subject = singleEmailMessages[index].getSubject(); // resolved merge fields
          emailMessage.htmlBody = singleEmailMessages[index].getHtmlBody(); // resolved merge fields
          emailMessage.fromAddress = request.getOrgWideEmailAddress();
          emailMessage.fromName = request.getOrgWideEmailAddressName();
          String[] toIds = new List<String>{
            singleEmailMessages[index].getTargetObjectId()
          };
          emailMessage.toIds = toIds;
          emailMessages.add(emailMessage);
        }
      } else {
        request.setTotalFailed(request.getTotalFailed() + 1);
        if (request.getSaveAsActivityMethod() != SaveAsActivityEnum.OFF) {
          tasks.add(
            createTaskForEmails(singleEmailMessages[index], request, false)
          );
        }
      }
    }

    if (!emailMessages.isEmpty()) {
      insert emailMessages;

      List<EmailMessageRelation> emailMessageRelations = new List<EmailMessageRelation>();
      for (EmailMessage emailMessage : emailMessages) {
        EmailMessageRelation emailMessageRelation = new EmailMessageRelation();
        emailMessageRelation.emailMessageId = emailMessage.id;
        emailMessageRelation.relationId = emailMessage.toIds.get(0);
        emailMessageRelation.relationType = 'ToAddress';
        emailMessageRelations.add(emailMessageRelation);
      }

      insert emailMessageRelations;
    }

    if (!tasks.isEmpty()) {
      insert tasks;
    }
  }*/

  /**
   * logAsTask method to log Emails as Task in the org
   *
   * @param sendEmailResults (List<Messaging.SendEmailResult>): Write the parameter description
   * @param singleEmailMessages (List<Messaging.SingleEmailMessage>): Write the parameter description
   * @param request (AIMEmailRequest): Write the parameter description
   */
  private static void logAsTask(
    List<Messaging.SendEmailResult> sendEmailResults,
    List<Messaging.SingleEmailMessage> singleEmailMessages,
    AIMEmailRequest request
  ) {
    List<Task> tasks = new List<Task>();
    for (Integer index = 0; index < sendEmailResults.size(); index++) {
      Messaging.SendEmailResult sendEmailResult = sendEmailResults[index];
      Messaging.SingleEmailMessage singleEmailMessage = singleEmailMessages[
        index
      ];
      if (sendEmailResult.isSuccess()) {
        request.setTotalSent(request.getTotalSent() + 1);
        if (request.getSaveAsActivityMethod() != SaveAsActivityEnum.OFF) {
          tasks.add(createTaskForEmails(singleEmailMessage, request, true));
        }
      } else {
        request.setTotalFailed(request.getTotalFailed() + 1);
        if (request.getSaveAsActivityMethod() != SaveAsActivityEnum.OFF) {
          tasks.add(createTaskForEmails(singleEmailMessage, request, false));
        }
      }
    }

    if (!tasks.isEmpty()) {
      insert tasks;
    }
  }

  /**
   * createTaskForEmails method to create Task record for recipient
   *
   * @param singleEmailMessage (Messaging.SingleEmailMessage): Information on individual email like recipient contact
   * @param request (AIMEmailRequest): Email Content
   * @param isSuccess (Boolean): Flag to track if email was sent successfully from apex
   *
   * @return Task: Created Task for individual recipient
   */
  private static Task createTaskForEmails(
    Messaging.SingleEmailMessage singleEmailMessage,
    AIMEmailRequest request,
    Boolean isSuccess
  ) {
    Task task = new Task();
    task.WhatId = request.getWhatId();
    task.WhoId = singleEmailMessage.getTargetObjectId();
    task.Type = 'Email';

    task.Status = 'Completed';
    String subject = 'Email: ' + singleEmailMessage.getSubject(); // resolved merge fields
    if (!isSuccess) {
      subject = 'Failed ' + subject;
      task.Status = 'Deferred';
    }
    task.Subject = abbreviate(subject, AIMConstants.MAX_TASK_SUBJECT_LENGTH);

    String description = String.format(
      AIMConstants.EMAIL_TASK_DESCRIPTION,
      new List<Object>{
        request.getOrgWideEmailAddressName(),
        request.getOrgWideEmailAddress(),
        singleEmailMessage.getSubject(),
        convertHTML2Text(singleEmailMessage.getHtmlBody())
      }
    );
    task.Description = abbreviate(
      description,
      AIMConstants.MAX_TASK_DESCRIPTION_LENGTH
    );

    return task;
  }

  /**
   * convertHTML2Text method to convert HTML into Text as Task 'description' field supports text value only
   *
   * @param htmlValue (String): HTML value of email body
   *
   * @return String: Email body as Text
   */
  private static String convertHTML2Text(String htmlValue) {
    String textValue = htmlValue.replaceAll(
        AIMConstants.HTML2TEXT_REGEX_PATTERNS[0],
        AIMConstants.HTML2TEXT_REPLACEMENTS[0]
      )
      .replaceAll(
        AIMConstants.HTML2TEXT_REGEX_PATTERNS[1],
        AIMConstants.HTML2TEXT_REPLACEMENTS[1]
      )
      .replaceAll(
        AIMConstants.HTML2TEXT_REGEX_PATTERNS[2],
        AIMConstants.HTML2TEXT_REPLACEMENTS[2]
      )
      .replaceAll(
        AIMConstants.HTML2TEXT_REGEX_PATTERNS[3],
        AIMConstants.HTML2TEXT_REPLACEMENTS[3]
      )
      .replaceAll(
        AIMConstants.HTML2TEXT_REGEX_PATTERNS[4],
        AIMConstants.HTML2TEXT_REPLACEMENTS[4]
      );
    return textValue;
  }

  /**
   * abbreviate method to abbreviate string based on maximum length
   *
   * @param input (String): Input string
   * @param maxLength (Integer): Maximum length of string allowed
   *
   * @return String: abbreviated string
   */
  private static String abbreviate(String input, Integer maxLength) {
    return input.abbreviate(maxLength);
  }

  /**
   * spliceContactList method to create list of contact for current execution and also remove it from pending recipient list. Used in queueable apex implementation.
   *
   * @param unprocessedContacts (List<Contact>): List of contacts that have not been sent emails
   * @param batchSize (Integer): batch size of the job
   *
   * @return List<Contact>: contact for current batch
   */
  public static List<Contact> spliceContactList(
    List<Contact> unprocessedContacts,
    Integer batchSize
  ) {
    List<Contact> currentBatch = new List<Contact>();
    for (Integer index = 0; index < batchSize; index++) {
      if (unprocessedContacts.isEmpty()) {
        break;
      }
      currentBatch.add(unprocessedContacts.remove(0));
    }
    return currentBatch;
  }

  /**
   * filterValidContacts method to segregate valid and invalid contacts based on Contact email address and Email opt out field
   *
   * @param allContacts (List<Contact>): Contact list to validate
   *
   * @return List<List<Contact>>: List of List of Contacts. index = 0 has valid Contacts, index =1 has invalid contacts
   */
  public static List<List<Contact>> filterValidContacts(
    List<Contact> allContacts
  ) {
    List<List<Contact>> processedContacts = new List<List<Contact>>();
    List<Contact> validContacts = new List<Contact>();
    List<Contact> invalidContacts = new List<Contact>();
    for (Contact contact : allContacts) {
      if (!contact.HasOptedOutOfEmail && !String.isBlank(contact.Email)) {
        validContacts.add(contact);
      } else {
        invalidContacts.add(contact);
      }
    }
    processedContacts.add(validContacts);
    processedContacts.add(invalidContacts);
    return processedContacts;
  }

  /**
   * setOrgWideEmailAddress method to populate org-wide email address details in the Email request
   *
   * @param emailRequest (AIMEmailRequest): Email content
   * @param orgWideEmailAddressId (String): org-wide email address Id
   */
  public static void setOrgWideEmailAddress(
    AIMEmailRequest emailRequest,
    String orgWideEmailAddressId
  ) {
    List<OrgWideEmailAddress> orgWideEmailAddress = [
      SELECT Id, Address, DisplayName
      FROM OrgWideEmailAddress
      WHERE Id = :orgWideEmailAddressId
    ];
    emailRequest.setOrgWideEmailAddressId(orgWideEmailAddress.get(0)?.Id);
    emailRequest.setOrgWideEmailAddress(orgWideEmailAddress.get(0)?.Address);
    emailRequest.setOrgWideEmailAddressName(
      orgWideEmailAddress.get(0)?.DisplayName
    );
  }

  /**
   * createTrackingTask method to create a Task for WhatId(Incident) to track progress of async jobs
   *
   * @param emailRequest (AIMEmailRequest): Email Content
   */
  public static void createTrackingTask(AIMEmailRequest emailRequest) {
    Task task = new Task();
    task.Subject = String.format(
      AIMConstants.TRACKING_TASK_SUBJECT,
      new List<Object>{ System.now().format() }
    );
    task.Status = 'In Progress';
    task.Type = 'Email';
    task.Description = String.format(
      AIMConstants.TRACKING_TASK_DESCRIPTION_HEADER,
      new List<Object>{
        System.now().format(),
        emailRequest.getTotalRecipients()
      }
    );
    task.WhatId = emailRequest.getWhatId();
    insert task;

    emailRequest.setTrackingTaskId(task.Id);
  }

  /**
   * updateTrackingTask method to append each batch progress on the exisitng tracking Task
   *
   * @param request (AIMEmailRequest): Email Content
   */
  public static void updateTrackingTask(AIMEmailRequest request) {
    List<Task> trackingTasks = [
      SELECT Id, Status, Description
      FROM Task
      WHERE Id = :request.getTrackingTaskId()
      LIMIT 1
    ];

    if (!trackingTasks.isEmpty()) {
      Task trackingTask = trackingTasks.get(0);
      String jobStatus = 'Updated';
      if (
        request.getTotalRecipients() ==
        request.getTotalSent() + request.getTotalFailed()
      ) {
        trackingTask.Status = 'Completed';
        jobStatus = 'Completed';
      }
      trackingTask.Description = populateDescription(
        trackingTask.Description,
        jobStatus,
        request
      );
      update trackingTask;
    }
  }

  /**
   * populateDescription utility method to update description of tracking Task
   *
   * @param currentDescription (String): Current Task description
   * @param jobStatus (String): Track is sending email jobs is complete
   * @param request (AIMEmailRequest): Email Content
   *
   * @return String: updated description
   */
  private static String populateDescription(
    String currentDescription,
    String jobStatus,
    AIMEmailRequest request
  ) {
    String appendedDescription = String.format(
      AIMConstants.TRACKING_TASK_DESCRIPTION_BODY,
      new List<Object>{
        jobStatus,
        System.now().format(),
        request.getTotalSent(),
        request.getTotalFailed()
      }
    );
    // Checking is current description length is close to the filed limit then put a truncation meesage and log the final batch execution only
    if (
      currentDescription.length() >
      AIMConstants.TASK_DESCRIPTION_TRUNCATION_THRESHOLD &&
      jobStatus.equals('Completed')
    ) {
      currentDescription += String.format(
        AIMConstants.TRACKING_TASK_DESCRIPTION_TRUNCATED,
        new List<Object>{ appendedDescription }
      );
    } else if (
      currentDescription.length() <
      AIMConstants.TASK_DESCRIPTION_TRUNCATION_THRESHOLD
    ) {
      currentDescription += appendedDescription;
    }
    return currentDescription;
  }
}
