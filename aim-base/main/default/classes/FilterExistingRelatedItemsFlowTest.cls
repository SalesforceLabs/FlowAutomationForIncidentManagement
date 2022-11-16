/**
 * FilterExistingRelatedItemsFlowTest:
 * Takes an incidentId, a list of caseIds and assetIds,
 * and filter the collections to only cases and assets
 * that are not already associated with the specified incident.
 * @version 56.0
 */
@isTest
private class FilterExistingRelatedItemsFlowTest {
  /**
   * createTestData: Create Data for test execution
   *
   */
  @testSetup
  static void createTestData() {
    List<Case> cases = AIM_TestFactory.createCases(4);
    List<Asset> assets = new List<Asset>();
    List<Incident> incidents = AIM_TestFactory.createIncidents(2);
    List<IncidentRelatedItem> incidentRelatedItems = new List<IncidentRelatedItem>();
    List<CaseRelatedIssue> caseRelatedIssues = new List<CaseRelatedIssue>();

    Account account = AIM_TestFactory.createAccounts(1)[0];

    for (Integer counter = 0; counter <= 2; counter++) {
      Asset asset = new Asset(
        Name = 'Test Asset ' + counter,
        AccountId = account.Id,
        Status = 'Shipped'
      );
      assets.add(asset);
    }
    insert assets;

    for (Integer counter = 0; counter <= 1; counter++) {
      CaseRelatedIssue caseRelatedIssue = new CaseRelatedIssue(
        RelatedIssueId = incidents.get(0).Id,
        CaseId = cases.get(counter).Id,
        RelationshipType = 'Similar'
      );
      IncidentRelatedItem incidentRelatedItem = new IncidentRelatedItem(
        IncidentId = incidents.get(0).Id,
        AssetId = assets.get(counter).Id,
        ImpactType = 'Partially Business-Blocking'
      );
      caseRelatedIssues.add(caseRelatedIssue);
      incidentRelatedItems.add(incidentRelatedItem);
    }
    insert caseRelatedIssues;
    insert incidentRelatedItems;
  }

  /**
   * testIncidentAssociatedWithItems: Pass IncidentId which is associated with some AssetIds and caseIds
   *
   */
  @isTest
  static void testIncidentAssociatedWithItems() {
    List<Incident> incident = [
      SELECT Id
      FROM Incident
      WHERE Subject = 'Test Incident 0'
    ];
    List<String> caseIds = new List<String>();
    for (Case caseRecord : [SELECT Id FROM Case WHERE Subject LIKE 'Test%']) {
      caseIds.add(caseRecord.Id);
    }
    List<String> assetIds = new List<String>();
    for (Asset assetRecord : [SELECT Id FROM Asset WHERE Name LIKE 'Test%']) {
      assetIds.add(assetRecord.Id);
    }
    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', incident.get(0).Id);
    inputs.put('assetIds', assetIds);
    inputs.put('caseIds', caseIds);
    Flow.Interview.AIM_FilterExistingIncidentRelatedItems flowRunner = new Flow.Interview.AIM_FilterExistingIncidentRelatedItems(
      inputs
    );
    flowRunner.start();

    Test.stopTest();
    List<String> caseIdsOutput = (List<String>) flowRunner.getVariableValue(
      'caseIds'
    );
    Assert.areEqual(
      2,
      caseIdsOutput.size(),
      'Number of Case Ids in Flow Output variable should have changed.'
    );
    List<String> assetIdsOutput = (List<String>) flowRunner.getVariableValue(
      'assetIds'
    );
    Assert.areEqual(
      1,
      assetIdsOutput.size(),
      'Number of Asset Ids in Flow Output variable should have changed.'
    );
  }

  /**
   * testIncidentNotAssociatedWithItems: Pass IncidentId which is not associated with any AssetIds and caseIds
   *
   */
  @isTest
  static void testIncidentNotAssociatedWithItems() {
    List<Incident> incident = [
      SELECT Id
      FROM Incident
      WHERE Subject = 'Test Incident 1'
    ];

    List<String> caseIds = new List<String>();
    for (Case caseRecord : [SELECT Id FROM Case WHERE Subject LIKE 'Test%']) {
      caseIds.add(caseRecord.Id);
    }
    List<String> assetIds = new List<String>();
    for (Asset assetRecord : [SELECT Id FROM Asset WHERE Name LIKE 'Test%']) {
      assetIds.add(assetRecord.Id);
    }
    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', incident.get(0).Id);
    inputs.put('assetIds', assetIds);
    inputs.put('caseIds', caseIds);
    Flow.Interview.AIM_FilterExistingIncidentRelatedItems flowRunner = new Flow.Interview.AIM_FilterExistingIncidentRelatedItems(
      inputs
    );
    flowRunner.start();

    Test.stopTest();
    List<String> caseIdsOutput = (List<String>) flowRunner.getVariableValue(
      'caseIds'
    );
    Assert.areEqual(
      4,
      caseIdsOutput.size(),
      'Number of Case Ids in Flow Output variable should be same as Input.'
    );
    List<String> assetIdsOutput = (List<String>) flowRunner.getVariableValue(
      'assetIds'
    );
    Assert.areEqual(
      3,
      assetIdsOutput.size(),
      'Number of Asset Ids in Flow Output variable should be same as Input.'
    );
  }
}
