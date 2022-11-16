/**
 UpdateMilestoneFlowTest: Test class for AIM_UpdateMilestone Flow
 */
@isTest
private with sharing class UpdateMilestoneFlowTest {
  /**
   * milestoneStatusTest: method to update the milestone associated with the Incident and read the updated status of the milestone
   */
  @isTest
  static void testMilestoneStatus() {
    Incident incident = TestFactory.createIncidents(1)[0];
    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', incident.Id);
    inputs.put('milestoneName', 'Milestone Test');
    inputs.put('markComplete', true);
    Flow.Interview.AIM_UpdateMilestone flowRunner = new Flow.Interview.AIM_UpdateMilestone(
      inputs
    );
    flowRunner.start();
    Test.stopTest();
    Assert.areEqual(
      false,
      (boolean) flowRunner.getVariableValue('isMilestoneCompleted'),
      'Milestone Completed status should be false'
    );
  }
}
