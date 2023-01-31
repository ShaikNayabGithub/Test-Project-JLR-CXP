global class TaskListWrapper implements Comparable {
	public HomePageRecordListControllerAU.TaskInfoListWrapper TaskList;
    public TaskListWrapper(HomePageRecordListControllerAU.TaskInfoListWrapper tlist)
    {
        TaskList = tlist;
    }
    
    global Integer compareTo(Object compareTo) {
        TaskListWrapper compareToTaskList = (TaskListWrapper)compareTo;
        
        Integer returnValue = 0;
        if(TaskList.objTask.ActivityDate > compareToTaskList.TaskList.objTask.ActivityDate){
            returnValue = 1;
        }
        else if(TaskList.objTask.ActivityDate < compareToTaskList.TaskList.objTask.ActivityDate){
            returnValue = -1;
        }
        else if((TaskList.objTask.ActivityDate == null) && (compareToTaskList.TaskList.objTask.ActivityDate != null)){
            returnValue = -1;
        }
        else if((TaskList.objTask.ActivityDate != null) && (compareToTaskList.TaskList.objTask.ActivityDate == null)){
            returnValue = 1;
        }
        return returnValue;
    }
}