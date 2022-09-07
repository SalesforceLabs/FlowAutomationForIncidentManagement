/**
 @description Test class for ReportDataRetriever Class
 */
public class ReportUtils {
  /**
   * @description  method to get the record Ids from Report
   * @param reportId (Id): Id of the Report
   * @return Set<Id>: Set containing Ids of the records present in the Report
   */
  public static Set<Id> getRecordIds(Id reportId) {
    Reports.reportResults results = Reports.ReportManager.runReport(
      reportId,
      true
    );
    Reports.Dimension dim = results.getGroupingsDown();

    integer size = dim.getGroupings().size();
    // size is not zero means it is a grouped report
    if (size != 0) {
      return getDataFromGroupedReport(results);
    } else if (size == 0) {
      return getDataFromUngroupedReport(results);
    }

    return null;
  }

  /**
   * @description  method to get data from Ungrouped Tabular Report
   * Report not grouped on any field and Id is present in the first column
   * @param results (Reports.reportResults): Result of Report
   * @return Set<Id>: Set containing Ids of the records present in the Report
   */
  private static Set<Id> getDataFromUngroupedReport(
    Reports.reportResults results
  ) {
    Set<Id> recordIds = new Set<Id>();
    List<String> header = new List<String>();

    // Access column Names of the Report
    for (String colName : results.getReportMetadata().getDetailColumns()) {
      String label = results.getReportExtendedMetadata()
        .getDetailColumnInfo()
        .get(colName)
        .getLabel();
      header.add(label);
    }

    if (header.get(0).contains(' ID')) {
      // Id is present in first column

      try {
        Reports.ReportFactWithDetails factWithDetails = (Reports.ReportFactWithDetails) results.getFactMap()
          .get('T!T');

        for (Reports.ReportDetailRow row : factWithDetails.getRows()) {
          Id value = (Id) row.getDataCells().get(0).getLabel();
          recordIds.add(value);
        }
      } catch (Exception e) {
        // Id is not present in first column and some other field is present

        return null;
      }
    } else {
      return null;
    }
    return recordIds;
  }

  /**
   * @description  method to get data from Tabular Report grouped on Id
   * Report grouped on Id
   * @param results (Reports.reportResults): Result of Report
   * @return Set<Id>: Set containing Ids of the records present in the Report
   */
  private static Set<Id> getDataFromGroupedReport(
    Reports.reportResults results
  ) {
    Set<Id> recordIds = new Set<Id>();
    try {
      Reports.Dimension dim = results.getGroupingsDown();

      for (integer i = 0; i < dim.getGroupings().size(); i++) {
        Reports.GroupingValue groupingVal = dim.getGroupings()[i];
        recordIds.add((Id) groupingVal.getValue());
      }
    } catch (Exception e) {
      //report not grouped by Id and is grouped by some other field
      return null;
    }

    return recordIds;
  }
}
