/**
 UpdateMilestoneFlowTest: Test class for AIM_UpdateMilestone Flow
 */
@isTest
private with sharing class UpdateMilestoneFlowTest {
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
   * milestoneStatusTest: method to update the milestone associated with the Incident and read the updated status of the milestone
   */
  @isTest
  static void testMilestoneStatus() {
    List<Incident> incidents = [SELECT Id FROM Incident];

    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('incidentId', incidents.get(0).Id);
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
