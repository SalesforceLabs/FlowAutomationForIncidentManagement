/**
 * EmailTemplateWrapper: Wrapper class for Email Template Editor LWC
 */
public with sharing class EmailTemplateWrapper {
  @AuraEnabled
  public String folderName { get; set; }

  @AuraEnabled
  public String folderId { get; set; }

  @AuraEnabled
  public String emailTemplateId { get; set; }

  @AuraEnabled
  public String emailBody { get; set; }

  @AuraEnabled
  public String emailSubject { get; set; }

  @AuraEnabled
  public String emailTemplateName { get; set; }
}
