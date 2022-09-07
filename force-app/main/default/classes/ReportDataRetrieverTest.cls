/**
 @description Test class for ReportDataRetriever Class
 */
@isTest
@SuppressWarnings('PMD')
public class ReportDataRetrieverTest {
  /**
   *@description Ungrouped Tabular Report with correct DeveloperName
   */
  @isTest(SeeAllData='true')
  static void getRecordIdsFromReport_1() {
    Case caseRecord = new Case();
    insert caseRecord;
    List<String> developerNameList = new List<String>();
    developerNameList.add('New_Cases_Report_nxP'); // cases report
    List<List<Id>> idList = ReportDataRetriever.retrieveRecordCollection(
      developerNameList
    );
    //System.AssertEquals(1, idList.get(0).size());
  }

  /**
   *@description  Incorrect DeveloperName
   */
  @isTest(SeeAllData='true')
  static void getRecordIdsFromReport_2() {
    List<String> developerNameList = new List<String>();
    developerNameList.add('xNew_Cases_Report_nxPx');
    List<List<Id>> idList = ReportDataRetriever.retrieveRecordCollection(
      developerNameList
    );
    System.AssertEquals(null, idList);
  }

  /**
   *@description Tabular Report Grouped on Id with correct DeveloperName
   */
  @isTest(SeeAllData='true')
  static void getRecordIdsFromReport_3() {
    Account accountRecord = new Account(Name = 'Test Account');
    insert accountRecord;
    Asset assetRecord = new Asset(
      Name = 'Test Asset',
      AccountId = accountRecord.Id
    );
    insert assetRecord;
    List<String> developerNameList = new List<String>();
    developerNameList.add('New_Assets_Report_0Y1'); // asset report
    List<List<Id>> idList = ReportDataRetriever.retrieveRecordCollection(
      developerNameList
    );
    //System.AssertEquals(1, idList.get(0).size());
  }
}
