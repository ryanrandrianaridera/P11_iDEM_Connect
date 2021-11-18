public with sharing class OrderManager {
    
    //Afficher msg d'erreur si order n'a pas d'item/service, au passage status order 'Activated'
    public static void checkActivatedOrders(List<Order> ordersToCheck) {
        Map<Id, Order> orders = new Map<Id, Order>([SELECT Id, (SELECT Id FROM OrderItems) FROM Order WHERE Id IN :ordersToCheck]);
        for (Order order : ordersToCheck) {
            if (orders.get(order.id).OrderItems.size() == 0) {
                order.Status = 'Draft';
                order.addError('Please add least one product to the order before changing status');
            }
        }
    }
    
    //Lister les comptes avec order et activer la case Active__c
    public static void setOrdersAccountActive(List<Order> createOrders){
        Set<Id> accountsIds = new Set<Id>();
        for (Order order : createOrders) {
            accountsIds.add(order.AccountId);
        }
        List<Account> accountsToCheck = new List<Account>([SELECT Id,(SELECT Id FROM Orders) FROM Account WHERE Id IN :accountsIds]);
		List<Account> accountsToActivate = new List<Account>();
        for (Account account : accountsToCheck) {
			if (account.Orders.size() > 0) {
                account.Active__c = true;
                accountsToActivate.add(account);
            }
        }
        if (accountsToActivate.size() > 0) update accountsToActivate;
    }
    
    // Lister les comptes à supprimer
    public static void checkAccountsForOrders(List<Order> deletedOrders){
        Set<Id> accountsIds = new Set<Id>();
        for (Order order : deletedOrders) {
            accountsIds.add(order.AccountId);
        }
        List<Account> accountsToCheck = new List<Account>([SELECT Id, (SELECT Id FROM Orders) FROM Account WHERE Id IN :accountsIds]);
        List<Account> accountsToUpdate = new List<Account>();
        for (Account account : accountsToCheck) {
            if (account.Orders.size() == 0) {
                account.Active__c = false;
                accountsToUpdate.add(account);
            }
        }
        if (accountsToUpdate.size() > 0) update accountsToUpdate;		
    }
}