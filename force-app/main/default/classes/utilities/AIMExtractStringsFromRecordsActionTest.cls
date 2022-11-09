/**
 * AIMExtractStringsFromRecordsActionTest Test Class for AIMExtractStringsFromRecordsAction utility action
 */
@isTest
private with sharing class AIMExtractStringsFromRecordsActionTest {
  /**
   * retrieveIds method to test retrieving Ids from Collection fo Incident Records
   */
  @isTest
  static void retrieveIds() {
    List<Incident> incidents = new List<Incident>();
    incidents.add(
      new Incident(
        Subject = 'Test Incident 1',
        Impact = 'High',
        Urgency = 'High',
        Priority = 'Critical',
        Status = 'New'
      )
    );
    incidents.add(
      new Incident(
        Subject = 'Test Incident 2',
        Impact = 'High',
        Urgency = 'High',
        Priority = 'Critical',
        Status = 'New'
      )
    );
    insert incidents;

    Test.startTest();
    List<AIMExtractStringsFromRecordsAction.FlowInput> flowInputs = new List<AIMExtractStringsFromRecordsAction.FlowInput>();
    List<AIMExtractStringsFromRecordsAction.FlowOutput> flowOutputs = new List<AIMExtractStringsFromRecordsAction.FlowOutput>();
    AIMExtractStringsFromRecordsAction.FlowInput flowInput = new AIMExtractStringsFromRecordsAction.FlowInput();
    flowInput.collection = incidents;
    flowInput.fieldName = 'Id';
    flowInput.shouldRemoveDuplicates = true;
    flowInputs.add(flowInput);

    flowOutputs = AIMExtractStringsFromRecordsAction.bulkInvoke(flowInputs);
    Test.stopTest();

    Assert.areEqual(
      2,
      flowOutputs?.get(0).values.size(),
      'Unable to retrieve Ids from Record Collection'
    );
  }
}
