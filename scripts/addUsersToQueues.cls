public static void addUsersToQueues() {
    List<GroupMember> members = new List<GroupMember>();
    String userId = System.UserInfo.getUserId();
    for(Group queue : [SELECT Id FROM Group WHERE Type = 'Queue']) {
        members.add(new GroupMember(
            UserOrGroupId = userId,
            GroupId = queue.Id
        ));
    }

    if(! members.isEmpty()) {
        insert members;
    }
}