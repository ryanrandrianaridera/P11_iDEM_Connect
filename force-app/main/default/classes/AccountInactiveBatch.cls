global with sharing class AccountInactiveBatch {
    global Database.QueryLocator start(Database.BatchableContext info) {
		// List Inactive Accounts (without Order)
		return Database.getQueryLocator('SELECT Id, OwnerId, (SELECT Id FROM Tasks WHERE Subject = \'Call\') FROM Account WHERE Active__c = false');
       // return Database.getQueryLocator('SELECT Id, Name,Owner.Id, (SELECT WhatId, Status, Subject, Priority FROM Tasks WHERE Subject = \'Call\')FROM Account WHERE Id NOT IN (SELECT AccountId FROM Order)');
    }
    global void execute(Database.BatchableContext info, List<Account> scope) {

        //Lister les comptes et créer un reminder task
      List<Account> accountNoTask = new List<Account>();
      
      }
    	

	global void finish(Database.BatchableContext info) {
	}
    
}
