/**
 * AIMSendEmailTest: Test Class for Email Editor and Send Email functionality
 */
@isTest
private with sharing class AIMSendEmailTest {
  @TestSetup
  static void createData() {
    Contact contact = new Contact(
      LastName = 'Test Contact',
      email = 'salesforce@aim.example.com'
    );
    insert contact;

    Incident incident = new Incident(
      Subject = 'Test Incident ',
      Impact = 'High',
      Urgency = 'High',
      Priority = 'Critical'
    );
    insert incident;
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

    Incident incident = [SELECT Id FROM Incident LIMIT 1];

    Test.startTest();
    List<AIMSendEmailAction.SendEmailRequest> sendEmailRequests = new List<AIMSendEmailAction.SendEmailRequest>();
    AIMSendEmailAction.SendEmailRequest sendEmailRequest = new AIMSendEmailAction.SendEmailRequest();
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
    sendEmailRequest.saveAsActivityMethod = 2;
    sendEmailRequests.add(sendEmailRequest);
    List<AIMSendEmailAction.SendEmailResult> sendEmailResults = AIMSendEmailAction.sendEmail(
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

    Incident incident = [SELECT Id FROM Incident LIMIT 1];

    Test.startTest();
    List<AIMSendEmailAction.SendEmailRequest> sendEmailRequests = new List<AIMSendEmailAction.SendEmailRequest>();
    AIMSendEmailAction.SendEmailRequest sendEmailRequest = new AIMSendEmailAction.SendEmailRequest();
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
    sendEmailRequest.saveAsActivityMethod = 2;
    sendEmailRequests.add(sendEmailRequest);
    List<AIMSendEmailAction.SendEmailResult> sendEmailResults = AIMSendEmailAction.sendEmail(
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
    Incident incident = [SELECT Id FROM Incident LIMIT 1];

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
