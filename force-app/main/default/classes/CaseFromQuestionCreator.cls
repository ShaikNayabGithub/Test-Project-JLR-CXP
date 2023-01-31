public with sharing class CaseFromQuestionCreator {
    public void CreateHighPriorityCases(List<Question> questions, Map<Id, Question> oldQuestions) {
        Set<Id> highPriorityQuestionIds = RetrieveHighPriorityQuestionIds(questions, oldQuestions);
        List<Question> highPriorityQuestions = RetrieveExpandedQuestions(highPriorityQuestionIds);
        List<Case> newCases = BuildCases(highPriorityQuestions);

        Database.insert(newCases, false);
    }


    private Set<Id> RetrieveHighPriorityQuestionIds(List<Question> questions, Map<Id, Question> oldQuestions) {
        Set<Id> highPriorityQuestionIds = new Set<Id>();

        for(Question question : questions) {
            if (question.Priority == 'high' && (question.Cases == null || question.Cases.Size() == 0) && 
                    oldQuestions.get(question.Id).Priority != 'high') {
                highPriorityQuestionIds.Add(question.Id);
            }
        }

        return highPriorityQuestionIds;
    }

    private List<Question> RetrieveExpandedQuestions(Set<Id> questionIds) {
        return [SELECT Id, Title, Body, CommunityId, createdById, createdBy.AccountId, 
                createdBy.ContactId FROM Question WHERE Id IN:questionIds];
    }

    private List<Case> BuildCases(List<Question> questions) {
        List<Case> newCases = new List<Case>();

        for(Question question : questions) {
            Case newCase = new Case(Origin='Chatter Answers', 
                OwnerId=question.CreatedById, 
                QuestionId=question.Id, 
                CommunityId=question.CommunityId, 
                Subject=question.Title, 
                Description=question.Body, 
                AccountId=question.CreatedBy.AccountId, 
                ContactId=question.CreatedBy.ContactId);

            newCases.add(newCase);
        }

        return newCases;
    }
}