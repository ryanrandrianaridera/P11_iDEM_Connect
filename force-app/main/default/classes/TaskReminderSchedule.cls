global without sharing class TaskReminderSchedule implements Schedulable{
    
    //Scheduler to be run on the 1st Monday of every months
    public static String CRON_EXP = '0 0 0 ? * 2#1 *';
    
    global void execute(SchedulableContext sc){
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE Id = :sc.getTriggerId()];
        
        //Action to be run with the batch with the related batch 
        TaskReminderBatch reminder = new TaskReminderBatch();
        database.executeBatch(reminder);
    }
}
