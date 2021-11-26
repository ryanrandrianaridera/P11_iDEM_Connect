@IsTest
public class TestDataFactory {
    
    public static List<Account> createAccounts(Integer cnt) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0 ; i < cnt ; i++) {
            Account acc = new Account(name = 'TestAccount_' + i);
            accounts.add(acc);
        }
        insert accounts;
        return accounts;
    }
    
    public static Contract createContract(Id accountId) {
        Contract contract = new Contract(
            AccountId = accountId,
            ContractTerm = 12,
            StartDate = Date.today());
        insert contract;
        return contract;
    }
    
    
    public static List<Order> createOrders(Integer cnt, List<Account>accts, PricebookEntry pbEntry) {
        List<Order> orders = new List<Order>();
        for (Integer i = 0 ; i < accts.size() ; i++) {
            Account acct = accts[i];
            
            for (Integer j = 0 ; j < cnt ; j++) {
                Order ord = new Order();
                ord.name = 'Order_' + j;
                ord.AccountId = acct.Id;
                ord.EffectiveDate = System.today();
                ord.Status = 'Draft';
                ord.Pricebook2Id = pbEntry.Pricebook2Id;
                orders.add(ord);
                
            }
        }
        insert orders;
        return orders;
    }
    
    public static PricebookEntry createPricebookEntry(Id productId,
                                                      Decimal amount) {
                                                          PricebookEntry pbEntry = new PricebookEntry(
                                                              Pricebook2Id = Test.getStandardPricebookId(),
                                                              Product2Id = productId,
                                                              UnitPrice = amount,
                                                              IsActive = true
                                                          );
                                                          insert pbEntry;
                                                          return pbEntry;
                                                      }
    
    public static Product2 createProduct(String name, String family) {
        Product2 product = new Product2(
            Name = name,
            IsActive = true,
            Family = family
        );
        
        insert product;
        return product;
    }
    
    public static List<OrderItem> createOrderItems(Integer num, List<Order> orders, PriceBookEntry pbEntry) {
        List<OrderItem> orderItems = new List<OrderItem>();
        for (Order ord : orders) {
            OrderItem orderItem = new OrderItem(
                OrderId = ord.Id,
                PricebookEntryId = pbEntry.Id,
                UnitPrice = pbEntry.UnitPrice,
                Quantity = num
            );
            orderItems.add(orderItem);
        }
        insert orderItems;
        return orderItems;
    }
    
    public static List<OrderItem> createOrderItemsWithRandomQuantity(List<Order> orders, PriceBookEntry pbEntry) {
        List<OrderItem> orderItems = new List<OrderItem>();
        Integer min = 1;
        Integer max = 10;
        Integer num;
        
        for (Order ord : orders) {
            num = (Integer) Math.floor(Math.random() * ( max - min + 1 ) + min);
            OrderItem orderItem = new OrderItem(
                OrderId = ord.Id,
                PricebookEntryId = pbEntry.Id,
                UnitPrice = pbEntry.UnitPrice,
                Quantity = num
            );
            orderItems.add(orderItem);
        }
        insert orderItems;
        return orderItems;
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