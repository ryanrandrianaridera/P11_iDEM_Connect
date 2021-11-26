public with sharing class HandlerManager {
    //Show Error Message if an Order have no item product
    public static void checkActivatedOrders(Map<Id, Order> newMap, Map<Id, Order> oldMap) {
        Set<Id> orderIds = new Set<Id>();       
        for (Order order : [SELECT Id, (SELECT Id FROM OrderItems) FROM Order WHERE Id IN :newMap.keySet()]) {        
            if (order.OrderItems.size() == 0 && newMap.get(order.Id).Status == 'Activated' &&
                newMap.get(order.Id).Status != oldMap.get(order.Id).Status) {         
                    orderIds.add(order.Id);
                }
        }        
        for (Order newOrder : newMap.values()) {
            if (orderIds.contains(newOrder.Id)) {
                newOrder.addError('Please add least one product to the order before changing status');
            }
        }
    }
    
    //List Account with Order and check the Account Checkbox field Active__c
    public static void setOrdersAccountActive(List<Order> createOrders){
        Set<Id> accountsIds = new Set<Id>();
        for (Order order : createOrders) {
            accountsIds.add(order.AccountId);
        } 
        List<Account> accountsToActivate = new List<Account>();
        for (Account account : [SELECT Id,(SELECT Id FROM Orders) FROM Account WHERE Id IN :accountsIds]) {
            if (account.Orders.size() > 0) {
                account.Active__c = true;
                accountsToActivate.add(account);
            }
        }
        if (accountsToActivate.size() > 0) update accountsToActivate;
    }
    
    //List Inactive Account with No Order and unchecked the Account Checkbox field Active_c
    public static void checkAccountsForOrders(List<Order> deletedOrders){
        Set<Id> accountsIds = new Set<Id>();
        for (Order order : deletedOrders) {
            accountsIds.add(order.AccountId);
        }
        List<Account> accountsToUpdate = new List<Account>();
        for (Account account : [SELECT Id, (SELECT Id FROM Orders) FROM Account WHERE Id IN :accountsIds]) {
            if (account.Orders.size() == 0) {
                account.Active__c = false;
                accountsToUpdate.add(account);
            }
        }
        if (accountsToUpdate.size() > 0) update accountsToUpdate;		
    }
    
    //List Account with no orders and no tasks and create task reminder
    public static void checkCallTasks(List<Account> createTasks){    
        List<Account> accountsWithoutTask = new List<Account>();
        for (Account account : createTasks) {
            if (account.Orders.size() == 0 && account.Tasks.size() == 0) {
                accountsWithoutTask.add(account);
            }
        }
        if (accountsWithoutTask.size() > 0) {   
            List<Task> tasksToCreate = new List<Task>();
            for (Account account : accountsWithoutTask) {
                tasksToCreate.add(
                    new Task(WhatId = account.Id, 
                             OwnerId = account.OwnerId, 
                             Subject = 'Call', 
                             Status = 'Not Started', 
                             Priority = 'Normal', 
                             IsReminderSet = true, 
                             ReminderDateTime = Date.today().addDays(5)));
            }
            if (tasksToCreate.size() > 0){
                insert tasksToCreate;
                update tasksToCreate;
            } 
        }
    }
}