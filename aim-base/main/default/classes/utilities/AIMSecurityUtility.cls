/**
 * AIMSecurityUtility Security Utils for checking current user Object and Field level access
 */
public with sharing class AIMSecurityUtility {
  /**
   * checkReadAccess method to check read access to the provided field
   *
   * @param sObjectAPIName (String): API name of the object
   * @param fieldAPIName (String): API name of the field
   *
   * @return Boolean: user access
   */
  public static Boolean checkReadAccess(
    String sObjectAPIName,
    String fieldAPIName
  ) {
    Boolean isAccessible = false;
    List<Schema.DescribeSObjectResult> describeSObjectResult = System.Schema.describeSObjects(
      new List<String>{ sObjectAPIName }
    );
    if (
      !describeSObjectResult.isEmpty() && describeSObjectResult.get(0) != null
    ) {
      Map<String, Schema.SObjectField> fields = describeSObjectResult.get(0)
        .fields.getMap();
      Schema.DescribeFieldResult describeFieldResult = fields.get(
          fieldAPIName.toLowerCase()
        )
        ?.getDescribe();
      if (describeFieldResult != null) {
        isAccessible = describeFieldResult.isAccessible();
      }
    }
    return isAccessible;
  }
}
