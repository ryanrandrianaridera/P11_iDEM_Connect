@isTest
public with sharing class TestDataFactory {
    
    public static Account createAccount(String name) {
        Account account = new Account( Name = name);
        insert account;
        return account;
    }
    
    public static Contract createContract(Id accountId) {
        Contract contract = New Contract(AccountId= accountId,
                                         StartDate= System.today(),
                                         ContractTerm=12,
                                         Status='Draft',
                                         Name = 'contractTest');
        insert contract;
        contract.Status = 'Activated';
        update contract;
        return contract;
    }
    
    public static Product2 createProduct() {
        Product2 product = new Product2(
            IsActive =true,
            Name = 'ProductTest'
        );
        insert product;
        return product;
    }
    
    public static PricebookEntry createPricebookEntry(Id productId, Decimal amount) {
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = productId,
            UnitPrice = amount,
            IsActive = false
        );
        insert priceBookEntry;
        return priceBookEntry;     
    }
    
    public static Order createOrder(Id accountId, Id contractId){         
        Order order = New Order (
            AccountId = accountId,
            ContractId = contractId,
            Status ='Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );       
        insert order;
        return order;   
    }            
    
    
    public static OrderItem createOrderItem(Id orderId, Id productId, Integer quantity, Decimal unitPrice,  Id pricebookEntryId) {
        OrderItem orderItem = new OrderItem(
            OrderId = orderId,
            Product2Id= productId,
            Quantity = quantity,
            UnitPrice = unitPrice,
            PricebookEntryId= pricebookEntryId
        );
        insert orderItem;
        return orderItem;
    }
    
    //Method to create a list of Accounts
    public static List<Account> createAccounts(Integer numberOfaccounts) {
        List<Account> accounts = new List<Account>();
        
        for (Integer i = 0 ; i < numberOfaccounts; i++) {
            Account accts = new Account(
                Name = 'TestAccount_'+i
            );
            accounts.add(accts);
        }
        insert accounts;
        return accounts;
    }
    
    //Method to create a list of Orders
    public static List<Order> createOrders(Account account, PricebookEntry pricebookEntry, Integer numberOrder) {
        List<Order> orders = new List<Order>();
        Contract contract =TestDataFactory.createContract(account.Id); 
        for(Integer i = 0; i < numberOrder; i++){
            Order order = TestDataFactory.createOrder(account.Id, contract.Id);
            order.Name='OrdersTest'+i;
            orders.add(order);
        }
        update orders;
        return orders;
    }
    
    //Method to create a list of OrderItems
    public static List<OrderItem> createOrderItems(Integer quantity, List<Order> orders, PricebookEntry pricebookEntry) {
        List<OrderItem> orderItems = new List<OrderItem>();
        for (Order order : orders){
            OrderItem orderItem = new OrderItem(
                OrderId = order.Id,
                PricebookEntryId = pricebookEntry.Id,
                UnitPrice = pricebookEntry.UnitPrice,
                Quantity = quantity
            );
            orderItems.add(orderItem);
        }
        insert orderItems;
        return orderItems;
    }
    //Method to create One account with several orders
    public static List<Order> createAccountWithOrders(Integer numberOrders, Id accountId){
        
        List<Order> orders = new List<Order>();
        for(Integer i=0; i<numberOrders; i++) {
            Order order = new Order(
                AccountId = accountId,
                Pricebook2Id = Test.getStandardPricebookId(),
                status = 'draft',
                effectiveDate = Date.today()
            );
            orders.add(order);
        }
        insert orders;
        Product2 product2 = TestDataFactory.createProduct();
        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(product2.Id, 100);
        
        List<OrderItem> items = new List<OrderItem>();
        for(Order order: orders) {
            OrderItem item = new OrderItem (OrderId = order.Id, PricebookEntryId = pricebookEntry.Id, Quantity=1, UnitPrice = 100);
            items.add(item);
        }
        insert items;     
        
        update orders;
        return orders;
    }   
    public static Task createReminderTaskForAccount(Account account) {
		Task task = new Task(
			WhatId = account.Id,
			OwnerId = account.OwnerId,
			Subject = 'Call',
			Status = 'Not Started',
			Priority = 'Normal',
			IsReminderSet = true,
			ReminderDateTime = Date.today().addDays(5)
		);
		insert task;
		return task;
	}
}
