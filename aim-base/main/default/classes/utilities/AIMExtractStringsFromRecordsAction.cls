/**
 * AIMExtractStringsFromRecords Flow Utility action to retrieve Field values from the passed Record Collection. This is useful in Flow to avoid Collection looping.
 * Idea taken from: https://github.com/trailheadapps/automation-components/blob/main/src-collections/main/default/classes/ExtractStringsFromRecords.cls
 */
public with sharing class AIMExtractStringsFromRecordsAction {
  /**
   * bulkInvoke: Invocable method to retrieve passed Field values from the input Record Collection.
   *
   * @param inputs (List<FlowInput>): Input wrapper
   *
   * @return List<FlowOutput>: Response with List of Field values.
   *
   * @throws AIMBaseException Generic exception
   */
  @InvocableMethod(
    label='Extracts specific field values as strings from a list of records'
    category='AIM'
  )
  public static List<FlowOutput> bulkInvoke(List<FlowInput> inputs) {
    try {
      List<FlowOutput> outputs = new List<FlowOutput>();
      for (FlowInput input : inputs) {
        outputs.add(invoke(input));
      }
      return outputs;
    } catch (Exception e) {
      throw new AIMBaseException(System.Label.AIM_Generic_Error, e);
    }
  }

  /**
   * invoke: method to retrive values from the single instance of invocable method input parameter.
   *
   * @param input (FlowInput): Single instance of input
   *
   * @return FlowOutput: Single instance of ouput
   */
  private static FlowOutput invoke(FlowInput input) {
    List<SObject> collection = input.collection;
    String fieldName = input.fieldName;

    List<String> values = new List<String>();
    for (SObject record : collection) {
      String fieldValue = String.valueOf(record.get(fieldName));
      values.add(fieldValue);
    }
    if (input.shouldRemoveDuplicates) {
      values = new List<String>(new Set<String>(values));
    }
    FlowOutput output = new FlowOutput();
    output.values = values;
    return output;
  }

  /**
   * FlowInput Flow Input wrapper for Record Collection, Field to retrieve
   */
  public class FlowInput {
    @InvocableVariable(
      label='Record Collection'
      description='Record collection variable to extract Field values from'
      required=true
    )
    public List<SObject> collection;
    @InvocableVariable(
      label='Field Name'
      description='Field API Name to extract value'
      required=true
    )
    public String fieldName;
    @InvocableVariable(
      label='Remove Duplicates'
      description='Should duplicates be removed from extracted collection?'
    )
    public Boolean shouldRemoveDuplicates = false;
  }

  /**
   * FlowOutput Flow Output wrapper with List of Field values
   */
  public class FlowOutput {
    @InvocableVariable(
      label='Collection String'
      description='Extracted collection variable'
    )
    public List<String> values;
  }
}
