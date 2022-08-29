/*
 *  @description Test Class for RetrieveImpactedAccountsAndContacts Flow
 */
@isTest
public class RetrieveImpactedAccountsAndContactsTest {
  @testSetup
  public static void populateData() {
    List<Account> accounts = new List<Account>();

    List<Contact> allContacts = new List<contact>();
    List<Contact> contacts = new List<Contact>();
    List<Contact> contactsWithAccount = new List<Contact>();

    List<Case> allCases = new List<Case>();
    List<Case> casesWithAccount = new List<Case>();
    List<Case> casesWithContact = new List<Case>();
    List<Case> casesWithSameContact = new List<Case>();
    List<Case> caseswithContactAndAccount = new List<Case>();
    List<Case> caseswithNoContactAndNoAccount = new List<Case>();

    List<Asset> allAssets = new List<Asset>();
    List<Asset> assetsWithAccount = new List<Asset>();
    List<Asset> assetswithContactAndAccount = new List<Asset>();

    List<Incident> incidents = new List<Incident>();

    List<IncidentRelatedItem> incidentRelatedItems = new List<IncidentRelatedItem>();

    List<CaseRelatedIssue> caseRelatedIssues = new List<CaseRelatedIssue>();

    for (Integer counter = 0; counter < 20; counter++) {
      Account account = new Account(Name = 'Test Account ' + counter);
      accounts.add(account);
    }
    insert accounts;

    for (Integer counter = 0; counter < 10; counter++) {
      Contact contact = new Contact(LastName = 'Test Contact ' + counter);
      contacts.add(contact);
    }
    allContacts.addAll(contacts);

    for (Integer counter = 10; counter < 20; counter++) {
      Contact contact = new Contact(
        LastName = 'Test Contact ' + counter,
        AccountId = accounts.get(Math.mod(counter, 10)).Id
      );
      contactsWithAccount.add(contact);
    }
    allContacts.addAll(contactsWithAccount);

    insert allContacts;

    // cases with both account and contact
    for (Integer counter = 0; counter < 5; counter++) {
      Case caseRecord = new Case(
        Subject = 'Test Case ' + counter,
        Status = 'New',
        ContactId = contactsWithAccount.get(counter).Id,
        AccountId = contactsWithAccount.get(counter).AccountId
      );
      caseswithContactAndAccount.add(caseRecord);
    }

    allCases.addAll(caseswithContactAndAccount);

    //cases with only contact
    for (Integer counter = 0; counter < 5; counter++) {
      Case caseRecord = new Case(
        Subject = 'Test Case ' + counter,
        Status = 'New',
        ContactId = contacts.get(counter).Id
      );
      casesWithContact.add(caseRecord);
    }

    allCases.addAll(casesWithContact);
    //cases with only account
    for (Integer counter = 0; counter < 5; counter++) {
      Case caseRecord = new Case(
        Subject = 'Test Case ' + counter,
        Status = 'New',
        AccountId = accounts.get(counter).Id
      );
      casesWithAccount.add(caseRecord);
    }

    allCases.addAll(casesWithAccount);

    //cases with no account and no contact
    for (Integer counter = 0; counter < 5; counter++) {
      Case caseRecord = new Case(
        Subject = 'Test Case ' + counter,
        Status = 'New'
      );
      caseswithNoContactAndNoAccount.add(caseRecord);
    }

    allCases.addAll(caseswithNoContactAndNoAccount);

    insert allCases;

    //  asset with only account
    for (Integer counter = 0; counter < 5; counter++) {
      Account account = accounts.get(counter);
      Asset asset = new Asset(
        Name = 'Test Asset ' + counter,
        AccountId = account.Id,
        Latitude = 37 + Math.random(),
        Longitude = 122 + Math.random()
      );
      assetsWithAccount.add(asset);
    }

    allAssets.addAll(assetsWithAccount);

    //assets with both contacts and account
    for (Integer counter = 0; counter < 5; counter++) {
      Contact contact = contactsWithAccount.get(counter);
      Asset asset = new Asset(
        Name = 'Test Asset ' + counter,
        ContactId = contact.Id,
        AccountId = contact.AccountId,
        Latitude = 37 + Math.random(),
        Longitude = 122 + Math.random()
      );
      assetswithContactAndAccount.add(asset);
    }

    allAssets.addAll(assetswithContactAndAccount);

    insert allAssets;

    //insert incidents
    for (Integer counter = 0; counter < 7; counter++) {
      Incident incident = new Incident(
        Subject = 'Test Incident ' + counter,
        Impact = 'High',
        Urgency = 'High',
        Priority = 'Critical'
      );
      incidents.add(incident);
    }
    insert incidents;

    // incident with only related cases

    CaseRelatedIssue caseRelatedIssue_1 = new CaseRelatedIssue(
      RelatedIssueId = incidents.get(0).Id,
      CaseId = casesWithAccount.get(0).Id,
      RelationshipType = 'Similar'
    );
    CaseRelatedIssue caseRelatedIssue_2 = new CaseRelatedIssue(
      RelatedIssueId = incidents.get(0).Id,
      CaseId = casesWithContact.get(0).Id,
      RelationshipType = 'Similar'
    );
    CaseRelatedIssue caseRelatedIssue_3 = new CaseRelatedIssue(
      RelatedIssueId = incidents.get(0).Id,
      CaseId = caseswithContactAndAccount.get(0).Id,
      RelationshipType = 'Similar'
    );
    CaseRelatedIssue caseRelatedIssue_4 = new CaseRelatedIssue(
      RelatedIssueId = incidents.get(0).Id,
      CaseId = caseswithNoContactAndNoAccount.get(0).Id,
      RelationshipType = 'Similar'
    );

    caseRelatedIssues.add(caseRelatedIssue_1);
    caseRelatedIssues.add(caseRelatedIssue_2);
    caseRelatedIssues.add(caseRelatedIssue_3);
    caseRelatedIssues.add(caseRelatedIssue_4);

    // incident with only related assets
    for (integer counter = 0; counter < 2; counter++) {
      IncidentRelatedItem incidentRelatedItem_1 = new IncidentRelatedItem(
        IncidentId = incidents.get(1).Id,
        AssetId = assetsWithAccount.get(counter).Id,
        ImpactType = '	Partially Business-Blocking'
      );
      IncidentRelatedItem incidentRelatedItem_2 = new IncidentRelatedItem(
        IncidentId = incidents.get(1).Id,
        AssetId = assetswithContactAndAccount.get(counter).Id,
        ImpactType = '	Partially Business-Blocking'
      );
      incidentRelatedItems.add(incidentRelatedItem_1);
      incidentRelatedItems.add(incidentRelatedItem_2);
    }

    // incident with both relatedcases and related assets

    CaseRelatedIssue caseRelatedIssue_5 = new CaseRelatedIssue(
      RelatedIssueId = incidents.get(2).Id,
      CaseId = caseswithContactAndAccount.get(1).Id,
      RelationshipType = 'Similar'
    );
    caseRelatedIssues.add(caseRelatedIssue_5);

    CaseRelatedIssue caseRelatedIssue_6 = new CaseRelatedIssue(
      RelatedIssueId = incidents.get(2).Id,
      CaseId = caseswithAccount.get(2).Id,
      RelationshipType = 'Similar'
    );
    caseRelatedIssues.add(caseRelatedIssue_6);
    CaseRelatedIssue caseRelatedIssue_7 = new CaseRelatedIssue(
      RelatedIssueId = incidents.get(2).Id,
      CaseId = caseswithContact.get(2).Id,
      RelationshipType = 'Similar'
    );
    caseRelatedIssues.add(caseRelatedIssue_7);

    IncidentRelatedItem incidentRelatedItem_3 = new IncidentRelatedItem(
      IncidentId = incidents.get(2).Id,
      AssetId = assetswithContactAndAccount.get(3).Id,
      ImpactType = '	Partially Business-Blocking'
    );
    incidentRelatedItems.add(incidentRelatedItem_3);

    IncidentRelatedItem incidentRelatedItem_4 = new IncidentRelatedItem(
      IncidentId = incidents.get(2).Id,
      AssetId = assetswithAccount.get(3).Id,
      ImpactType = '	Partially Business-Blocking'
    );
    incidentRelatedItems.add(incidentRelatedItem_4);

    // incident with  relatedcases that has no contact or account
    CaseRelatedIssue caseRelatedIssue_8 = new CaseRelatedIssue(
      RelatedIssueId = incidents.get(4).Id,
      CaseId = caseswithNoContactAndNoAccount.get(1).Id,
      RelationshipType = 'Similar'
    );
    caseRelatedIssues.add(caseRelatedIssue_8);

    // incident with relatedAsset that has only account
    IncidentRelatedItem incidentRelatedItem_5 = new IncidentRelatedItem(
      IncidentId = incidents.get(5).Id,
      AssetId = assetswithAccount.get(4).Id,
      ImpactType = '	Partially Business-Blocking'
    );
    incidentRelatedItems.add(incidentRelatedItem_5);

    // incident with duplicate contacts

    for (Integer counter = 0; counter < 2; counter++) {
      Case caseRecord = new Case(
        Subject = 'Test Case ' + counter,
        Status = 'New',
        ContactId = contacts.get(0).Id
      );
      casesWithSameContact.add(caseRecord);
    }
    insert casesWithSameContact;

    CaseRelatedIssue caseRelatedIssue_9 = new CaseRelatedIssue(
      RelatedIssueId = incidents.get(6).Id,
      CaseId = casesWithSameContact.get(0).Id,
      RelationshipType = 'Similar'
    );

    caseRelatedIssues.add(caseRelatedIssue_9);
    CaseRelatedIssue caseRelatedIssue_10 = new CaseRelatedIssue(
      RelatedIssueId = incidents.get(6).Id,
      CaseId = casesWithSameContact.get(1).Id,
      RelationshipType = 'Similar'
    );

    caseRelatedIssues.add(caseRelatedIssue_10);

    insert caseRelatedIssues;

    insert incidentRelatedItems;
  }

