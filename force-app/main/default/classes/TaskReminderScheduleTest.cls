@IsTest
private class TaskReminderScheduleTest {
    //CRON_EXP is the next time this schedule will run
    public static String CRON_EXP = '0 0 0 ? * 2#1';
    public static String JOB_NAME = 'Scheduled Apex Test';
    
    //Description test the Scheduled Job    
    @IsTest
    static void testScheduledJob() {  
        //Create some accounts without related orders (they have no related call tasks either)
        List<Account> acct  = TestDataFactory.createAccounts(10);
        
        //Get the IDs of the accounts we just inserted
        List<Id> accountIds = new List<Id>(new Map<Id, Account>(acct).keySet());   
        
        Test.startTest();        
        String jobId = System.schedule(JOB_NAME,
                                       CRON_EXP,
                                       new TaskReminderSchedule());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime,CronJobDetailId,State FROM CronTrigger WHERE id = :jobId];
        
        //Verify the Scheduled Apex job exists
        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM CronTrigger
                WHERE CronJobDetail.JobType = '7' AND CronJobDetail.Name = :JOB_NAME
            ]
        );
        
        //Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
        //Verify the scheduled job has not run yet.
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals(
            0,
            [SELECT Id FROM Task WHERE WhatId IN :accountIds].size(),
            'Tasks exist before job has run'
        );
        System.debug(ct.TimesTriggered);
        System.debug(ct.NextFireTime);
        System.debug(ct.State);
        
        //Calculate expected job run date
        Date jobRunDate = Date.today()
            .addMonths(1)
            .toStartOfMonth()
            .toStartOfWeek();
        
        //Add a week if "first Monday" is in last month
        if (jobRunDate < date.today().addMonths(1).toStartOfmonth()) {
            jobRunDate = jobRunDate.addDays(7);
        }
        
        //Verify the next date the job will run
        System.assertEquals(jobRunDate, ct.NextFireTime.date());
        
        
        // Stopping the test will run the job synchronously
        Test.stopTest();        
    }
}