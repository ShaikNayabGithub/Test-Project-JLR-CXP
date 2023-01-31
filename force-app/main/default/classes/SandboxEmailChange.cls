global class SandboxEmailChange implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        System.debug('Org ID: ' + context.organizationId());
        System.debug('Sandbox ID: ' + context.sandboxId());
        System.debug('Sandbox Name: ' + context.sandboxName());
        
        List<GroupMember> gmList = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'SandboxEmail'];
        
        Set<Id> usrIds = new Set<Id>();
        
        for (GroupMember gm : gmList){
            usrIds.add(gm.UserOrGroupId);
        }
        if (usrIds.size() > 0){
            List<User> uList = [SELECT Id, Email from User WHERE Id in :usrIds ];
            
            for (User u : uList) {
                u.Email = u.Email.replace('.invalid', '');
            }
            if (uList.size() > 0){
                update uList;            
            }
            
        }
        
        
    }
}