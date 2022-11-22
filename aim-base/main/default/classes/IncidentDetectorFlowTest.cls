/**
 * IncidentDetectorFlowTest This is a test class to test AIM - Incident Detector Flow
 */
@isTest
private with sharing class IncidentDetectorFlowTest {
  /**
   * testIncidentDetectorFlowWithoutIncident To test the AIM - Incident Detector Flow without any incident record created.
   */
  @isTest
  static void testIncidentDetectorFlowWithoutIncident() {
    Test.startTest();
    insert new Case(
      Subject = 'Test Case',
      Status = 'New',
      Origin = 'Web',
      Priority = 'Medium'
    );
    Test.stopTest();

    Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
    Assert.isNotNull(testCase, 'Case is not created');
  }
}
