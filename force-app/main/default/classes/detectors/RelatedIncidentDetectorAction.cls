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
      description='Id of the case/asset for which match will happen to find the related incident if it is present'
      required='true'
    )
    public Id caseOrAssetId;

    @InvocableVariable(
      label='Product Match criteria'
      description='Case/Asset will be matched on products if this is set as true to find the related incident if it is present'
    )
    public boolean isProductMatchEnabled;
    @InvocableVariable(
      label='Asset Match criteria'
      description='Case/Asset will be matched on assets if this is set as true to find the related incident if it is present'
    )
    public boolean isAssetMatchEnabled;
    @InvocableVariable(
      label='Asset proximity distance criteria'
      description='Case/Asset will be matched on asset proximity distance if it has a positive value'
    )
    public Double assetProximityDistance;
    @InvocableVariable(
      label='Id of the Cases/Assets Report'
      description='Case/Asset will be matched on records present in report to find the related incident if it is present'
    )
    public String reportId;
  }
}
