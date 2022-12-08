/**
 @description Invokable Apex action to retrieve RecordIds from Report
 */
public with sharing class ReportDataRetrieverAction {
  /**
   * @description  Retrieve RecordIds from Report
   * @param developerNames (List<String>):List containing the DeveloperName of the Report
   * @return List<List<Id>>: List of List containing the Id of the records present in the Report
   * @throws  AIMInvalidInputException : Exception thrown if the developer name is null or empty.
   */
  @InvocableMethod(
    label='Retrieve RecordIds from Report'
    description='Returns the Id of the records present in the Report'
    category='AIM'
  )
  public static List<List<Id>> retrieveRecordIdsFromReport(
    List<String> developerNames
  ) {
    List<List<Id>> recordIds = new List<List<Id>>();

    if (
      developerNames == null ||
      developerNames.isEmpty() ||
      developerNames.get(0) == null ||
      String.isEmpty(developerNames.get(0))
    ) {
      throw new AIMBaseException.AIMInvalidInputException(
        System.Label.AIM_Report_Null_Exception
      );
    }

    String developerName = developerNames.get(0);

    List<Report> reports = [
      SELECT Id
      FROM Report
      WHERE DeveloperName = :developerName
      LIMIT 1
    ];
    if (!reports.isEmpty()) {
      Set<Id> uniqueRecordIds = ReportDataExtractionHandler.getRecordIds(
        reports.get(0).Id
      );

      recordIds.add(new List<Id>(uniqueRecordIds));
    }

    return recordIds;
  }
}
