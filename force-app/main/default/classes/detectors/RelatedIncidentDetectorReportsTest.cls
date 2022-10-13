/*
 *  @description Test Class for  RelatedIncidentDetectorAction -Report records Match criteria
 */

@isTest
@SuppressWarnings('PMD')
public class RelatedIncidentDetectorReportsTest {
  /*
   *  @description get the related Incident if present for the case from Cases Report
   */
  @isTest(SeeAllData='true')
  static void caseReportTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    Case caseRecord = new Case();
    insert caseRecord;
    apexActionInput.caseOrAssetId = caseRecord.Id;
    apexActionInput.reportId = [
      SELECT Id
      FROM Report
      WHERE DeveloperName = 'New_Cases_Report_nxP'
    ]
    .Id;
    System.assertEquals(
      null,
      RelatedIncidentDetectorActionTest.runDetector(apexActionInput).get(0)
    );
  }

  /*
   *  @description get the related Incident if present for the asset from Assets Report
   */
  @isTest(SeeAllData='true')
  static void assetReportTest() {
    RelatedIncidentDetectorAction.FlowInput apexActionInput = new RelatedIncidentDetectorAction.FlowInput();
    Account account = new Account(Name = 'Test Account');
    insert account;
    Asset assetRecord = new Asset(AccountId = account.Id, Name = 'Test Asset');
    insert assetRecord;
    apexActionInput.caseOrAssetId = assetRecord.Id;
    apexActionInput.reportId = [
      SELECT Id
      FROM Report
      WHERE DeveloperName = 'New_Assets_Report_0Y1'
    ]
    .Id;
    System.assertEquals(
      null,
      RelatedIncidentDetectorActionTest.runDetector(apexActionInput).get(0)
    );
  }
}
