/**
 * UpdateIncidentStatusFlowTest: Test class for AIM_UpdateIncidentStatus flow
 */
@isTest
private with sharing class UpdateIncidentStatusFlowTest /**
 * testIncidentStatusUpdate: method to test the scneario where Incident Status should be changed
 */ {
  @isTest
  static void testIncidentStatusUpdate() {
    Incident incident = AIM_TestFactory.createIncidents(1)[0];
    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', incident.Id);
    inputs.put('statusTo', 'In Progress');
    inputs.put('statusFrom', 'New');
    Flow.Interview.AIM_UpdateIncidentStatus flowRunner = new Flow.Interview.AIM_UpdateIncidentStatus(
      inputs
    );
    flowRunner.start();
    Test.stopTest();

    List<Incident> incidentsAfterFlowExecution = [
      SELECT Status
      FROM Incident
      WHERE Id = :incident.Id
    ];
    System.assertEquals(
      'In Progress',
      incidentsAfterFlowExecution.get(0)?.Status,
      'Incident Status should have changed.'
    );
  }

  /**
   * testNoIncidentStatusUpdate: method to test the scenario where Incident Status should not change
   */
  @isTest
  static void testNoIncidentStatusUpdate() {
    Incident incident = AIM_TestFactory.createIncidents(1)[0];

    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', incident.Id);
    inputs.put('statusTo', 'In Progress');
    inputs.put('statusFrom', 'Open');
    Flow.Interview.AIM_UpdateIncidentStatus flowRunner = new Flow.Interview.AIM_UpdateIncidentStatus(
      inputs
    );
    flowRunner.start();
    Test.stopTest();

    List<Incident> incidentsAfterFlowExecution = [
      SELECT Status
      FROM Incident
      WHERE Id = :incident.Id
    ];
    System.assertEquals(
      'New',
      incidentsAfterFlowExecution.get(0)?.Status,
      'Incident Status should not have changed.'
    );
  }
}
