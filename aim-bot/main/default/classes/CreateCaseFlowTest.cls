/**
 * CreateCaseFlowTest This is a test class for AIM Bot - Create Case flow
 */
@isTest
private class CreateCaseFlowTest {
  /**
   * makeData test data
   */
  @TestSetup
  static void makeData() {
    Incident incident = new Incident(
      Subject = 'Test Incident',
      Impact = 'High',
      Urgency = 'High',
      Priority = 'Critical',
      Status = 'New'
    );
    insert incident;
  }

  /**
   * testCreateCaseFlow Unit test to test AIM Bot - Create Case flow
   */
  @isTest
  static void testCreateCaseFlow() {
    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>{
      'incidentId' => [SELECT Id FROM Incident LIMIT 1]
      .Id
    };
    Flow.Interview.AIMBot_CreateCase flowRunner = new Flow.Interview.AIMBot_CreateCase(
      inputs
    );
    flowRunner.start();
    Test.stopTest();

    Case testCase = [
      SELECT Id, (SELECT Id FROM CaseRelatedIssues)
      FROM Case
      LIMIT 1
    ];
    Assert.isNotNull(testCase, 'Case is not created.');
    Assert.isNotNull(
      testCase.CaseRelatedIssues,
      'Case Related Issue is not created.'
    );
  }
}
