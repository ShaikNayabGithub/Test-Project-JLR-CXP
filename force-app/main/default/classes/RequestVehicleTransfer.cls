public without sharing class RequestVehicleTransfer {

    public boolean SubmitForApproval (List<Asset> vehicles, String transferNotes, String offerPrice) {

        List<Approval.ProcessSubmitRequest> reqs = new List<Approval.ProcessSubmitRequest>();
        List<Approval.ProcessResult> results = new List<Approval.ProcessResult>();
        
        Id currentUserId = UserInfo.getUserId();
                
        //loop through passed Assets and create an Approval Process for each
        //set Next Approver to the queue id of the Asset's Retailer 
        for (Asset v : vehicles) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(v.Id);
            req.setSubmitterId(currentUserId);
            req.setNextApproverIds(new List<Id>{v.Account.Queue_ID__c});
            req.setProcessDefinitionNameOrId('Vehicle_Request_Approval');
            req.setSkipEntryCriteria(false);
            //include transfer notes, but also need include offer price if this has been specified?
            if(String.IsBlank(offerPrice)){
                req.setComments(transferNotes);
            }
            else{
                req.setComments(System.Label.Stock_Search_Offer_Price + ' ' + offerPrice + '\n\n' + transferNotes);
            }
            reqs.add(req);
        }

        //submit approval processes
        try{
            results = Approval.process(reqs); //do we need to do anything with the results?
        }
        catch(Exception e){
            System.debug('Exception thrown while submitting assets for approval');
            System.debug(e);
            ApexPages.addMessages(e);
            return false;
        }

        try {
            List<Id> vehiclesWithSuccesfullySubmittedRequests = new List<Id>();

            for (Integer i = 0; i < results.size() && i < vehicles.size(); ++i) {
                if (results[i].isSuccess()) {
                    vehiclesWithSuccesfullySubmittedRequests.add(vehicles.get(i).Id);
                }
            }

            prepareAndSendEmails(vehiclesWithSuccesfullySubmittedRequests, transferNotes, offerPrice, currentUserId);
        }
        catch (Exception e) {
            System.debug('Exception thrown while sending emails');
            System.debug(e);
            ApexPages.addMessages(e);

            return false;
        }

        return true;
    }

    
    @future(callout=true) 
    private static void prepareAndSendEmails(List<Id> vehicleIds, String transferNotes, String offerPrice, Id requestorUserId) {
        List<Asset> vehicles = getAssets(vehicleIds, VehicleTransferRequestEmailRenderer.RequiredFields.get('asset'));

        List<List<Messaging.SingleEmailMessage>> messages = new List<List<Messaging.SingleEmailMessage>>();
        Map<Id, ApprovalRequestDetails> approvalRequestDetailsMappedToQueueId = getApprovalRequestDetailsMappedToQueueId(vehicles, requestorUserId);

        for (Asset v : vehicles) {
            if (approvalRequestDetailsMappedToQueueId.containsKey(v.Account.Queue_ID__c)) {
                messages.add(createApprovalEmails(v, transferNotes, approvalRequestDetailsMappedToQueueId.get(v.Account.Queue_ID__c)));
            }
        }

        sendEmails(messages);
    }

    private static Map<Id, ApprovalRequestDetails> getApprovalRequestDetailsMappedToQueueId(List<Asset> vehicles, Id requestorUserId) {
        List<Id> queueIds = new List<Id>();

        for (Asset vehicle : vehicles) {
            if (vehicle != null && vehicle.Account != null && !String.isBlank(vehicle.Account.Queue_ID__c))
            queueIds.add(vehicle.Account.Queue_ID__c);
        }

        Map<Id, ApprovalRequestDetails> approvalRequestDetailsMappedToQueueId = new Map<Id, ApprovalRequestDetails>();

        List<Id> userIds = new List<Id> {requestorUserId};

        for (Group queue : [SELECT Id, DoesSendEmailToMembers, Email,
                                        (SELECT UserOrGroupId
                                         FROM GroupMembers)
                            FROM Group
                            WHERE Id IN :queueIds]) {

            if (queue.GroupMembers.size() == 0) {
                continue;
            }

            ApprovalRequestDetails details = new ApprovalRequestDetails(queue.GroupMembers[0].UserOrGroupId, queue.Email);

            for (GroupMember gm : queue.GroupMembers) {
                details.AddUserId(gm.UserOrGroupId);
            }

            userIds.addAll(details.UserIds);

            approvalRequestDetailsMappedToQueueId.put(queue.Id, details);
        }

        Map<Id, User> users = getUsers(userIds, VehicleTransferRequestEmailRenderer.RequiredFields.get('user'));

        Set<String> languageSet = new Set<String>();

        for (ApprovalRequestDetails details : approvalRequestDetailsMappedToQueueId.values()) {
            details.Requestor = users.get(requestorUserId);
            for (Id userId : details.UserIds) {
                if (users.containsKey(userId)) {
                    User userRecord = users.get(userId);
                    if (!languageSet.contains(userRecord.LanguageLocaleKey)) {
                        languageSet.add(userRecord.LanguageLocaleKey);
                    }
                    details.addUser(userRecord);
                }
            }
        }

        VehicleTransferRequestEmailRenderer.initialiseLanguage(languageSet);

        return approvalRequestDetailsMappedToQueueId;
    }

    private static List<Messaging.SingleEmailMessage> createApprovalEmails(Asset vehicle, String transferNotes, ApprovalRequestDetails details) {

        if (details == null) return null;

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        if (details.Users.size() == 0) {
            return messages;
        }

        if (!String.isBlank(details.GroupEmail)) {
            messages.add(createApprovalEmail(vehicle, details.Requestor, details.Users[0], transferNotes, details.GroupEmail));
        }

        for (User user : details.Users) {
            messages.add(createApprovalEmail(vehicle, details.Requestor, user, transferNotes, user.Email));
        }       
        
        return messages;
    }

    private static Messaging.SingleEmailMessage createApprovalEmail(Asset vehicle, User requestor, User approver, String transferNotes, String emailAddress) {

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        VehicleTransferRequestEmailRenderer renderer = new VehicleTransferRequestEmailRenderer(requestor, approver, vehicle, transferNotes, approver.LanguageLocaleKey);

        VehicleTransferRequestEmailRenderer.EmailContent emailContact = renderer.Render();

        email.setToAddresses(new List<String> {emailAddress});
        email.setSubject(emailContact.Subject);
        email.setHtmlBody(emailContact.HtmlContent);
        email.setPlainTextBody(emailContact.TextContent);

        return email;
    }

    private static void sendEmails(List<List<Messaging.SingleEmailMessage>> emails) {
        List<Messaging.SingleEmailMessage> flattenedList = new List<Messaging.SingleEmailMessage>();

        for (List<Messaging.SingleEmailMessage> emailList : emails) {
            flattenedList.addAll(emailList);
        }

        if(!Test.IsRunningTest()) Messaging.sendEmail(flattenedList, true);
    }

    private class ApprovalRequestDetails {
        private Id GroupId;
        private String GroupEmail;
        private List<Id> UserIds;
        private List<User> Users;
        private User Requestor;

        public ApprovalRequestDetails(Id groupId, String groupEmail) {
            this.GroupId = groupId;
            this.GroupEmail = groupEmail;
            this.UserIds = new List<Id>();
            this.Users = new List<User>();
        }

        public void AddUserId(Id userId) {
            this.UserIds.add(userId);
        }

        public void AddUser(User record) {
            if (!String.isBlank(record.Email)) {
                this.Users.add(record);
            }
        }
    }

    private static Map<Id, User> getUsers(List<Id> userIds, Set<String> fields) {

        String query = 'SELECT Id, LanguageLocaleKey, UserType, Email {0} FROM User WHERE Id IN :UserIds';

        String concatFields = '';

        for (String field : fields) {
            if (field.toLowerCase() != 'id' && field.toLowerCase() != 'languagelocalekey' && field.toLowerCase() != 'usertype' && field.toLowerCase() != 'email') {
                concatFields += ', ' + String.escapeSingleQuotes(field);
            }
        }

        query = String.format(query, new List<String> {concatFields});

        return new Map<Id, User>((List<User>)Database.query(query));
    }

    private static List<Asset> getAssets(List<Id> assetIds, Set<String> fields) {

        String query = 'SELECT Id, Name, Account.Queue_ID__c {0} FROM Asset WHERE Id IN :assetIds';

        String concatFields = '';

        if (fields != null && fields.size() > 0) {
            for (String field : fields) {
                if (field.toLowerCase() != 'id' && field.toLowerCase() != 'name' && field.toLowerCase() != 'account.queue_id__c') {
                    concatFields += ', ' + String.escapeSingleQuotes(field);
                }
            }
        }

        query = String.format(query, new List<String> {concatFields});

        return (List<Asset>)Database.query(query);
    }

}