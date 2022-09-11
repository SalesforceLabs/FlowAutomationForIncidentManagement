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

    return new Set<Id>();
  }

  /**
   * @description   Get data from Ungrouped Tabular Report
   * Report not grouped on any field and Id is present in the first column
   * System will throw exception if it is not able to convert the data to Id and the caller need to handle the exception
   * @param results (Reports.reportResults): Result of Report
   * @return Set<Id>: Set containing Ids of the records present in the Report
   */
  private static Set<Id> getDataFromUngroupedReport(
    Reports.reportResults results
  ) {
    Set<Id> uniqueRecordIds = new Set<Id>();
    List<String> header = new List<String>();

    // Access column Names of the Report
    for (String columnName : results.getReportMetadata().getDetailColumns()) {
      String label = results.getReportExtendedMetadata()
        .getDetailColumnInfo()
        .get(columnName)
        .getLabel();
      header.add(label);
    }

    if (header.get(0).contains(' ID')) {
      // Id is present in first column

      Reports.ReportFactWithDetails factWithDetails = (Reports.ReportFactWithDetails) results.getFactMap()
        .get('T!T');

      for (Reports.ReportDetailRow row : factWithDetails.getRows()) {
        Id value = (Id) row.getDataCells().get(0).getLabel();
        uniqueRecordIds.add(value);
      }
    }
    return uniqueRecordIds;
  }

  /**
   * @description  Get data from Tabular Report grouped on Id
   * System will throw exception if it is not able to convert the data to Id and the caller need to handle the exception
   * @param results (Reports.reportResults): Result of Report
   * @return Set<Id>: Set containing Ids of the records present in the Report
   */
  private static Set<Id> getDataFromGroupedReport(
    Reports.reportResults results
  ) {
    Set<Id> uniqueRecordIds = new Set<Id>();

    Reports.Dimension dimensions = results.getGroupingsDown();

    for (integer i = 0; i < dimensions.getGroupings().size(); i++) {
      Reports.GroupingValue groupingValue = dimensions.getGroupings()[i];
      uniqueRecordIds.add((Id) groupingValue.getValue());
    }

    return uniqueRecordIds;
  }
}
