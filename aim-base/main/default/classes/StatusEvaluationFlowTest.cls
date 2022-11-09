/**
 * StatusEvaluationFlowTest: Test class for AIM_Status_Evaluation flow
 */
@isTest
private with sharing class StatusEvaluationFlowTest {
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
   * testIncidentStatusEvaluationUpdate: method to test the scenario where isOrchestrationConditionMet is true if the status matches input criteria.
   */
  @isTest
  static void testIncidentStatusEvaluationUpdate() {
    List<Incident> incidents = [SELECT Id, Status FROM Incident];

    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', incidents.get(0).Id);
    inputs.put('statusValue', 'New');
    inputs.put('isCheckEquality', true);
    Flow.Interview.AIM_Status_Evaluation flowRunner = new Flow.Interview.AIM_Status_Evaluation(
      inputs
    );
    flowRunner.start();
    Test.stopTest();

    Boolean isOrchestrationConditionMet = (Boolean) flowRunner.getVariableValue(
      'isOrchestrationConditionMet'
    );
    Assert.areEqual(
      true,
      isOrchestrationConditionMet,
      'The isOrchestrationConditionMet should be true.'
    );
  }

  /**
   * testNoIncidentStatusEvaluationUpdate: method to test the scenario where isOrchestrationConditionMet is false if the status matches input criteria.
   */
  @isTest
  static void testNoIncidentStatusEvaluationUpdate() {
    List<Incident> incidents = [SELECT Id, Status FROM Incident];

    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', incidents.get(0).Id);
    inputs.put('statusValue', 'In Progress');
    inputs.put('isCheckEquality', true);
    Flow.Interview.AIM_Status_Evaluation flowRunner = new Flow.Interview.AIM_Status_Evaluation(
      inputs
    );
    flowRunner.start();
    Test.stopTest();

    Boolean isOrchestrationConditionMet = (Boolean) flowRunner.getVariableValue(
      'isOrchestrationConditionMet'
    );
    Assert.areEqual(
      false,
      isOrchestrationConditionMet,
      'The isOrchestrationConditionMet should be false.'
    );
  }
}
