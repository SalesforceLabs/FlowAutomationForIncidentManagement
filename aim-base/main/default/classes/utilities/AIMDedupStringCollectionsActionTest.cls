/**
 * AIMDedupStringCollectionsActionTest Test class for AIMDedupStringCollectionsAction
 */
@isTest
private with sharing class AIMDedupStringCollectionsActionTest {
  /**
   * removeDuplicates method to test removing duplciate collection from List of collection
   */
  @isTest
  static void removeDuplicates() {
    List<AIMDedupStringCollectionsAction.FlowInput> flowInputs = new List<AIMDedupStringCollectionsAction.FlowInput>();
    List<AIMDedupStringCollectionsAction.FlowOutput> flowOutputs = new List<AIMDedupStringCollectionsAction.FlowOutput>();
    AIMDedupStringCollectionsAction.FlowInput flowInputOriginal = new AIMDedupStringCollectionsAction.FlowInput();
    flowInputOriginal.collection = new List<String>{ '1', '2' };
    AIMDedupStringCollectionsAction.FlowInput flowInputDuplciate = new AIMDedupStringCollectionsAction.FlowInput();
    flowInputDuplciate.collection = new List<String>{ '1', '2' };
    flowInputs.add(flowInputOriginal);
    flowInputs.add(flowInputDuplciate);

    flowOutputs = AIMDedupStringCollectionsAction.bulkInvoke(flowInputs);

    Assert.areEqual(
      0,
      flowOutputs?.get(1).filteredCollection.size(),
      'Duplicate not removed'
    );
  }
}
