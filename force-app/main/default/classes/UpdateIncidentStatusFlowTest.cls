/**
 * UpdateIncidentStatusFlowTest: Test class for AIM_UpdateIncidentStatus flow
 */
@isTest
private with sharing class UpdateIncidentStatusFlowTest {
  @TestSetup
  static void createIncident() {
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
   * testIncidentStatusUpdate: method to test the scneario where Incident Status should be changed
   */
  @isTest
  static void testIncidentStatusUpdate() {
    List<Incident> incidents = [SELECT Id, Status FROM Incident];

    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', incidents.get(0).Id);
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
      WHERE Id = :incidents.get(0).Id
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
    List<Incident> incidents = [SELECT Id, Status FROM Incident];

    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', incidents.get(0).Id);
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
      WHERE Id = :incidents.get(0).Id
    ];
    System.assertEquals(
      'New',
      incidentsAfterFlowExecution.get(0)?.Status,
      'Incident Status should not have changed.'
    );
  }
}
