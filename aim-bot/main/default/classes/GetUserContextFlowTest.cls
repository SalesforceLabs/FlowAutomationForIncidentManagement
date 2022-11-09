/**
 * GetUserContextFlowTest This is a test class to test AIM Bot - Get User Context flow
 */
@isTest
private class GetUserContextFlowTest {
  /**
   * testGetUserContextFlow test method to test AIM Bot - Get User Context flow
   */
  @isTest
  static void testGetUserContextFlow() {
    Test.startTest();
    Map<String, Object> inputs = new Map<String, Object>{
      'routableId' => null,
      'networkId' => null
    };
    Flow.Interview.AIMBot_GetUserContext flowRunner = new Flow.Interview.AIMBot_GetUserContext(
      inputs
    );
    flowRunner.start();
    Test.stopTest();

    Assert.isNull((String) flowRunner.getVariableValue('bannerText'));
  }
}
