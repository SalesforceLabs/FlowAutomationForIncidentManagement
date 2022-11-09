/**
 * AIMDedupStringCollectionsAction Flow Utility action to remove duplicate String collection from List of List of String. This is used in special use-case to avoid duplciate record creation in AIM during record-triggered Flow bulklification by removing duplicate Id collections from Case Ids. Use this action only if you know what you are doing.
 */
public with sharing class AIMDedupStringCollectionsAction {
  /**
   * bulkInvoke: invocable method to check string collection against other string collection for duplicates in a bulkified flow transaction. If there are duplicates, the collection is set to empty value
   *
   * @param inputs (List<FlowInput>): Input wrapper wtih unfiltered collection
   *
   * @return List<FlowOutput>: Output wrapper with duplicates removed
   *
   * @throws AIMBaseException Generic exception
   */
  @InvocableMethod(
    label='Remove duplicate String/Id collection from Flow bulkification'
    category='AIM'
  )
  public static List<FlowOutput> bulkInvoke(List<FlowInput> inputs) {
    try {
      List<FlowOutput> outputs = new List<FlowOutput>();
      Set<String> uniqueValues = new Set<String>();
      for (FlowInput input : inputs) {
        FlowOutput output = new FlowOutput();
        if (uniqueValues.contains(input.collection.get(0))) {
          output.filteredCollection = new List<String>();
        } else {
          output.filteredCollection = input.collection;
          uniqueValues.addAll(input.collection);
        }
        outputs.add(output);
      }
      return outputs;
    } catch (Exception e) {
      throw new AIMBaseException(System.Label.AIM_Generic_Error, e);
    }
  }

  /**
   * FlowInput Flow Input wrapper for String collection
   */
  public class FlowInput {
    @InvocableVariable(
      label='String/Id Collection'
      description='String collection variable to check for duplicates against other collection in bulkified transaction'
      required=true
    )
    public List<String> collection;
  }

  /**
   * FlowOutput Flow Output wrapper with List of filtered values
   */
  public class FlowOutput {
    @InvocableVariable(
      label='Filtered String/Id Collection'
      description='Filtered String collection variable without duplicates against other collection in bulkified transaction'
    )
    public List<String> filteredCollection;
  }
}
