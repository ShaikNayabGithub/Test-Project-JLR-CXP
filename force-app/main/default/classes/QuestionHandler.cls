public with sharing class QuestionHandler {
    public void PostUpdate(List<Question> questions, Map<Id, Question> oldQuestions) {
        CaseFromQuestionCreator caseFromQuestionCreator = new CaseFromQuestionCreator();

        caseFromQuestionCreator.CreateHighPriorityCases(questions, oldQuestions);
    }
}