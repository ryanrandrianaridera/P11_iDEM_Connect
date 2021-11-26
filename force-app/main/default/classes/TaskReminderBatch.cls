global class TaskReminderBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext info) {
        //Select Account with no Order and Account Checkbox field not checked
        String query = 'SELECT Id, OwnerId, (SELECT Id FROM Tasks WHERE Subject = \'Call\') FROM Account WHERE Active__c = false';
        return Database.getQueryLocator(query);  
    }
    global void execute(Database.BatchableContext info, List<Account> scope) {
        HandlerManager.checkCallTasks(scope);
    }
    
    global void finish(Database.BatchableContext info) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :info.getJobId()
        ];
    }
}