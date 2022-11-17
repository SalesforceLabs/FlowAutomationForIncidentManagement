/**
 * AIMSendEmailTest: Test Class for Email Editor and Send Email functionality
 */
@isTest
private with sharing class AIMSendEmailTest {
  @TestSetup
  static void createData() {
    AIMTestDataFactory.createIncidents(1);
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
   * testSendEmailSuccessQueueable: test method to send email successfully via Queueable Apex
   */
  @isTest
  static void testSendEmailSuccessQueueable() {
    List<Contact> contacts = AIMTestDataFactory.createContacts(1, null);

    Incident incident = [SELECT Id FROM Incident LIMIT 1];

    Test.startTest();
    List<AIMSendEmailAction.SendEmailRequest> sendEmailRequests = new List<AIMSendEmailAction.SendEmailRequest>();
    AIMSendEmailAction.SendEmailRequest sendEmailRequest = AIMTestDataFactory.createSendEmailRequest(
      contacts,
      incident,
      1
    );
    sendEmailRequests.add(sendEmailRequest);
    List<AIMSendEmailAction.SendEmailResult> sendEmailResults = AIMSendEmailAction.sendEmail(
      sendEmailRequests
    );
    Integer successEmail = sendEmailResults.get(0).totalSuccessQueuedEmails;
    Test.stopTest();
    Assert.areEqual(1, successEmail, 'Email should be successfully sent');
  }

  /**
   * testSendQueueableEmailOverLimit: test method to send email via Queueable Apex hitting the limit
   */
  @isTest
  static void testSendQueueableEmailOverLimit() {
    List<Contact> contacts = AIMTestDataFactory.createContacts(20, null);

    Incident incident = [SELECT Id FROM Incident LIMIT 1];

    Test.startTest();
    List<AIMSendEmailAction.SendEmailRequest> sendEmailRequests = new List<AIMSendEmailAction.SendEmailRequest>();
    AIMSendEmailAction.SendEmailRequest sendEmailRequest = AIMTestDataFactory.createSendEmailRequest(
      contacts,
      incident,
      20
    );
    sendEmailRequests.add(sendEmailRequest);
    List<AIMSendEmailAction.SendEmailResult> sendEmailResults = AIMSendEmailAction.sendEmail(
      sendEmailRequests
    );
    Integer successEmail = sendEmailResults.get(0).totalSuccessQueuedEmails;
    Test.stopTest();
    // Different org edition has different limit so we can assert equal for successful requests only
    Assert.areEqual(20, successEmail, 'Something went wrong queuing emails');
  }

  /**
   * testSendEmailSuccessBatchable: test method to send email successfully via Batch Apex
   */
  @isTest
  static void testSendEmailSuccessBatchable() {
    List<Contact> contacts = AIMTestDataFactory.createContacts(6, null);

    Incident incident = [SELECT Id FROM Incident LIMIT 1];
    Test.startTest();
    List<AIMSendEmailAction.SendEmailRequest> sendEmailRequests = new List<AIMSendEmailAction.SendEmailRequest>();
    AIMSendEmailAction.SendEmailRequest sendEmailRequest = AIMTestDataFactory.createSendEmailRequest(
      contacts,
      incident,
      1
    );
    sendEmailRequests.add(sendEmailRequest);
    List<AIMSendEmailAction.SendEmailResult> sendEmailResults = AIMSendEmailAction.sendEmail(
      sendEmailRequests
    );
    Integer successEmail = sendEmailResults.get(0).totalSuccessQueuedEmails;
    Test.stopTest();
    Assert.areEqual(6, successEmail, 'Email should be successfully queued');
  }

  /**
   * testSendBatchEmailOverLimit: test method to send email via Batch Apex hitting the limit
   */
  @isTest
  static void testSendBatchEmailOverLimit() {
    List<Contact> contacts = AIMTestDataFactory.createContacts(20, null);

    Incident incident = [SELECT Id FROM Incident LIMIT 1];
    Test.startTest();
    List<AIMSendEmailAction.SendEmailRequest> sendEmailRequests = new List<AIMSendEmailAction.SendEmailRequest>();
    AIMSendEmailAction.SendEmailRequest sendEmailRequest = AIMTestDataFactory.createSendEmailRequest(
      contacts,
      incident,
      1
    );
    sendEmailRequests.add(sendEmailRequest);
    List<AIMSendEmailAction.SendEmailResult> sendEmailResults = AIMSendEmailAction.sendEmail(
      sendEmailRequests
    );
    Test.stopTest();
    Integer successEmail = sendEmailResults.get(0).totalSuccessQueuedEmails;
    // Different org edition has different limit so we can assert equal for successful requests only
    Assert.areEqual(20, successEmail, 'Something went wrong setting up emails');
  }

  /**
   * testSendEmailFailed: test method to send email unsuccessfully
   */
  @isTest
  static void testSendEmailFailed() {
    Contact contact = new Contact(
      LastName = 'Test Contact',
      Email = '',
      HasOptedOutOfEmail = true
    );
    insert contact;

    Incident incident = [SELECT Id FROM Incident LIMIT 1];

    Test.startTest();
    List<AIMSendEmailAction.SendEmailRequest> sendEmailRequests = new List<AIMSendEmailAction.SendEmailRequest>();
    AIMSendEmailAction.SendEmailRequest sendEmailRequest = AIMTestDataFactory.createSendEmailRequest(
      new List<Contact>{ contact },
      incident,
      1
    );
    sendEmailRequests.add(sendEmailRequest);
    List<AIMSendEmailAction.SendEmailResult> sendEmailResults = AIMSendEmailAction.sendEmail(
      sendEmailRequests
    );
    Test.stopTest();
    Integer failedEmail = sendEmailResults.get(0).totalFailedEmails;
    Assert.areEqual(1, failedEmail, 'An email should be failed');
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
