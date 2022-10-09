/*
 *  @description Test Class for  SimilarIncidentsDetectorAction
 */
@isTest
public class SimilarIncidentsDetectorActionTest {
  @testSetup
  static void populateData() {
    List<Account> accounts = new List<Account>();
    List<Contact> contacts = new List<Contact>();
    List<Case> cases = new List<Case>();
    List<Asset> assets = new List<Asset>();
    List<Product2> products = new List<Product2>();
    List<Incident> incidents = new List<Incident>();
    List<IncidentRelatedItem> incidentRelatedItems = new List<IncidentRelatedItem>();
    List<CaseRelatedIssue> caseRelatedIssues = new List<CaseRelatedIssue>();

    for (Integer counter = 0; counter < 20; counter++) {
      Account account = new Account(Name = 'Test Account ' + counter);
      accounts.add(account);
    }
    insert accounts;

    for (Integer counter = 0; counter < 20; counter++) {
      Contact contact = new Contact(
        LastName = 'Test Contact ' + counter,
        AccountId = accounts.get(Math.mod(counter, 20)).Id
      );
      contacts.add(contact);
    }
    insert contacts;

    for (Integer counter = 0; counter < 10; counter++) {
      Case caseRecord = new Case(
        Subject = 'Test Case ' + counter,
        Status = 'New',
        ContactId = contacts.get(counter).Id,
        AccountId = contacts.get(counter).AccountId
      );
      cases.add(caseRecord);
    }

    insert cases;

    for (Integer counter = 0; counter < 10; counter++) {
      Product2 product = new Product2(Name = 'Test Product ' + counter);
      products.add(product);
    }
    insert products;

    for (Integer counter = 0; counter < 10; counter++) {
      Contact contact = contacts.get(counter);
      Asset asset = new Asset(
        Name = 'Test Asset ' + counter,
        ContactId = contact.Id,
        AccountId = contact.AccountId,
        Product2Id = products.get(counter).Id
      );
      assets.add(asset);
    }
    Asset asset_10 = new Asset(
      Name = 'Test Asset 10',
      ContactId = contacts.get(10).Id,
      AccountId = contacts.get(10).AccountId,
      Latitude = 37.7749295,
      Longitude = 77.22496,
      Product2Id = products.get(6).Id
    );
    assets.add(asset_10);
    Asset asset_11 = new Asset(
      Name = 'Test Asset 11',
      ContactId = contacts.get(11).Id,
      AccountId = contacts.get(11).AccountId,
      Latitude = 38.7749295,
      Longitude = 80.22496,
      Product2Id = products.get(7).Id
    );
    assets.add(asset_11);
    Asset asset_12 = new Asset(
      Name = 'Test Asset 12',
      ContactId = contacts.get(12).Id,
      AccountId = contacts.get(12).AccountId,
      Latitude = 43.7749295,
      Longitude = -122.22496,
      Product2Id = products.get(8).Id
    );
    assets.add(asset_12);
    insert assets;

    for (Integer counter = 0; counter < 5; counter++) {
      Incident incident = new Incident(
        Subject = 'Test Incident ' + counter,
        Impact = 'High',
        Urgency = 'High',
        Priority = 'Critical',
        Category = 'C' + counter,
        SubCategory = 'S' + counter,
        Type = 'T' + counter
      );
      incidents.add(incident);
    }
    for (Integer counter = 5; counter < 8; counter++) {
      Incident incident = new Incident(
        Subject = 'Test Incident ' + counter,
        Impact = 'High',
        Urgency = 'High',
        Priority = 'Critical',
        Category = 'C0',
        SubCategory = 'S0',
        Type = 'T0'
      );
      incidents.add(incident);
    }
    for (Integer counter = 8; counter < 10; counter++) {
      Incident incident = new Incident(
        Subject = 'Test Incident ' + counter,
        Impact = 'High',
        Urgency = 'High',
        Priority = 'Critical',
        Category = 'C' + counter,
        SubCategory = 'S' + counter,
        Type = 'T' + counter
      );
      incidents.add(incident);
    }
    insert incidents;
    IncidentRelatedItem incidentRelatedItem_1 = new IncidentRelatedItem(
      IncidentId = incidents.get(7).Id,
      AssetId = asset_10.Id,
      ImpactType = '	Partially Business-Blocking'
    );
    incidentRelatedItems.add(incidentRelatedItem_1);

    IncidentRelatedItem incidentRelatedItem_2 = new IncidentRelatedItem(
      IncidentId = incidents.get(8).Id,
      AssetId = asset_11.Id,
      ImpactType = '	Partially Business-Blocking'
    );
    incidentRelatedItems.add(incidentRelatedItem_2);
    IncidentRelatedItem incidentRelatedItem_3 = new IncidentRelatedItem(
      IncidentId = incidents.get(9).Id,
      AssetId = asset_12.Id,
      ImpactType = '	Partially Business-Blocking'
    );
    incidentRelatedItems.add(incidentRelatedItem_3);

    //  incident with 3 cases
    for (Integer counter = 0; counter < 3; counter++) {
      CaseRelatedIssue caseRelatedIssue = new CaseRelatedIssue(
        RelatedIssueId = incidents.get(0).Id,
        CaseId = cases.get(counter).Id,
        RelationshipType = 'Similar'
      );
      caseRelatedIssues.add(caseRelatedIssue);

      IncidentRelatedItem incidentRelatedItem = new IncidentRelatedItem(
        IncidentId = incidents.get(0).Id,
        AssetId = assets.get(counter).Id,
        ImpactType = '	Partially Business-Blocking'
      );
      incidentRelatedItems.add(incidentRelatedItem);
    }

    for (Integer counter = 1; counter <= 3; counter++) {
      CaseRelatedIssue caseRelatedIssue = new CaseRelatedIssue(
        RelatedIssueId = incidents.get(counter).Id,
        CaseId = cases.get(0).Id,
        RelationshipType = 'Similar'
      );
      caseRelatedIssues.add(caseRelatedIssue);
      IncidentRelatedItem incidentRelatedItem = new IncidentRelatedItem(
        IncidentId = incidents.get(counter).Id,
        AssetId = assets.get(1).Id,
        ImpactType = '	Partially Business-Blocking'
      );
      incidentRelatedItems.add(incidentRelatedItem);
    }

    for (Integer counter = 4; counter <= 6; counter++) {
      CaseRelatedIssue caseRelatedIssue = new CaseRelatedIssue(
        RelatedIssueId = incidents.get(counter).Id,
        CaseId = cases.get(counter).Id,
        RelationshipType = 'Similar'
      );
      caseRelatedIssues.add(caseRelatedIssue);

      IncidentRelatedItem incidentRelatedItem = new IncidentRelatedItem(
        IncidentId = incidents.get(counter).Id,
        AssetId = assets.get(counter).Id,
        ImpactType = '	Partially Business-Blocking'
      );
      incidentRelatedItems.add(incidentRelatedItem);
    }

    CaseRelatedIssue caseRelatedIssue = new CaseRelatedIssue(
      RelatedIssueId = incidents.get(7).Id,
      CaseId = cases.get(1).Id,
      RelationshipType = 'Similar'
    );
    caseRelatedIssues.add(caseRelatedIssue);

    IncidentRelatedItem incidentRelatedItem_4 = new IncidentRelatedItem(
      IncidentId = incidents.get(9).Id,
      AssetId = assets.get(2).Id,
      ImpactType = '	Partially Business-Blocking'
    );
    incidentRelatedItems.add(incidentRelatedItem_4);
    insert caseRelatedIssues;
    insert incidentRelatedItems;
  }

