/**
 * EmailTemplateEditorController: Apex controller called by LWC to retrieve template and org-wide email data.
 */
public with sharing class EmailTemplateEditorController {
  /**
   * sendTestEmail: Method to send a test email
   *
   * @param emailAddress (String): Test Email Address
   * @param sender (String): org wide email Id
   * @param subject (String): Test email subject
   * @param body (String): Test email body
   * @param whatId (String): Incident Id
   */
  @AuraEnabled
  public static void sendTestEmail(
    String emailAddress,
    String sender,
    String subject,
    String body,
    String whatId
  ) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    List<String> sendTo = new List<String>();
    sendTo.add(emailAddress);
    email.setToAddresses(sendTo);
    email.setOrgWideEmailAddressId(sender);
    email.setSubject(subject);
    email.setHtmlBody(body);
    email.setSaveAsActivity(false);
    email.setWhatId(whatId);
    emails.add(email);

    Messaging.sendEmail(emails);
  }

  /**
   * getSenderAddresses: Aura-Enabled method to retrieve org wide email address.
   *
   *
   * @return list<OrgWideEmailAddress>: List of Org wide email addresses
   */
  @AuraEnabled(cacheable=true scope='global')
  public static list<OrgWideEmailAddress> getSenderAddresses() {
    return new List<OrgWideEmailAddress>(
      [SELECT ID, Address, DisplayName FROM OrgWideEmailAddress]
    );
  }

  /**
   * getEmailTemplates: Aura-Enabled method to retrieve email template data.
   *
   *
   * @return Map<String, List<EmailTemplateWrapper>>: Map for template folder and email template data.
   */
  @AuraEnabled(cacheable=true scope='global')
  public static Map<String, List<EmailTemplateWrapper>> getEmailTemplates() {
    Map<String, List<EmailTemplateWrapper>> emailTemplatesbyFolder = new Map<String, List<EmailTemplateWrapper>>();
    List<ID> folderIDs = new List<ID>();
    for (Folder folder : [
      SELECT Id, Name
      FROM Folder
      WHERE Type = 'EmailTemplate'
    ]) {
      folderIds.add(folder.Id);
    }
    for (EmailTemplate emailTemplate : [
      SELECT Id, FolderId, HtmlValue, FolderName, IsActive, Body, Name, Subject
      FROM EmailTemplate
      WHERE IsActive = TRUE AND FolderId IN :folderIDs
    ]) {
      EmailTemplateWrapper emailTemplateWrapper = new EmailTemplateWrapper();
      emailTemplateWrapper.folderId = emailTemplate.FolderId;
      emailTemplateWrapper.folderName = emailTemplate.FolderName;
      emailTemplateWrapper.emailTemplateId = emailTemplate.Id;
      emailTemplateWrapper.emailTemplateName = emailTemplate.Name;
      emailTemplateWrapper.emailBody = (emailTemplate.HtmlValue != null
        ? emailTemplate.HtmlValue
        : '');
      emailTemplateWrapper.emailSubject = emailTemplate.Subject;
      if (
        emailTemplatesbyFolder.containsKey(
          String.valueOf(emailTemplate.FolderId)
        )
      ) {
        emailTemplatesbyFolder.get(String.valueOf(emailTemplate.FolderId))
          .add(emailTemplateWrapper);
      } else {
        List<EmailTemplateWrapper> emailTemplateWrappers = new List<EmailTemplateWrapper>();
        emailTemplateWrappers.add(emailTemplateWrapper);
        emailTemplatesbyFolder.put(
          String.valueOf(emailTemplate.FolderId),
          emailTemplateWrappers
        );
      }
    }
    return emailTemplatesbyFolder;
  }
}
