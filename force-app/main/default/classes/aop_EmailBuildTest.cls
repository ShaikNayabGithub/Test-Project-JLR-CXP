@isTest
public class aop_EmailBuildTest {
    
        static TestMethod void TestBuildEmailRuns()
        {
            ID targetObjId;
            ID emailTemplateId;
            aop_EmailBuild emailBuilder = new aop_EmailBuild();
            emailBuilder.BuildEmail(targetObjId, emailTemplateId);
        }
    
        static TestMethod void TestBuildMassEmailRuns()
        {
            List<ID> targetObjIdList;
            ID emailTemplateID;
            aop_EmailBuild emailBuilder = new aop_EmailBuild();
            emailBuilder.BuildMassEmail(targetObjIdList, emailTemplateID);
        }

    

}