  /**
   * @description get similar Incidents based on Attributes match , Assets match and
   * Product match
   */
  @isTest
  static void getSimilarIncidentsMatchedOnAttributes_Assets_ProductsTest() {
    List<Incident> incidents = [
      SELECT Id, Subject
      FROM Incident
      WHERE Subject = 'Test Incident 0'
    ];

    SimilarIncidentsDetectorAction.FlowInput apexActionInput = new SimilarIncidentsDetectorAction.FlowInput();
    apexActionInput.incidentId = incidents.get(0).Id;
    apexActionInput.isProductMatchEnabled = true;
    apexActionInput.isAssetMatchEnabled = true;
    apexActionInput.isAttributesMatchEnabled = true;
    List<SimilarIncidentsDetectorAction.FlowInput> flowInputs = new List<SimilarIncidentsDetectorAction.FlowInput>();
    flowInputs.add(apexActionInput);
    Test.startTest();
    List<List<Id>> output = SimilarIncidentsDetectorAction.findSimilarIncidents(
      flowInputs
    );
    Test.stopTest();
    System.AssertEquals(7, output.get(0).size());
  }
  /**
   * @description get similar Incidents based on Asset Proximity Match
   */
  @isTest
  static void getSimilarIncidentsMatchedOnAssetProximityTest() {
    List<Incident> incidents = [
      SELECT Id, Subject
      FROM Incident
      WHERE Subject = 'Test Incident 7'
    ];

    SimilarIncidentsDetectorAction.FlowInput apexActionInput = new SimilarIncidentsDetectorAction.FlowInput();
    apexActionInput.incidentId = incidents.get(0).Id;
    apexActionInput.assetProximityDistance = 500;
    List<SimilarIncidentsDetectorAction.FlowInput> flowInputs = new List<SimilarIncidentsDetectorAction.FlowInput>();
    flowInputs.add(apexActionInput);
    Test.startTest();
    List<List<Id>> output = SimilarIncidentsDetectorAction.findSimilarIncidents(
      flowInputs
    );
    Test.stopTest();
    System.AssertEquals(1, output.get(0).size());
  }

