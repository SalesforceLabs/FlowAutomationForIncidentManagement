public static void enableKnowledgeUser() {
  User u = [SELECT Id, UserPermissionsKnowledgeUser FROM User WHERE Id = :System.UserInfo.getUserId()];
  u.UserPermissionsKnowledgeUser = true;
  update u;
}