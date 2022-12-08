/**
 * @description Invokable Apex action to retrieve the related incident
 */
public with sharing class RelatedIncidentDetectorAction {
  /**
   * @description retrieve the related incident
   * @param request (List<FlowInput>): Apex Wrapper to get multiple inputs from Flow
   * @return List<Id>: List containing the Id of the related incident
   * @throws AIMInvalidInputException Exception thrown if an empty list or null is passed
   */
  @InvocableMethod(
    label='Retrieve Id of the Related Incident'
    description='Returns the Id of the Related Incident'
    category='AIM'
  )
  public static List<Id> findRelatedIncident(List<FlowInput> request) {
    if (
      request != null &&
      !request.isEmpty() &&
      request.get(0) != null &&
      request.get(0).caseOrAssetId != null
    ) {
      return new List<Id>{
        RelatedIncidentDetectorHandler.getRelatedIncident(request.get(0))
      };
    } else {
      throw new AIMBaseException.AIMInvalidInputException(
        System.Label.AIM_Matching_Logic_Invalid_Input_Exception
      );
    }
  }

  /**
   * @description Apex Wrapper class to receive multiple inputs from Flow
   */
  public class FlowInput {
    @InvocableVariable(
      label='Input Case Or Asset Id'
      description='The ID of the case or asset that is related to the incident.'
      required='true'
    )
    public Id caseOrAssetId;

    @InvocableVariable(
      label='Product Match criteria'
      description='Enable this capability to find a related incident with cases and assets that meet the specified match criteria based on products'
    )
    public boolean isProductMatchEnabled;
    @InvocableVariable(
      label='Asset Match criteria'
      description='Enable this capability to find a related incident with cases and assets that meet the specified match criteria.'
    )
    public boolean isAssetMatchEnabled;
    @InvocableVariable(
      label='Asset proximity distance criteria'
      description='Find a related incident for cases and assets that meet the specified proximity distance.'
    )
    public Double assetProximityDistance;
    @InvocableVariable(
      label='Id of the Cases/Assets Report'
      description='Find a related incident for cases and assets based on records in the specified report.'
    )
    public String reportId;
  }
}