  /**
   * @description get similar Incidents based on Cases match
   */
  @isTest
  static void getSimilarIncidentsMatchedOnCasesTest() {
    List<Incident> incidents = [
      SELECT Id, Subject
      FROM Incident
      WHERE Subject = 'Test Incident 3'
    ];

    SimilarIncidentsDetectorAction.FlowInput apexActionInput = new SimilarIncidentsDetectorAction.FlowInput();
    apexActionInput.incidentId = incidents.get(0).Id;
    apexActionInput.isCaseMatchEnabled = true;
    List<SimilarIncidentsDetectorAction.FlowInput> flowInputs = new List<SimilarIncidentsDetectorAction.FlowInput>();
    flowInputs.add(apexActionInput);
    Test.startTest();
    List<List<Id>> output = SimilarIncidentsDetectorAction.findSimilarIncidents(
      flowInputs
    );
    Test.stopTest();
    System.AssertEquals(3, output.get(0).size());
  }

  /**
   * @description Incident with no similar incidents
   */
  @isTest
  static void noSimilarIncidentsTest() {
    SimilarIncidentsDetectorAction.FlowInput apexActionInput = new SimilarIncidentsDetectorAction.FlowInput();
    apexActionInput.incidentId = [
      SELECT Id, Subject
      FROM Incident
      WHERE Subject = 'Test Incident 8'
    ]
    .Id;
    apexActionInput.isProductMatchEnabled = true;
    apexActionInput.isAssetMatchEnabled = true;
    apexActionInput.isCaseMatchEnabled = true;
    apexActionInput.isAttributesMatchEnabled = true;
    apexActionInput.assetProximityDistance = 2;
    List<SimilarIncidentsDetectorAction.FlowInput> flowInputs = new List<SimilarIncidentsDetectorAction.FlowInput>();
    flowInputs.add(apexActionInput);
    Test.startTest();
    List<List<Id>> output = SimilarIncidentsDetectorAction.findSimilarIncidents(
      flowInputs
    );
    Test.stopTest();
    System.AssertEquals(0, output.get(0).size());
  }

  /**
   * @description Invalid inputs test passing nulls
   */

  @isTest
  static void invalidInputsTest() {
    Boolean exceptionOccurred = false;
    List<SimilarIncidentsDetectorAction.FlowInput> flowInputs = new List<SimilarIncidentsDetectorAction.FlowInput>();
    flowInputs.add(null);
    Test.startTest();
    try {
      SimilarIncidentsDetectorAction.findSimilarIncidents(flowInputs);
    } catch (AIMBaseException.AIMInvalidInputException e) {
      exceptionOccurred = true;
    }

    try {
      SimilarIncidentsDetectorAction.findSimilarIncidents(null);
    } catch (AIMBaseException.AIMInvalidInputException e) {
      exceptionOccurred = true;
    }
    Test.stopTest();
    System.assert(exceptionOccurred, 'An Exception was not thrown');
  }
}
