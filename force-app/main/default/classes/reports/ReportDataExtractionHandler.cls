/**
 @description  Extract the RecordIds from Report
 */
public with sharing class ReportDataExtractionHandler {
  /**
   * @description   Get the RecordIds from Report
   * @param reportId (Id): Id of the Report
   * @return Set<Id>: Set containing Ids of the records present in the Report
   */
  public static Set<Id> getRecordIds(Id reportId) {
    Reports.reportResults results = Reports.ReportManager.runReport(
      reportId,
      true
    );
    Reports.Dimension dimensions = results.getGroupingsDown();

    integer size = dimensions.getGroupings().size();
    // size is not zero means it is a grouped report
    if (size != 0) {
      return getDataFromGroupedReport(results);
    } else {
      return getDataFromUngroupedReport(results);
    }
  }

  /**
   * @description   Get data from Ungrouped Tabular Report
   * Report not grouped on any field and primary field is present in the first column
   * @param results (Reports.reportResults): Result of Report
   * @return Set<Id>: Set containing Ids of the records present in the Report
   * @throws AIMReportRetrievalException Exception : Exception thrown if the first column of the report is not primary field.
   * getValue() method is used since the value of the primary field is Id in the Report results
   */

  private static Set<Id> getDataFromUngroupedReport(
    Reports.reportResults results
  ) {
    Set<Id> uniqueRecordIds = new Set<Id>();

    Reports.ReportFactWithDetails factWithDetails = (Reports.ReportFactWithDetails) results.getFactMap()
      .get('T!T');

    for (Reports.ReportDetailRow row : factWithDetails.getRows()) {
      if (row.getDataCells().get(0).getValue() instanceof Id) {
        uniqueRecordIds.add((Id) row.getDataCells().get(0).getValue());
      } else {
        throw new AIMBaseException.AIMReportRetrievalException(
          'Primary field is not present in the first column of the Report'
        );
      }
    }
    return uniqueRecordIds;
  }

  /**
   * @description  Get data from Tabular Report grouped on Id
   * @param results (Reports.reportResults): Result of Report
   * @return Set<Id>: Set containing Ids on which the Report is grouped
   * @throws AIMReportRetrievalException Exception : Exception thrown if the first column of the report is not Id.
   * getLabel() method is used since the label and value for the Id field is same.
   * Fields which are of not Id type will not have label and value as same in Report results
   */
  private static Set<Id> getDataFromGroupedReport(
    Reports.reportResults results
  ) {
    Set<Id> uniqueRecordIds = new Set<Id>();

    Reports.Dimension dimensions = results.getGroupingsDown();

    for (integer i = 0; i < dimensions.getGroupings().size(); i++) {
      Reports.GroupingValue groupingValue = dimensions.getGroupings()[i];

      if (groupingValue.getLabel() instanceof Id) {
        uniqueRecordIds.add((Id) groupingValue.getLabel());
      } else {
        throw new AIMBaseException.AIMReportRetrievalException(
          'Invalid Grouping : Report need to be grouped only on Id'
        );
      }
    }

    return uniqueRecordIds;
  }
}
