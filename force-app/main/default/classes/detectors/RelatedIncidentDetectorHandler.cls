/**
 * @description Retrieve related Incident Id
 */

public class RelatedIncidentDetectorHandler {
  private static Id caseId;
  private static Id assetId;
  private static boolean isProductMatchEnabled;
  private static boolean isAssetMatchEnabled;
  private static Double assetProximityDistance;
  private static Id relatedIncidentId;
  private static Id reportId;
  private static List<Id> unclosedIncidentIds;

  /**
   * @description get the Id of the incident related to the case/asset
   * @param request (relatedIncidentDetectorAction.FlowInput):  flow input
   * @return Id: Id of the related Incident
   */
  public static Id getRelatedIncident(
    relatedIncidentDetectorAction.FlowInput request
  ) {
    sanitizeInput(request);
    unclosedIncidentIds = getUnclosedIncidentIds();

    if (caseId != null) {
      return getRelatedIncidentForInputCase(request);
    }
    return assetId != null ? getRelatedIncidentForInputAsset(request) : null;
  }

  /**
   * @description get the Id of the incident related to the asset
   * @param request (relatedIncidentDetectorAction.FlowInput):  flow input
   * @return Id: Id of the related Incident
   */

  private static Id getRelatedIncidentForInputAsset(
    relatedIncidentDetectorAction.FlowInput request
  ) {
    getRelatedIncidentIfAssetAlreadyAttached();
    Asset inputAsset;
    if (relatedIncidentId == null) {
      inputAsset = getInputAssetInfo();
    }

    if (
      relatedIncidentId == null &&
      isProductMatchEnabled &&
      inputAsset?.Product2Id != null
    ) {
      findIncidentMatchedOnProductFromRelatedAssets(inputAsset.Product2Id);
      if (relatedIncidentId == null) {
        findIncidentMatchedOnProductFromRelatedCases(inputAsset.Product2Id);
      }
    }
    if (relatedIncidentId == null && isAssetMatchEnabled) {
      findIncidentMatchedOnAssetFromRelatedCases(assetId);
    }

    if (
      relatedIncidentId == null &&
      assetProximityDistance > 0 &&
      inputAsset != null
    ) {
      findIncidentMatchedOnAssetProximity(assetProximityDistance, inputAsset);
    }

    if (relatedIncidentId == null && reportId != null) {
      getRelatedIncidentFromRecordsInAssetsReport();
    }
    return relatedIncidentId;
  }