  // case 1 - Incident with only cases
  @isTest
  public static void getImpactedAccountsAndContactsTest_1() {
    List<Incident> incidents = [
      SELECT Id
      FROM Incident
      WHERE Subject = 'Test Incident 0'
    ];

    List<List<Id>> outputList = executeAutolaunchedFlow(incidents.get(0).Id);
    System.assertEquals(2, outputList.get(0).size());
    System.assertEquals(2, outputList.get(1).size());
  }

  // case 2 - Incident with only assets
  @isTest
  public static void getImpactedAccountsAndContactsTest_2() {
    List<Incident> incidents = [
      SELECT Id
      FROM Incident
      WHERE Subject = 'Test Incident 1'
    ];

    List<List<Id>> outputList = executeAutolaunchedFlow(incidents.get(0).Id);

    System.assertEquals(2, outputList.get(0).size());
    System.assertEquals(4, outputList.get(1).size());
  }

  // case 3 Incident with both cases and assets
  @isTest
  public static void getImpactedAccountsAndContactsTest_3() {
    List<Incident> incidents = [
      SELECT Id
      FROM Incident
      WHERE Subject = 'Test Incident 2'
    ];
    List<List<Id>> outputList = executeAutolaunchedFlow(incidents.get(0).Id);

    System.assertEquals(3, outputList.get(0).size());
    System.assertEquals(4, outputList.get(1).size());
  }

