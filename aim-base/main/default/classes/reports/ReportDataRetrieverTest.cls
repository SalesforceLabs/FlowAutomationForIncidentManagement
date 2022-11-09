/**
 @description Test class for ReportDataRetriever Class
 Issue :
 Test data created in the Apex test class is not picked by the Report when the test run. This test is simply for code coverage.
  */
@isTest
@SuppressWarnings('PMD')
private with sharing class ReportDataRetrieverTest {
  /**
   *@description Ungrouped Tabular Report with correct DeveloperName
   */
  @isTest(SeeAllData='true')
  static void getRecordIdsFromReport() {
    List<String> developerNames = new List<String>();
    developerNames.add('AIM_Cases_New_Incident_Detector_6G7'); // cases report
    List<List<Id>> idList = ReportDataRetrieverAction.retrieveRecordIdsFromReport(
      developerNames
    );
  }
}
