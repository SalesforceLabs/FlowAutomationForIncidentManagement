/*
 *  @description Test Class for  RelatedIncidentDetectorAction
 */
@isTest
private with sharing class RelatedIncidentDetectorActionTest {
  @testSetup
  static void populateData() {
    List<Account> accounts = AIMTestDataFactory.createAccounts(10);
    List<Contact> contacts = AIMTestDataFactory.createContacts(10, accounts);
    List<Product2> products = AIMTestDataFactory.createProducts(10);
    List<Asset> assets = AIMTestDataFactory.createAssets(5, products, contacts);
    List<Case> cases = new List<Case>();

    List<Incident> incidents = AIMTestDataFactory.createIncidents(10);
    List<IncidentRelatedItem> incidentRelatedItems = new List<IncidentRelatedItem>();
    List<CaseRelatedIssue> caseRelatedIssues = new List<CaseRelatedIssue>();

    // asset without product
    Asset asset_5 = new Asset(
      Name = 'Test Asset 5',
      ContactId = contacts.get(2).Id,
      AccountId = contacts.get(2).AccountId,
      Latitude = 37.7749295,
      Longitude = 77.22496
    );
    assets.add(asset_5);

    // asset with product and lat/long
    Asset asset_6 = new Asset(
      Name = 'Test Asset 6',
      ContactId = contacts.get(3).Id,
      AccountId = contacts.get(3).AccountId,
      Latitude = 38.7749295,
      Longitude = 80.22496,
      product2Id = products.get(4).Id
    );
    assets.add(asset_6);

    Asset asset_7 = new Asset(
      Name = 'Test Asset 7',
      ContactId = contacts.get(4).Id,
      AccountId = contacts.get(4).AccountId,
      Latitude = 43.7749295,
      Longitude = -122.22496
    );
    assets.add(asset_7);

    Asset asset_8 = new Asset(
      Name = 'Test Asset 8',
      ContactId = contacts.get(3).Id,
      AccountId = contacts.get(3).AccountId,
      product2Id = products.get(4).Id
    );
    assets.add(asset_8);

    Asset asset_9 = new Asset(
      Name = 'Test Asset 9',
      ContactId = contacts.get(3).Id,
      AccountId = contacts.get(3).AccountId,
      product2Id = products.get(5).Id
    );
    assets.add(asset_9);

    Asset asset_10 = new Asset(
      Name = 'Test Asset 10',
      ContactId = contacts.get(3).Id,
      AccountId = contacts.get(3).AccountId,
      product2Id = products.get(5).Id
    );
    assets.add(asset_10);
    insert assets;

    Case caseRecord_5 = new Case(
      Subject = 'Test Case 5',
      Status = 'New',
      ContactId = contacts.get(0).Id,
      AccountId = contacts.get(0).AccountId,
      AssetId = asset_5.Id
    );
    cases.add(caseRecord_5);

    // case without asset
    Case caseRecord_6 = new Case(
      Subject = 'Test Case 6',
      Status = 'New',
      ContactId = contacts.get(1).Id,
      AccountId = contacts.get(1).AccountId
    );
    cases.add(caseRecord_6);

    // case with asset and asset with product and lat/long
    Case caseRecord_7 = new Case(
      Subject = 'Test Case 7',
      Status = 'New',
      ContactId = contacts.get(1).Id,
      AccountId = contacts.get(1).AccountId,
      AssetId = asset_6.Id
    );
    cases.add(caseRecord_7);
    Case caseRecord_8 = new Case(
      Subject = 'Test Case 8',
      Status = 'New',
      ContactId = contacts.get(1).Id,
      AccountId = contacts.get(1).AccountId,
      AssetId = asset_10.Id
    );
    cases.add(caseRecord_8);
    insert cases;
    cases.addAll(AIMTestDataFactory.createCases(5, contacts, null, assets));

    IncidentRelatedItem incidentRelatedItem_1 = new IncidentRelatedItem(
      IncidentId = incidents.get(0).Id,
      AssetId = assets.get(0).Id,
      ImpactType = '	Partially Business-Blocking'
    );
    incidentRelatedItems.add(incidentRelatedItem_1);

    IncidentRelatedItem incidentRelatedItem_2 = new IncidentRelatedItem(
      IncidentId = incidents.get(4).Id,
      AssetId = asset_5.Id,
      ImpactType = '	Partially Business-Blocking'
    );
    incidentRelatedItems.add(incidentRelatedItem_2);

    IncidentRelatedItem incidentRelatedItem_3 = new IncidentRelatedItem(
      IncidentId = incidents.get(3).Id,
      AssetId = asset_8.Id,
      ImpactType = '	Partially Business-Blocking'
    );
    incidentRelatedItems.add(incidentRelatedItem_3);
    CaseRelatedIssue caseRelatedIssue_1 = new CaseRelatedIssue(
      RelatedIssueId = incidents.get(1).Id,
      CaseId = cases.get(5).Id,
      RelationshipType = 'Similar'
    );
    caseRelatedIssues.add(caseRelatedIssue_1);
    CaseRelatedIssue caseRelatedIssue_2 = new CaseRelatedIssue(
      RelatedIssueId = incidents.get(2).Id,
      CaseId = caseRecord_8.Id,
      RelationshipType = 'Similar'
    );
    caseRelatedIssues.add(caseRelatedIssue_2);
    insert caseRelatedIssues;
    insert incidentRelatedItems;
  }

  /*
   *  @description get the incident to which the case is already attached
   */
  @isTest
  static void caseAlreadyAttachedTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.caseOrAssetId = [
      SELECT Id
      FROM Case
      WHERE Subject = 'Test Case 1'
    ]
    .Id;
    List<Id> relatedIncident = runDetector(apexActionInput);
    System.assert(
      relatedIncident.contains(
        [SELECT Id FROM Incident WHERE Subject = 'Test Incident 1' LIMIT 1]
        .Id
      )
    );
  }

  /*
   *  @description get the incident to which the asset is already attached
   */
  @isTest
  static void assetAlreadyAttachedTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.caseOrAssetId = [
      SELECT Id
      FROM Asset
      WHERE Name = 'Test Asset 0'
    ]
    .Id;
    List<Id> relatedIncident = runDetector(apexActionInput);
    System.assert(
      relatedIncident.contains(
        [SELECT Id FROM Incident WHERE Subject = 'Test Incident 0' LIMIT 1]
        .Id
      )
    );
  }

  /*
   *  @description invalid inputs and null test
   */
  @isTest
  static void invalidInputsTest() {
    Boolean exceptionOccurred = false;
    try {
      runDetector(null);
    } catch (AIMBaseException.AIMInvalidInputException e) {
      exceptionOccurred = true;
    }
    System.assert(exceptionOccurred, 'An Exception was not thrown');
  }
  /*
   *  @description unsupported sObject recordID test
   */
  @isTest
  static void unsupportedSObjectRecordIDTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.caseOrAssetId = '001B000001MFadaIAD';
    Boolean exceptionOccurred = false;
    try {
      runDetector(apexActionInput);
    } catch (AIMBaseException.AIMInvalidInputException e) {
      exceptionOccurred = true;
    }
    System.assert(exceptionOccurred, 'An Exception was not thrown');
  }

  /*
   *  @description get related incident if it is present for a case without asset
   */
  @isTest
  static void caseWithoutAssetTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.caseOrAssetId = [
      SELECT Id
      FROM Case
      WHERE Subject = 'Test Case 6'
    ]
    .Id;
    apexActionInput.isProductMatchEnabled = true;
    apexActionInput.isAssetMatchEnabled = true;
    System.assertEquals(null, runDetector(apexActionInput).get(0));
  }

  /*
   *  @description get related incident if it is present for an asset without latitude and longitude
   */
  @isTest
  static void assetWithoutLatitudeLongitudeTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.assetProximityDistance = 2;
    apexActionInput.caseOrAssetId = [
      SELECT Id
      FROM Asset
      WHERE Name = 'Test Asset 1'
    ]
    .Id;
    System.assertEquals(null, runDetector(apexActionInput).get(0));
  }

  /*
   *  @description get related incident if it is present for an asset without product
   */
  @isTest
  static void assetWithoutProductTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.caseOrAssetId = [
      SELECT Id
      FROM Asset
      WHERE Name = 'Test Asset 5'
    ]
    .Id;
    apexActionInput.isProductMatchEnabled = true;
    apexActionInput.isAssetMatchEnabled = true;
    List<Id> relatedIncident = runDetector(apexActionInput);
    System.Assert(
      relatedIncident.contains(
        [SELECT Id FROM Incident WHERE Subject = 'Test Incident 4' LIMIT 1]
        .Id
      )
    );
  }

  /*
   *  @description get related incident if it is present for an asset with proximity distance match paramter greater than zero
   */
  @isTest
  static void assetWithProximityDistanceMatchTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.caseOrAssetId = [
      SELECT Id
      FROM Asset
      WHERE Name = 'Test Asset 7'
    ]
    .Id;
    apexActionInput.assetProximityDistance = 10;
    System.assertEquals(null, runDetector(apexActionInput).get(0));
  }

  /*
   *  @description get related incident if it is present for a case without product
   */
  @isTest
  static void caseWithoutProductTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.caseOrAssetId = [
      SELECT Id
      FROM Case
      WHERE Subject = 'Test Case 5'
    ]
    .Id;
    apexActionInput.isProductMatchEnabled = true;
    System.assertEquals(null, runDetector(apexActionInput).get(0));
  }

  /*
   *  @description get related incident if it is present for a case with asset
   */
  @isTest
  static void caseWithAssetTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.caseOrAssetId = [
      SELECT Id
      FROM Case
      WHERE Subject = 'Test Case 7'
    ]
    .Id;
    apexActionInput.isAssetMatchEnabled = true;
    apexActionInput.assetProximityDistance = 500;
    List<Id> relatedIncident = runDetector(apexActionInput);
    System.Assert(
      relatedIncident.contains(
        [SELECT Id FROM Incident WHERE Subject = 'Test Incident 4' LIMIT 1]
        .Id
      )
    );
  }

  /*
   *  @description get related incident if it is present for an asset with product
   */
  @isTest
  static void assetWithProductTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.caseOrAssetId = [
      SELECT Id
      FROM Asset
      WHERE Name = 'Test Asset 6'
    ]
    .Id;
    apexActionInput.isProductMatchEnabled = true;
    System.Assert(
      runDetector(apexActionInput)
        .contains(
          [SELECT Id FROM Incident WHERE Subject = 'Test Incident 3' LIMIT 1]
          .Id
        )
    );
  }

  /*
   *  @description get related incident if it is present for an asset matched on Case Related Issues
   */
  @isTest
  static void assetMatchedOnRelatedCasesTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.caseOrAssetId = [
      SELECT Id
      FROM Asset
      WHERE Name = 'Test Asset 9'
    ]
    .Id;
    apexActionInput.isProductMatchEnabled = true;
    System.Assert(
      runDetector(apexActionInput)
        .contains(
          [SELECT Id FROM Incident WHERE Subject = 'Test Incident 2' LIMIT 1]
          .Id
        )
    );
  }

  /*
   *  @description get related incident if it is present for an asset with asset match criteria enabled from Case Related Issues
   */
  @isTest
  static void assetWithMatchOnAssetEnabledTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.caseOrAssetId = [
      SELECT Id
      FROM Asset
      WHERE Name = 'Test Asset 9'
    ]
    .Id;
    apexActionInput.isAssetMatchEnabled = true;
    System.AssertEquals(null, runDetector(apexActionInput).get(0));
  }

  /*
   *  @description get related incident if it is present for a case matched on product from Incident Related Items
   */
  @isTest
  static void caseMatchedOnProductFromRelatedAssetsTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.caseOrAssetId = [
      SELECT Id
      FROM Case
      WHERE Subject = 'Test Case 0'
    ]
    .Id;
    apexActionInput.isProductMatchEnabled = true;
    System.Assert(
      runDetector(apexActionInput)
        .contains(
          [SELECT Id FROM Incident WHERE Subject = 'Test Incident 0' LIMIT 1]
          .Id
        )
    );
  }

  /*
   *  @description get related incident if it is present for a case matched on asset from Incident Related Items
   */
  @isTest
  static void caseMatchedOnAssetFromRelatedAssetsTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    apexActionInput.caseOrAssetId = [
      SELECT Id
      FROM Case
      WHERE Subject = 'Test Case 5'
    ]
    .Id;
    apexActionInput.isAssetMatchEnabled = true;
    System.Assert(
      runDetector(apexActionInput)
        .contains(
          [SELECT Id FROM Incident WHERE Subject = 'Test Incident 4' LIMIT 1]
          .Id
        )
    );
  }

  /**
   * @description executes the Related Incident Detector Apex action
   * @param apexActionInput (RelatedIncidentDetectorAction.FlowInput): Apex wrapper to receive flow inputs
   * @return List<Id>: list containing a single related Incident Id if present
   */
  static List<Id> runDetector(
    RelatedIncidentDetectorAction.FlowInput apexActionInput
  ) {
    List<RelatedIncidentDetectorAction.FlowInput> flowInputs = new List<RelatedIncidentDetectorAction.FlowInput>();
    flowInputs.add(apexActionInput);
    Test.startTest();
    List<Id> relatedIncident = RelatedIncidentDetectorAction.findRelatedIncident(
      flowInputs
    );
    Test.stopTest();
    return relatedIncident;
  }
}
