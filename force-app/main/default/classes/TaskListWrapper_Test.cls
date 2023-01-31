@isTest
public class TaskListWrapper_Test {
    static testmethod void test1(){
        TaskListWrapper[] taskList = new List<TaskListWrapper>();
        
        HomePageRecordListControllerAU.ActivityWrapper FirstActivityWrapper = new HomePageRecordListControllerAU.ActivityWrapper();
        FirstActivityWrapper.ActivityDate = Date.today().addDays(10);
        FirstActivityWrapper.Id = '1';
        
        HomePageRecordListControllerAU.TaskInfoListWrapper FirstTaskWrapper = new HomePageRecordListControllerAU.TaskInfoListWrapper();
        FirstTaskWrapper.objTask = FirstActivityWrapper;
        
        HomePageRecordListControllerAU.ActivityWrapper SecondActivityWrapper = new HomePageRecordListControllerAU.ActivityWrapper();
        SecondActivityWrapper.ActivityDate = Date.today().addDays(9);
        SecondActivityWrapper.Id = '2';
        
        HomePageRecordListControllerAU.TaskInfoListWrapper SecondTaskWrapper = new HomePageRecordListControllerAU.TaskInfoListWrapper();
        SecondTaskWrapper.objTask = SecondActivityWrapper;
        
        HomePageRecordListControllerAU.ActivityWrapper ThirdActivityWrapper = new HomePageRecordListControllerAU.ActivityWrapper();
        ThirdActivityWrapper.ActivityDate = Date.today().addDays(8);
        ThirdActivityWrapper.Id = '3';
        
        HomePageRecordListControllerAU.TaskInfoListWrapper ThirdTaskWrapper = new HomePageRecordListControllerAU.TaskInfoListWrapper();
        ThirdTaskWrapper.objTask = ThirdActivityWrapper;
        
        taskList.add(new TaskListWrapper(FirstTaskWrapper));
        taskList.add(new TaskListWrapper(SecondTaskWrapper));
        taskList.add(new TaskListWrapper(ThirdTaskWrapper));
        
        taskList.sort();
        
        System.assertEquals('3', taskList[0].TaskList.objTask.Id);
        System.assertEquals(Date.today().addDays(8), taskList[0].TaskList.objTask.ActivityDate);
        System.assertEquals('2', taskList[1].TaskList.objTask.Id);
        System.assertEquals(Date.today().addDays(9), taskList[1].TaskList.objTask.ActivityDate);
        System.assertEquals('1', taskList[2].TaskList.objTask.Id);
        System.assertEquals(Date.today().addDays(10), taskList[2].TaskList.objTask.ActivityDate);
        
        
    }
}