@isTest
private class ChatterAnswersEscalationTriggerTest {
    static testMethod void validateQuestionEscalation() {
        Community[] communities = [SELECT Id, Name from Community];
        String communityId = communities[0].Id;
        for(Community c : communities){
            if(c.Name.equalsIgnoreCase('CXP IDEA PLATFORM')){ //in live, we have to select this community
                communityId = c.Id;
            }
        }
        Question q = new Question(Title = 'questionTitle', Body = 'questionBody', CommunityId = communityId);
        insert(q);
        q.Priority = 'High';
        update(q);
        //Test that the escaltion trigger correctly escalates the question to a case
        List<Case> questionCases = [SELECT Origin, CommunityId, Subject, Description from Case where QuestionId = :q.Id];
        System.assertEquals(1, questionCases.size());
    }
}