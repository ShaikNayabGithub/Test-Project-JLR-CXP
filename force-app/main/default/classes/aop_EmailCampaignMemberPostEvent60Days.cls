public class aop_EmailCampaignMemberPostEvent60Days {

    @InvocableMethod(label='Send Emails' description='Sends Emails for CampaignMembersPostEvent60Days')
    public static void sendEmail(List<CampaignMember> campaignMembers)
    {
        aop_EmailController emailController = new aop_EmailController();

        Set<ID> campaignMemberCampaignIds = new Set<ID>();
        Set<ID> campaignMemberContactIds = new Set<ID>();


        for(CampaignMember cm : campaignMembers)
        {
            campaignMemberCampaignIds.add(cm.CampaignId);
            campaignMemberContactIds.add(cm.ContactId);
        }

        List<aop_Game_Result__c> GameResults = [SELECT ID
                                                   FROM aop_Game_Result__c
                                                   WHERE aop_Customer__c IN: campaignMemberContactIds AND aop_Event__c IN: campaignMemberCampaignIds 
                                                   AND aop_Viewed_Results__c =: true];
        
        System.debug('campaignMemberCampaignIds ' +  campaignMemberCampaignIds +'campaignMemberContactIds ' + campaignMemberContactIds +'GameResults ' + GameResults);
        if(GameResults.isEmpty())
        {
            List<Contact> Contacts = [SELECT ID, Name, Language__c, aop_Country__C
                                     FROM Contact
                                     WHERE ID IN: campaignMemberCampaignIds
                                    ];

            if(Contacts.size() > 0)
            {
            	for(Contact c : Contacts)
	        	{
                	emailController.CampaignCompleteSixtyDays(c);
	        	}
            }
        }

    }

}