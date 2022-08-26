/**
 *  @description Test Class for RetrieveImpactedAccountsAndContacts Flow
 *  @author      Srinath Sethumadhavan, Sbe Saffron.
 *  @date        08/26/2022
 */
@isTest
public class RetrieveImpactedAccountsAndContactsTest {
  @testSetup
  public static void populateData() {
    List<Account> accounts = new List<Account>();
    List<Contact> contacts = new List<Contact>();
    List<Contact> contactsWithAccount = new List<Contact>();
    List<Case> casesWithAccount = new List<Case>();
    List<Case> casesWithContact = new List<Case>();
    List<Case> casesWithSameContact = new List<Case>();
    List<Case> caseswithContactAndAccount = new List<Case>();
    List<Case> caseswithNoContactAndNoAccount = new List<Case>();
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
    insert contacts;

    for (Integer counter = 10; counter < 20; counter++) {
      Contact contact = new Contact(
        LastName = 'Test Contact ' + counter,
        AccountId = accounts.get(Math.mod(counter, 10)).Id
      );
      contactsWithAccount.add(contact);
    }
    insert contactsWithAccount;

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

    //cases with only contact
    for (Integer counter = 0; counter < 5; counter++) {
      Case caseRecord = new Case(
        Subject = 'Test Case ' + counter,
        Status = 'New',
        ContactId = contacts.get(counter).Id
      );
      casesWithContact.add(caseRecord);
    }

    //cases with only account
    for (Integer counter = 0; counter < 5; counter++) {
      Case caseRecord = new Case(
        Subject = 'Test Case ' + counter,
        Status = 'New',
        AccountId = accounts.get(counter).Id
      );
      casesWithAccount.add(caseRecord);
    }

    //cases with no account and no contact
    for (Integer counter = 0; counter < 5; counter++) {
      Case caseRecord = new Case(
        Subject = 'Test Case ' + counter,
        Status = 'New'
      );
      caseswithNoContactAndNoAccount.add(caseRecord);
    }

    insert casesWithAccount;
    insert casesWithContact;
    insert caseswithContactAndAccount;
    insert caseswithNoContactAndNoAccount;

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

    insert assetsWithAccount;
    insert assetswithContactAndAccount;

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

  @isTest
  public static void getImpactedAccountsAndContactsTest() {
    List<Incident> incidents;
    Map<String, Object> params = new Map<String, Object>();
    Flow.Interview.Retrieve_Impacted_Accounts_and_Contacts_Flow flowRunner;
    List<Id> contactIds;
    List<Id> AccountIds;

    // case 1 - Incident with only cases

    incidents = [SELECT Id FROM Incident WHERE Subject = 'Test Incident 0'];

    params.put('IncidentId', incidents.get(0).Id);
    flowRunner = new Flow.Interview.Retrieve_Impacted_Accounts_and_Contacts_Flow(
      params
    );

    flowRunner.start();

    contactIds = (List<Id>) flowRunner.getVariableValue('ContactIdList');
    AccountIds = (List<Id>) flowRunner.getVariableValue('AccountIdList');

    System.assertEquals(2, contactIds.size());
    System.assertEquals(2, AccountIds.size());

    // case 2 - Incident with only assets

    incidents = [SELECT Id FROM Incident WHERE Subject = 'Test Incident 1'];
    params.put('IncidentId', incidents.get(0).Id);
    flowRunner = new Flow.Interview.Retrieve_Impacted_Accounts_and_Contacts_Flow(
      params
    );

    flowRunner.start();

    contactIds = (List<Id>) flowRunner.getVariableValue('ContactIdList');
    AccountIds = (List<Id>) flowRunner.getVariableValue('AccountIdList');

    System.assertEquals(2, contactIds.size());
    System.assertEquals(4, AccountIds.size());

    // case 3 Incident with both cases and assets

    incidents = [SELECT Id FROM Incident WHERE Subject = 'Test Incident 2'];

    params.put('IncidentId', incidents.get(0).Id);
    flowRunner = new Flow.Interview.Retrieve_Impacted_Accounts_and_Contacts_Flow(
      params
    );

    flowRunner.start();

    contactIds = (List<Id>) flowRunner.getVariableValue('ContactIdList');
    AccountIds = (List<Id>) flowRunner.getVariableValue('AccountIdList');

    System.assertEquals(3, contactIds.size());
    System.assertEquals(4, AccountIds.size());

    // case 4 Incident with no cases and no assets

    incidents = [SELECT Id FROM Incident WHERE Subject = 'Test Incident 3'];

    params.put('IncidentId', incidents.get(0).Id);
    flowRunner = new Flow.Interview.Retrieve_Impacted_Accounts_and_Contacts_Flow(
      params
    );

    flowRunner.start();

    contactIds = (List<Id>) flowRunner.getVariableValue('ContactIdList');
    AccountIds = (List<Id>) flowRunner.getVariableValue('AccountIdList');

    System.assertEquals(null, contactIds);
    System.assertEquals(null, AccountIds);

    // case 5 incident with  relatedcases that has no contact or account

    incidents = [SELECT Id FROM Incident WHERE Subject = 'Test Incident 4'];

    params.put('IncidentId', incidents.get(0).Id);
    flowRunner = new Flow.Interview.Retrieve_Impacted_Accounts_and_Contacts_Flow(
      params
    );

    flowRunner.start();

    contactIds = (List<Id>) flowRunner.getVariableValue('ContactIdList');
    AccountIds = (List<Id>) flowRunner.getVariableValue('AccountIdList');

    System.assertEquals(null, contactIds);
    System.assertEquals(null, AccountIds);

    //  case 6 incident with relatedAsset that has only account

    incidents = [SELECT Id FROM Incident WHERE Subject = 'Test Incident 5'];

    params.put('IncidentId', incidents.get(0).Id);
    flowRunner = new Flow.Interview.Retrieve_Impacted_Accounts_and_Contacts_Flow(
      params
    );

    flowRunner.start();

    contactIds = (List<Id>) flowRunner.getVariableValue('ContactIdList');
    AccountIds = (List<Id>) flowRunner.getVariableValue('AccountIdList');

    System.assertEquals(null, contactIds);
    System.assertEquals(1, AccountIds.size());

    // case 7 incident with duplicate contacts

    incidents = [SELECT Id FROM Incident WHERE Subject = 'Test Incident 6'];

    params.put('IncidentId', incidents.get(0).Id);
    flowRunner = new Flow.Interview.Retrieve_Impacted_Accounts_and_Contacts_Flow(
      params
    );

    flowRunner.start();

    contactIds = (List<Id>) flowRunner.getVariableValue('ContactIdList');

    System.assertEquals(2, contactIds.size()); // duplicate contacts Assertion
  }
}
