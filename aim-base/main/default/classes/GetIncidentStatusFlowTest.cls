/**
 * GetIncidentStatusFlowTest Test class for AIM_GetIncidentStatus flow
 */
@isTest
private with sharing class GetIncidentStatusFlowTest {
  /**
   * testIncidentStatus method to test Incident Status returned by the flow
   */
  @isTest
  static void testIncidentStatus() {
    Incident incident = AIMTestDataFactory.createIncidents(1)[0];

    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', incident.Id);
    Flow.Interview.AIM_GetIncidentStatus flowRunner = new Flow.Interview.AIM_GetIncidentStatus(
      inputs
    );
    flowRunner.start();
    String status = (String) flowRunner.getVariableValue('incidentStatus');
    System.assertEquals(
      'New',
      status,
      'The correct Incident Status is not returned.'
    );
    Test.stopTest();
  }

  /**
   * testStatusForEmptyIncident method to test Incident Status when no incident Id is passed
   */
  @isTest
  static void testStatusForEmptyIncident() {
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', null);
    Flow.Interview.AIM_GetIncidentStatus flowRunner = new Flow.Interview.AIM_GetIncidentStatus(
      inputs
    );
    flowRunner.start();
    String status = (String) flowRunner.getVariableValue('incidentStatus');
    System.assertEquals(
      null,
      status,
      'A null Incident Status should be returned.'
    );
  }
}