  /**
   * @description get the Id of the incident related to the case
   * @param request (relatedIncidentDetectorAction.FlowInput):  flow input
   * @return Id: Id of the related Incident
   */
  private static Id getRelatedIncidentForInputCase(
    relatedIncidentDetectorAction.FlowInput request
  ) {
    getRelatedIncidentIfCaseAlreadyAttached();
    Case inputCase;
    if (relatedIncidentId == null) {
      inputCase = getInputCaseInfo();
    }

    if (
      relatedIncidentId == null &&
      isProductMatchEnabled &&
      inputCase?.Asset?.Product2Id != null
    ) {
      findIncidentMatchedOnProductFromRelatedAssets(inputCase.Asset.Product2Id);

      if (relatedIncidentId == null) {
        findIncidentMatchedOnProductFromRelatedCases(
          inputCase.Asset.Product2Id
        );
      }
    }
    if (
      relatedIncidentId == null &&
      isAssetMatchEnabled &&
      inputCase?.Asset != null
    ) {
      findIncidentMatchedOnAssetFromRelatedCases(inputCase.AssetId);
      if (relatedIncidentId == null) {
        findIncidentMatchedOnAssetFromRelatedAssets(inputCase.AssetId);
      }
    }
    if (
      relatedIncidentId == null &&
      assetProximityDistance > 0 &&
      inputCase?.Asset != null
    ) {
      findIncidentMatchedOnAssetProximity(
        assetProximityDistance,
        inputCase.Asset
      );
    }
    if (relatedIncidentId == null && reportId != null) {
      getRelatedIncidentFromRecordsInCasesReport();
    }

    return relatedIncidentId;
  }
  /**
   * @description get details about the input case
   * @param caseId (Id): Id of the input case
   * @return Case: input case object
   */
  private static Case getInputCaseInfo() {
    List<Case> caseInfo = [
      SELECT AssetId, Asset.Product2Id, Asset.Latitude, Asset.Longitude
      FROM Case
      WHERE Id = :caseId
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    return !caseInfo.isEmpty() ? caseInfo.get(0) : null;
  }

  /**
   * @description get details about the input asset
   * @param assetId (Id): Id of the input asset
   * @return Asset: input asset object
   */
  private static Asset getInputAssetInfo() {
    List<Asset> assetInfo = [
      SELECT Latitude, Longitude, Product2Id
      FROM Asset
      WHERE Id = :assetId
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    return !assetInfo.isEmpty() ? assetInfo.get(0) : null;
  }

  /**
   * @description get the related incident if the case is already attached
   * @param caseId (Id): Id of the input case
   */
  private static void getRelatedIncidentIfCaseAlreadyAttached() {
    List<CaseRelatedIssue> relatedIncident = [
      SELECT RelatedIssueId
      FROM CaseRelatedIssue
      WHERE CaseId = :caseId AND RelatedEntityType = 'Incident'
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    if (!relatedIncident.isEmpty()) {
      relatedIncidentId = relatedIncident.get(0).RelatedIssueId;
    }
  }

  /**
   * @description get the related incident if the asset is already attached
   * @param assetId (Id): Id of the input asset
   */
  private static void getRelatedIncidentIfAssetAlreadyAttached() {
    List<IncidentRelatedItem> relatedIncident = [
      SELECT IncidentId
      FROM IncidentRelatedItem
      WHERE AssetId = :AssetId
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
    if (!relatedIncident.isEmpty()) {
      relatedIncidentId = relatedIncident.get(0).IncidentId;
    }
  }

  /**
   * @description get the related incident matched on products from Incident Related Items
   * @param inputProduct2Id (Id): Id of the case's asset's/asset's product
   */
  private static void findIncidentMatchedOnProductFromRelatedAssets(
    Id inputProduct2Id
  ) {
    List<IncidentRelatedItem> relatedIncident = [
      SELECT IncidentId
      FROM IncidentRelatedItem
      WHERE
        Asset.Product2Id = :inputProduct2Id
        AND IncidentId = :unclosedIncidentIds
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
    if (!relatedIncident.isEmpty()) {
      relatedIncidentId = relatedIncident.get(0).IncidentId;
    }
  }

  /**
   * @description get the related incident matched on products from Case Related Issues
   * @param inputProduct2Id (Id): Id of the case's/asset's product
   */
  private static void findIncidentMatchedOnProductFromRelatedCases(
    Id inputProduct2Id
  ) {
    List<CaseRelatedIssue> relatedCases = [
      SELECT RelatedIssueId
      FROM CaseRelatedIssue
      WHERE
        Case.Asset.Product2Id = :inputProduct2Id
        AND RelatedIssueId IN :unclosedIncidentIds
        AND RelatedEntityType = 'Incident'
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
    if (!relatedCases.isEmpty()) {
      relatedIncidentId = relatedCases.get(0).RelatedIssueId;
    }
  }

  /**
   * @description get the related incident matched on assets from Incident Related Items
   * @param inputAssetId (Id): Id of the input case's asset/input asset
   */
  private static void findIncidentMatchedOnAssetFromRelatedAssets(
    Id inputAssetId
  ) {
    List<IncidentRelatedItem> relatedIncident = [
      SELECT IncidentId
      FROM IncidentRelatedItem
      WHERE AssetId = :inputAssetId AND IncidentId = :unclosedIncidentIds
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
    if (!relatedIncident.isEmpty()) {
      relatedIncidentId = relatedIncident.get(0).IncidentId;
    }
  }

  /**
   * @description get the related incident matched on assets from Case Related Issues
   * @param assetId (Id): Id of the input case's asset/input asset
   */
  private static void findIncidentMatchedOnAssetFromRelatedCases(Id assetId) {
    List<CaseRelatedIssue> relatedCases = [
      SELECT RelatedIssueId
      FROM CaseRelatedIssue
      WHERE
        Case.AssetId = :assetId
        AND RelatedIssueId IN :unclosedIncidentIds
        AND RelatedEntityType = 'Incident'
      WITH security_enforced
      LIMIT 1
    ];
    if (!relatedCases.isEmpty()) {
      relatedIncidentId = relatedCases.get(0).RelatedIssueId;
    }
  }

  /**
   * @description get the related incident matched on records present in assets report
   * @param reportId (Id): Id of the asset's report
   */
  private static void getRelatedIncidentFromRecordsInAssetsReport() {
    Set<Id> recordIds = ReportDataExtractionHandler.getRecordIds(reportId);

    List<IncidentRelatedItem> relatedIncident = [
      SELECT IncidentId
      FROM IncidentRelatedItem
      WHERE AssetId IN :recordIds AND IncidentId = :unclosedIncidentIds
      WITH security_enforced
      LIMIT 1
    ];
    if (!relatedIncident.isEmpty()) {
      relatedIncidentId = relatedIncident.get(0).IncidentId;
    }
  }

  /**
   * @description get the related incident matched on records present in cases report
   * @param reportId (Id): Id of the case's report
   */
  private static void getRelatedIncidentFromRecordsInCasesReport() {
    Set<Id> recordIds = ReportDataExtractionHandler.getRecordIds(reportId);

    List<CaseRelatedIssue> relatedIncident = [
      SELECT RelatedIssueId
      FROM CaseRelatedIssue
      WHERE
        CaseId IN :recordIds
        AND RelatedIssueId IN :unclosedIncidentIds
        AND RelatedEntityType = 'Incident'
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
    if (!relatedIncident.isEmpty()) {
      relatedIncidentId = relatedIncident.get(0).RelatedIssueId;
    }
  }

  /**
   * @description get the related incident matched on asset proximity distance
   * @param proximityValue (Double):threshold value for proximity calculation
   * @param inputAsset (Asset): input asset object
   */
  private static void findIncidentMatchedOnAssetProximity(
    Double proximityValue,
    Asset inputAsset
  ) {
    if (
      inputAsset != null &&
      inputAsset.Latitude != null &&
      inputAsset.Longitude != null
    ) {
      Location loc1 = Location.newInstance(
        inputAsset.Latitude,
        inputAsset.Longitude
      );

      for (IncidentRelatedItem relatedItem : [
        SELECT Asset.Latitude, Asset.Longitude, IncidentId
        FROM IncidentRelatedItem
        WHERE IncidentId = :unclosedIncidentIds
        WITH SECURITY_ENFORCED
      ]) {
        if (
          relatedItem.Asset.Latitude != null &&
          relatedItem.Asset.Longitude != null
        ) {
          Location loc2 = Location.newInstance(
            relatedItem.Asset.Latitude,
            relatedItem.Asset.Longitude
          );
          if (Location.getDistance(loc1, loc2, 'mi') <= proximityValue) {
            relatedIncidentId = relatedItem.IncidentId;
            break;
          }
        }
      }
    }
  }

  /**
   * @description get the unclosed Incident Ids
   * @return List<Id> : List containing unclosed incident Ids
   */
  private static List<Id> getUnclosedIncidentIds() {
    List<Id> unclosedIncidentIds = new List<Id>();
    for (Incident incident : [
      SELECT Id
      FROM Incident
      WHERE isClosed = FALSE
      WITH SECURITY_ENFORCED
    ]) {
      unclosedIncidentIds.add(incident.Id);
    }

    return unclosedIncidentIds;
  }

  /**
   * @description validates if any criteria is null and sets as false if it is null
   * @param request (List<relatedIncidentDetectorAction.FlowInput>): input request
   */
  private static void sanitizeInput(
    relatedIncidentDetectorAction.FlowInput request
  ) {
    isProductMatchEnabled = request.isProductMatchEnabled == null
      ? false
      : request.isProductMatchEnabled;
    isAssetMatchEnabled = request.isAssetMatchEnabled == null
      ? false
      : request.isAssetMatchEnabled;

    assetProximityDistance = request.assetProximityDistance == null
      ? 0
      : request.assetProximityDistance;
    String sobjectType = request.caseOrAssetId.getSObjectType()
      .getDescribe()
      .getName();
    if (sobjectType == SObjectFieldAPINameConstants.ASSET) {
      assetId = request.caseOrAssetId;
    } else if (sobjectType == SObjectFieldAPINameConstants.CASE_OBJECT) {
      caseId = request.caseOrAssetId;
    } else {
      throw new AIMBaseException.AIMInvalidInputException(
        System.Label.AIM_Unsupported_sObject_recordId
      );
    }

    if (!String.isBlank(request.reportId) && (request.reportId instanceof Id)) {
      reportId = request.reportId;
    } else {
      reportId = null;
    }
  }
}
