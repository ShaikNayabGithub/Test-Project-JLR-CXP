public class aop_GameResultTriggerLogic {
   /* 
    public void MapGameResultRelationship(aop_Game_Result__c[] gameResults)
    {
      for (aop_Game_Result__c gr: gameResults)
      {
         if(gr.aop_Booking_Id__c != null)
         {
             CampaignMember cm = [Select Id, CampaignId, ContactId From CampaignMember where aop_Booking_id__c = :gr.aop_Booking_Id__c];
             Contact customer = [Select Name From Contact where Id = :cm.ContactId];
             if(cm != null)
             {  
                gr.aop_Customer__c = cm.ContactId;
                gr.aop_Event__c = cm.CampaignId;
                gr.Name = string.valueof(gr.aop_Run_Number__c)+' - ' + customer.Name;
             }
          }
        //select cm where booking id
       }
    } */
}