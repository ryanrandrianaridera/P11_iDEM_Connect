@isTest
private class TaskReminderBatchTest {
    @TestSetup
    static void setupData(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
        ];
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'MyTestRole');
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Los_Angeles',
                          UserName = uniqueUserName,
                          UserRoleId = r.Id
                         );
        System.runAs(u) {
            List<Account> accounts = TestDataFactory.createAccounts(200);            
        }
    }
    
    @IsTest
    static void ReminderForAccountInactivityBatchTest(){
        
        Test.startTest();
        TaskReminderBatch reminder = new TaskReminderBatch();
        Id batchId = Database.executeBatch(reminder);
        Test.stopTest();
        
        List<Task> myTasksReminder = [
            SELECT WhatId, Status, Subject, Priority, OwnerId, IsReminderSet, ReminderDateTime
            FROM Task
            WHERE Subject = 'Call' AND OwnerId IN (
                SELECT Id
                FROM User
                WHERE Alias LIKE 'standt')
        ];
        
        System.assertEquals(200, myTasksReminder.size());
        
        for (Task task : myTasksReminder) {
            System.assertEquals(task.Subject, 'Call', 'The task subject should be a call reminder');
            System.assertEquals(task.Status, 'Not Started', 'The tasks status should be new');
            System.assertEquals(task.Priority, 'Normal');
            System.assertEquals(task.IsReminderSet, true);
            System.assertEquals(task.ReminderDateTime, Date.today().addDays(5));
        }
    }
    @IsTest
    static void ReminderActiveOrdersAccountBatchTest() {
        List<Account> accts = [SELECT Id From Account WHERE Name LIKE 'TestAccount_%' Limit 5];
        Product2 productOne = TestDataFactory.createProduct('TestItem', 'Prestation');
        PricebookEntry priceBook = TestDataFactory.createPricebookEntry(productOne.Id, 1020);
        List<Order> ord = TestDataFactory.createOrders(2, accts, priceBook);
        
        Test.startTest();
        TaskReminderBatch reminder = new TaskReminderBatch();
        Id batchId = Database.executeBatch(reminder);
        Test.stopTest();
        List <Task> myTasksReminder = [
            SELECT WhatId, Status, Subject, Priority, OwnerId, IsReminderSet, ReminderDateTime
            FROM Task
            WHERE Subject = 'call' AND OwnerId IN (
                SELECT Id
                FROM User
                WHERE Alias LIKE 'standt'
            )
        ];
        System.debug(myTasksReminder);
        System.assertEquals(195, myTasksReminder.size());//half of created account has orders
        for (Task task : myTasksReminder) {
            System.assertEquals(task.Subject, 'Call', 'The task subject should be a call reminder');
            System.assertEquals(task.Status, 'Not Started', 'The tasks status should be new');
            System.assertEquals(task.Priority, 'Normal');
            System.assertEquals(task.IsReminderSet, true);
            System.assertEquals(task.ReminderDateTime, Date.today().addDays(5));
        }
        
        System.debug(myTasksReminder);
    }
    static void ReminderActiveTasksAccountBatchTest() {
        List<Account> accts = [SELECT Id From Account WHERE Name LIKE 'TestAccount_%' Limit 10];
        for (Account account : accts){
            TestDataFactory.createReminderTaskForAccount(account);
        }
        
        Test.startTest();
        TaskReminderBatch reminder = new TaskReminderBatch();
        Id batchId = Database.executeBatch(reminder);
        Test.stopTest();
        
        System.assertEquals(10, [SELECT COUNT() FROM Task], 'Bad Tasks count');
    }
}