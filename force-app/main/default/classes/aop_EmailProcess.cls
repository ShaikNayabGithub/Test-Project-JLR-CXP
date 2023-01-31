public class aop_EmailProcess {

    @InvocableMethod(label='Send Emails' description='Sends Emails for requests')
    public static void sendEmail(List<User> users)
    {
        aop_EmailController emailController = new aop_EmailController();

        Set<ID> userContactID = New Set<ID>();

        For (User user : users)
        {
			userContactID.add(user.ContactId);
        }
        


        List<Request__c> requests = [SELECT ID, aop_Status__c, Request_Type__c, language__c, aop_country__c, aop_Customer__c, aop_Source__c
                                    FROM Request__c
                                    WHERE aop_Customer__c In: userContactID And RecordType.DeveloperName !=: 'DMS Request'
                                    ORDER BY CreatedDate ASC
                                    ];  

        If (!requests.isEmpty())
        {

        For (Request__c request : requests)
		{
			If (!users.isEmpty())
        	{
	            If (request.aop_Status__c == System.label.aop_Qualified)
	            {
	                emailController.SendQualifiedEmail(request);
	            }

				//phase 2 disabled
	            /*else if(request.aop_Source__c == System.label.aop_Walk_In && request.aop_Status__c == System.label.aop_No_Qualification_Required)
	            {
	                emailController.SendWalkInEmail(request);
	            }*/
        	}
		}            


}





    }

}