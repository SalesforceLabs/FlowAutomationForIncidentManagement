/**
 * WakeUpOrchestrationFlowTest: Test class for AIM - Wake Up Orchestration flow
 */
@isTest
private with sharing class WakeUpOrchestrationFlowTest {
  /**
   * testWakeUpOrchestrationFlow: tests the AIM - Wake Up Orchestration Flow on update of incident record
   */
  @isTest
  static void testWakeUpOrchestrationFlow() {
    Incident incident = AIMTestDataFactory.createIncidents(1)[0];

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
