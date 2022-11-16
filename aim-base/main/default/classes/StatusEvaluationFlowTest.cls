/**
 * StatusEvaluationFlowTest: Test class for AIM_Status_Evaluation flow
 */
@isTest
private with sharing class StatusEvaluationFlowTest {
  /**
   * testIncidentStatusEvaluationUpdate: method to test the scenario where isOrchestrationConditionMet is true if the status matches input criteria.
   */
  @isTest
  static void testIncidentStatusEvaluationUpdate() {
    Incident incident = AIM_TestFactory.createIncidents(1)[0];
    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', incident.Id);
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
    Incident incident = AIM_TestFactory.createIncidents(1)[0];
    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', incident.Id);
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
