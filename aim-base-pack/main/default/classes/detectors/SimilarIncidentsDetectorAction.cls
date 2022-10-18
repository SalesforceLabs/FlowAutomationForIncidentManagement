/**
 * @description Invokable Apex action to retrieve the similar incidents
 */
public with sharing class SimilarIncidentsDetectorAction {
  /**
   * @description retrieve the similar incidents
   * @param request (List<FlowInput>): Apex Wrapper to get multiple inputs from Flow
   * @return List<List<Id>>:  List of List containing the Id of the similar incidents
   * @throws AIMInvalidInputException Exception thrown if an empty list or null is passed
   */
  @InvocableMethod(
    label='Retrieve Ids of the Similar Incidents'
    description='Returns the Ids of the Similar Incidents'
    category='AIM'
  )
  public static List<List<Id>> findSimilarIncidents(List<FlowInput> request) {
    if (
      request != null &&
      !request.isEmpty() &&
      request.get(0) != null &&
      request.get(0).incidentId != null
    ) {
      Set<Id> relatedIncidentIds = SimilarIncidentsDetectorHandler.getSimilarIncidents(
        request
      );

      List<List<Id>> similarIncidents = new List<List<Id>>();
      similarIncidents.add(new List<Id>(relatedIncidentIds));
      return similarIncidents;
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
      label='Product Match criteria '
      description='Incidents will be matched on products if this is set as true'
    )
    public boolean isProductMatchEnabled;
    @InvocableVariable(
      label='Asset Match criteria'
      description='Incidents will be matched on assets if this is set as true'
    )
    public boolean isAssetMatchEnabled;
    @InvocableVariable(
      label='Case Match criteria'
      description='Incidents will be matched on cases if this is set as true'
    )
    public boolean isCaseMatchEnabled;
    @InvocableVariable(
      label='Attribute Match criteria'
      description='Incidents will be matched on attributes if this is set as true'
    )
    public boolean isAttributesMatchEnabled;
    @InvocableVariable(
      label='Asset proximity distance criteria'
      description='Incidents will be matched on asset proximity distance if it has a positive value'
    )
    public Double assetProximityDistance;
    @InvocableVariable(
      label='Input Incident Id'
      description='Id of the  incident for which match will happen'
    )
    public Id incidentId;
  }
}
