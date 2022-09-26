/**
 * @description Retrieve similar Incident Ids
 */
public with sharing class SimilarIncidentsDetectorHandler {
  private static Id inputIncidentId;
  private static boolean isProductMatchEnabled;
  private static boolean isAssetMatchEnabled;
  private static boolean isCaseMatchEnabled;
  private static boolean isAttributesMatchEnabled;
  private static Double assetProximityDistance;
  /**
   * @description get all the Id of the incidents similar to the input incident
   * @param request (List<SimilarIncidentsDetectorAction.FlowInput>): flow inputs
   * @return Set<Id>: Id of the  similar incidents
   */
  public static Set<Id> getSimilarIncidents(
    List<SimilarIncidentsDetectorAction.FlowInput> request
  ) {
    inputIncidentId = request.get(0).incidentId;

    sanitizeInput(request);

    Set<Id> relatedIncidentIds = new Set<Id>();
    List<Id> inputIncidentAssetIds = new List<Id>();
    List<Id> inputIncidentProductIds = new List<Id>();
    List<IncidentRelatedItem> inputIncidentRelatedItems = new List<IncidentRelatedItem>();
    if (
      isProductMatchEnabled ||
      isAssetMatchEnabled ||
      (assetProximityDistance > 0)
    ) {
      inputIncidentRelatedItems = getInputIncidentAssetsAndProducts(
        inputIncidentId
      );

      for (
        IncidentRelatedItem inputIncidentRelatedItem : inputIncidentRelatedItems
      ) {
        if (inputIncidentRelatedItem.Asset.Product2Id != null) {
          inputIncidentProductIds.add(
            inputIncidentRelatedItem.Asset.Product2Id
          );
        }
        if (inputIncidentRelatedItem.AssetId != null) {
          inputIncidentAssetIds.add(inputIncidentRelatedItem.AssetId);
        }
      }
    }

    if (isProductMatchEnabled) {
      findIncidentsMatchedOnProducts(
        inputIncidentProductIds,
        inputIncidentId,
        relatedIncidentIds
      );
    }
    if (isAssetMatchEnabled) {
      findIncidentsMatchedOnAssets(
        inputIncidentAssetIds,
        inputIncidentId,
        relatedIncidentIds
      );
    }
    if (isCaseMatchEnabled) {
      findIncidentsMatchedOnCases(inputIncidentId, relatedIncidentIds);
    }

    if (isAttributesMatchEnabled) {
      findIncidentsMatchedOnAttributes(inputIncidentId, relatedIncidentIds);
    }

    if (assetProximityDistance > 0) {
      findIncidentsMatchedOnAssetProximity(
        assetProximityDistance,
        inputIncidentId,
        inputIncidentRelatedItems,
        relatedIncidentIds
      );
    }
    relatedIncidentIds.remove(inputIncidentId);
    return relatedIncidentIds;
  }

  /**
   *@description Get input incident's Assets and Products
   * @param inputIncidentId (Id): Id of the input incident
   * @return List<IncidentRelatedItem>:List of IncidentRelatedItem records which contains
   * assets and products of the input incident
   */
  private static List<IncidentRelatedItem> getInputIncidentAssetsAndProducts(
    Id inputIncidentId
  ) {
    List<IncidentRelatedItem> inputIncidentRelatedItems = [
      SELECT Asset.Product2Id, Asset.Latitude, Asset.Longitude, AssetId
      FROM IncidentRelatedItem
      WHERE IncidentId = :inputIncidentId
      WITH SECURITY_ENFORCED
    ];

    return inputIncidentRelatedItems;
  }
  /**
   * @description find incidents matched on Products of the input incident
   * @param inputIncidentProductIds (List<Id>):List containing the Products
   *  of the input incident
   * @param inputIncidentId (Id): Id of the input incident
   * @param relatedIncidentIds (Set<Id>): Set containing the Ids of the
   * similar incidents identified so far
   */

  private static void findIncidentsMatchedOnProducts(
    List<Id> inputIncidentProductIds,
    Id inputIncidentId,
    Set<Id> relatedIncidentIds
  ) {
    for (IncidentRelatedItem relatedIncident : [
      SELECT IncidentId
      FROM IncidentRelatedItem
      WHERE
        Incident.IsClosed = FALSE
        AND Asset.Product2Id IN :inputIncidentProductIds
        AND IncidentId != :inputIncidentId
      WITH SECURITY_ENFORCED
    ]) {
      relatedIncidentIds.add(relatedIncident.IncidentId);
    }
  }

  /**
   * @description find incidents matched on Assets of the input incident
   * @param inputIncidentAssetIds (List<Id>):List containing the Assets
   *  of the input incident
   * @param inputIncidentId (Id): Id of the input incident
   * @param relatedIncidentIds (Set<Id>): Set containing the Ids of the
   * similar incidents identified so far
   */
  private static void findIncidentsMatchedOnAssets(
    List<Id> inputIncidentAssetIds,
    Id inputIncidentId,
    Set<Id> relatedIncidentIds
  ) {
    for (IncidentRelatedItem relatedIncident : [
      SELECT IncidentId
      FROM IncidentRelatedItem
      WHERE
        Incident.IsClosed = FALSE
        AND AssetId IN :inputIncidentAssetIds
        AND IncidentId != :inputIncidentId
      WITH SECURITY_ENFORCED
    ]) {
      relatedIncidentIds.add(relatedIncident.IncidentId);
    }
  }
  /**
   * @description find incidents matched on Cases of the input incident
   * @param inputIncidentId (Id): Id of the input incident
   * @param relatedIncidentIds (Set<Id>): Set containing the Ids of the
   * similar incidents identified so far
   */
  private static void findIncidentsMatchedOnCases(
    Id inputIncidentId,
    Set<Id> relatedIncidentIds
  ) {
    List<Id> incidentIds = new List<Id>();
    for (Incident incident : [
      SELECT Id
      FROM Incident
      WHERE isClosed = FALSE AND Id NOT IN :relatedIncidentIds
      WITH SECURITY_ENFORCED
    ]) {
      incidentIds.add(incident.Id);
    }
    // adding the input incident Id incase if it not retrieved by SOQL
    if (!incidentIds.contains(inputIncidentId)) {
      incidentIds.add(inputIncidentId);
    }
    List<Id> inputIncidentCaseIds = new List<Id>();
    Map<Id, List<Id>> caseIdToIncidentIdsMap = new Map<Id, List<Id>>();
    for (CaseRelatedIssue caseRelatedIssue : [
      SELECT RelatedIssueId, CaseId
      FROM CaseRelatedIssue
      WHERE RelatedIssueId = :incidentIds
      WITH SECURITY_ENFORCED
    ]) {
      if (caseRelatedIssue.RelatedIssueId == inputIncidentId) {
        inputIncidentCaseIds.add(caseRelatedIssue.caseId);
      } else {
        if (!caseIdToIncidentIdsMap.containsKey(caseRelatedIssue.CaseId)) {
          caseIdToIncidentIdsMap.put(caseRelatedIssue.CaseId, new List<Id>());
        }
        caseIdToIncidentIdsMap.get(caseRelatedIssue.CaseId)
          .add(caseRelatedIssue.RelatedIssueId);
      }
    }

    for (Id inputIncidentCaseId : inputIncidentCaseIds) {
      if (caseIdToIncidentIdsMap.containsKey(inputIncidentCaseId)) {
        relatedIncidentIds.addAll(
          caseIdToIncidentIdsMap.get(inputIncidentCaseId)
        );
      }
    }
  }

  /**
   * @description find incidents matched on Attributes of the input incident
   * @param inputIncidentId (Id): Id of the input incident
   * @param relatedIncidentIds (Set<Id>): Set containing the Ids of the
   * similar incidents identified so far
   */
  private static void findIncidentsMatchedOnAttributes(
    Id inputIncidentId,
    Set<Id> relatedIncidentIds
  ) {
    List<Incident> inputIncident = [
      SELECT Category, SubCategory, Type
      FROM Incident
      WHERE Id = :inputIncidentId
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    if (inputIncident == null || inputIncident.isEmpty()) {
      return;
    }
    for (Incident relatedIncident : [
      SELECT Id
      FROM Incident
      WHERE
        Category = :inputIncident.get(0).Category
        AND SubCategory = :inputIncident.get(0).SubCategory
        AND Type = :inputIncident.get(0).Type
        AND isClosed = FALSE
    ]) {
      relatedIncidentIds.add(relatedIncident.Id);
    }
  }

  /**
   * @description find incidents matched on Asset Proximity of the input incident
   * @param proximityValue (Integer): Integer threshold value for proximity calculation
   * @param incidentId (Id):  Id of the input incident
   * @param inputIncidentRelatedItems (List<IncidentRelatedItem>): Incident Related Items
   * of the input incident
   * @param relatedIncidentIds (Set<Id>): Set containing the Ids of the
   * similar incidents identified so far
   */

  private static void findIncidentsMatchedOnAssetProximity(
    Double proximityValue,
    Id incidentId,
    List<IncidentRelatedItem> inputIncidentRelatedItems,
    Set<Id> relatedIncidentIds
  ) {
    Location loc1 = null;
    for (
      IncidentRelatedItem inputIncidentRelatedItem : inputIncidentRelatedItems
    ) {
      if (
        inputIncidentRelatedItem.Asset.Latitude != null &&
        inputIncidentRelatedItem.Asset.Longitude != null
      ) {
        loc1 = Location.newInstance(
          inputIncidentRelatedItem.Asset.Latitude,
          inputIncidentRelatedItem.Asset.Longitude
        );
        break;
      }
    }
    if (loc1 == null) {
      return;
    }
    List<IncidentRelatedItem> incidentRelatedItems = [
      SELECT Asset.Latitude, Asset.Longitude, IncidentId
      FROM IncidentRelatedItem
      WHERE
        IncidentId != :incidentId
        AND IncidentId NOT IN :relatedIncidentIds
        AND Incident.IsClosed = FALSE
      WITH SECURITY_ENFORCED
    ];

    for (IncidentRelatedItem relatedItem : incidentRelatedItems) {
      if (!relatedIncidentIds.contains(relatedItem.IncidentId)) {
        if (
          relatedItem.Asset.Latitude != null &&
          relatedItem.Asset.Longitude != null
        ) {
          Location loc2 = Location.newInstance(
            relatedItem.Asset.Latitude,
            relatedItem.Asset.Longitude
          );
          if (Location.getDistance(loc1, loc2, 'mi') <= proximityValue) {
            relatedIncidentIds.add(relatedItem.IncidentId);
          }
        }
      }
    }
  }
  /**
   * @description validates if any criteria is null and sets as false if it is null
   * @param request (List<SimilarIncidentsDetectorAction.FlowInput>): input request
   */
  private static void sanitizeInput(
    List<SimilarIncidentsDetectorAction.FlowInput> request
  ) {
    isProductMatchEnabled = request.get(0).isProductMatchEnabled == null
      ? false
      : request.get(0).isProductMatchEnabled;
    isAssetMatchEnabled = request.get(0).isAssetMatchEnabled == null
      ? false
      : request.get(0).isAssetMatchEnabled;
    isCaseMatchEnabled = request.get(0).isCaseMatchEnabled == null
      ? false
      : request.get(0).isCaseMatchEnabled;
    isAttributesMatchEnabled = request.get(0).isAttributesMatchEnabled == null
      ? false
      : request.get(0).isAttributesMatchEnabled;
    assetProximityDistance = request.get(0).assetProximityDistance == null
      ? 0
      : request.get(0).assetProximityDistance;
  }
}
