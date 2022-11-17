/**
 * AIM_SendEmailTest: Test Class for Email Editor and Send Email functionality
 */
@isTest
private with sharing class AIM_SendEmailTest {
  @TestSetup
  static void createData() {
    Contact contact = new Contact(
      LastName = 'Test Contact',
      email = 'salesforce@aim.example.com'
    );
    insert contact;
  }
  /**
   * testEmailEditor: test method to retrieve email template data
   */
  @isTest
  static void testEmailEditor() {
    List<OrgWideEmailAddress> sendersAddresses = EmailTemplateEditorController.getSenderAddresses();
    Assert.isTrue(
      sendersAddresses.size() >= 0,
      'OrgWideEmailAddress is needed'
    );
    EmailTemplateEditorController.getEmailTemplates();
  }

  /**
   * testSendEmailSuccess: test method to send email successfully
   */
  @isTest
  static void testSendEmailSuccess() {
    Contact contact = [SELECT Id, Email FROM Contact LIMIT 1];

    Incident incident = AIMTestDataFactory.createIncidents(1)[0];

    Test.startTest();
    List<AIM_SendEmailAction.SendEmailRequest> sendEmailRequests = new List<AIM_SendEmailAction.SendEmailRequest>();
    AIM_SendEmailAction.SendEmailRequest sendEmailRequest = new AIM_SendEmailAction.SendEmailRequest();
    sendEmailRequest.contacts = new List<Contact>{ contact };
    List<OrgWideEmailAddress> orgWideEmailAddresses = [
      SELECT Id
      FROM OrgWideEmailAddress
      LIMIT 1
    ];
    sendEmailRequest.orgWideEmailAddressId = orgWideEmailAddresses.isEmpty()
      ? null
      : orgWideEmailAddresses.get(0).Id;
    sendEmailRequest.templateId = null;
    sendEmailRequest.subject = 'Test Subject';
    sendEmailRequest.body = 'Test Body';
    sendEmailRequest.whatId = incident.Id;
    sendEmailRequest.shouldSaveAsActivity = true;
    sendEmailRequests.add(sendEmailRequest);
    List<AIM_SendEmailAction.SendEmailResult> sendEmailResults = AIM_SendEmailAction.sendEmail(
      sendEmailRequests
    );
    Integer successEmail = sendEmailResults.get(0).totalSuccessEmails;
    Integer invocations = Limits.getEmailInvocations();
    Assert.areEqual(1, successEmail, 'Email should be successfully sent');
    Assert.areEqual(1, invocations, 'An email should be sent');
    Test.stopTest();
  }

  /**
   * testSendEmailFailed: test method to send email unsuccessfully
   */
  @isTest
  static void testSendEmailFailed() {
    Contact contact = new Contact(LastName = 'Test Contact');
    insert contact;

    Incident incident = AIMTestDataFactory.createIncidents(1)[0];

    Test.startTest();
    List<AIM_SendEmailAction.SendEmailRequest> sendEmailRequests = new List<AIM_SendEmailAction.SendEmailRequest>();
    AIM_SendEmailAction.SendEmailRequest sendEmailRequest = new AIM_SendEmailAction.SendEmailRequest();
    sendEmailRequest.contacts = new List<Contact>{ contact };
    List<OrgWideEmailAddress> orgWideEmailAddresses = [
      SELECT Id
      FROM OrgWideEmailAddress
      LIMIT 1
    ];
    sendEmailRequest.orgWideEmailAddressId = orgWideEmailAddresses.isEmpty()
      ? null
      : orgWideEmailAddresses.get(0).Id;
    sendEmailRequest.templateId = null;
    sendEmailRequest.subject = 'Test Subject';
    sendEmailRequest.body = 'Test Body';
    sendEmailRequest.whatId = incident.Id;
    sendEmailRequest.shouldSaveAsActivity = true;
    sendEmailRequests.add(sendEmailRequest);
    List<AIM_SendEmailAction.SendEmailResult> sendEmailResults = AIM_SendEmailAction.sendEmail(
      sendEmailRequests
    );
    Integer failedEmail = sendEmailResults.get(0).totalFailedEmails;
    Assert.areEqual(1, failedEmail, 'An email should be failed');
    Test.stopTest();
  }

  /**
   * testSendDummyEmail: test method to send dummy email from emailTemplateEditor LWC
   */
  @isTest
  static void testSendDummyEmail() {
    Incident incident = AIMTestDataFactory.createIncidents(1)[0];

    List<OrgWideEmailAddress> orgWideEmailAddresses = [
      SELECT Id
      FROM OrgWideEmailAddress
      LIMIT 1
    ];
    String orgWideEmailAddressId = orgWideEmailAddresses.isEmpty()
      ? null
      : orgWideEmailAddresses.get(0).Id;

    Test.startTest();
    EmailTemplateEditorController.sendTestEmail(
      'salesforce@aim.example.com',
      orgWideEmailAddressId,
      'Test Subject',
      'Test Body',
      incident.Id
    );
    Integer invocations = Limits.getEmailInvocations();
    Assert.areEqual(1, invocations, 'An dummy email should be sent');
    Test.stopTest();
  }
}