  // case 4 Incident with no cases and no assets
  @isTest
  public static void getImpactedAccountsAndContactsTest_4() {
    List<Incident> incidents = [
      SELECT Id
      FROM Incident
      WHERE Subject = 'Test Incident 3'
    ];

    List<List<Id>> outputList = executeAutolaunchedFlow(incidents.get(0).Id);
    System.assertEquals(null, outputList.get(0));
    System.assertEquals(null, outputList.get(1));
  }

  // case 5 incident with  relatedcases that has no contact or account
  @isTest
  public static void getImpactedAccountsAndContactsTest_5() {
    List<Incident> incidents = [
      SELECT Id
      FROM Incident
      WHERE Subject = 'Test Incident 4'
    ];

    List<List<Id>> outputList = executeAutolaunchedFlow(incidents.get(0).Id);
    System.assertEquals(null, outputList.get(0));
    System.assertEquals(null, outputList.get(1));
  }

  //  case 6 incident with relatedAsset that has only account
  @isTest
  public static void getImpactedAccountsAndContactsTest_6() {
    List<Incident> incidents = [
      SELECT Id
      FROM Incident
      WHERE Subject = 'Test Incident 5'
    ];

    List<List<Id>> outputList = executeAutolaunchedFlow(incidents.get(0).Id);

    System.assertEquals(null, outputList.get(0));
    System.assertEquals(1, outputList.get(1).size());
  }

  // case 7 incident with duplicate contacts
  @isTest
  public static void getImpactedAccountsAndContactsTest_7() {
    List<Incident> incidents = [
      SELECT Id
      FROM Incident
      WHERE Subject = 'Test Incident 6'
    ];

    List<List<Id>> outputList = executeAutolaunchedFlow(incidents.get(0).Id);

    System.assertEquals(2, outputList.get(0).size()); // duplicate contacts Assertion
  }

  private static List<List<Id>> executeAutolaunchedFlow(Id incidentId) {
    Map<String, Object> params = new Map<String, Object>();
    List<List<Id>> outputList = new List<List<Id>>();

    params.put('IncidentId', incidentId);
    Flow.Interview.Retrieve_Impacted_Accounts_and_Contacts_Flow flowRunner = new Flow.Interview.Retrieve_Impacted_Accounts_and_Contacts_Flow(
      params
    );

    flowRunner.start();

    List<Id> contactIds = (List<Id>) flowRunner.getVariableValue(
      'ContactIdList'
    );
    List<Id> AccountIds = (List<Id>) flowRunner.getVariableValue(
      'AccountIdList'
    );

    outputList.add(contactIds);
    outputList.add(AccountIds);

    return outputList;
  }
}
