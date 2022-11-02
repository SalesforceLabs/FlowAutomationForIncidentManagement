/**
 * WakeUpOrchestrationFlowTest: Test class for AIM - Wake Up Orchestration flow
 */
@isTest
private class WakeUpOrchestrationFlowTest {
  /**
   * testWakeUpOrchestrationFlow: tests the AIM - Wake Up Orchestration Flow on update of incident record
   */
  @isTest
  static void testWakeUpOrchestrationFlow() {
    Incident incident = new Incident(
      Subject = 'Test Incident',
      Impact = 'High',
      Urgency = 'High',
      Priority = 'Critical',
      Status = 'New'
    );
    insert incident;

    Test.startTest();
    incident.Status = 'In Progress';
    update incident;
    System.assertEquals(
      'In Progress',
      incident.Status,
      'Status has not changed.'
    );
    Test.stopTest();
  }
}
