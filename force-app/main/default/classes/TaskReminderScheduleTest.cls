@IsTest
private class TaskReminderScheduleTest {
    //CRON_EXP is the next time this schedule will run
    public static String CRON_EXP = '0 0 0 ? * 2#1';
    
    @TestSetup
    static void setupData() {
        List<Account> acct = TestDataFactory.createAccounts(5);
    }
    
    //description test the Scheduled Job
    
    @IsTest
    static void testScheduledJob() {      
        
        
        Test.startTest();
        
        String jobId = System.schedule('ScheduleApexTest',
                                       CRON_EXP,
                                       new TaskReminderSchedule());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime,CronJobDetailId,State FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.debug(ct.TimesTriggered);
        System.debug(ct.NextFireTime);
        System.debug(ct.State);
        
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
    }
}