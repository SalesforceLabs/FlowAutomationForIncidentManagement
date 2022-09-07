public class ReportDataRetriever {
  @InvocableMethod(
    label='Get Report RecordIds'
    description='Returns the list of Ids'
  )
  public static List<List<Id>> retrieveRecordCollection(
    List<String> developerNames
  ) {
    List<List<Id>> idList = new List<List<Id>>();

    String devName = developerNames.get(0);

    List<Report> reportList = [
      SELECT Id, DeveloperName
      FROM Report
      WHERE DeveloperName = :devName
      LIMIT 1
    ];

    if (reportList.size() != 0) {
      Set<Id> idSet = ReportUtils.getRecordIds(reportList.get(0).Id);
      if (idSet != null) {
        idList.add(new List<Id>(idSet));
        return idList;
      }
    }

    return null;
  }
}
