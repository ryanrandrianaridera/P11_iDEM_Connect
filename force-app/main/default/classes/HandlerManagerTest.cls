@IsTest
public class HandlerManagerTest {
    @TestSetup
    static void setupData() {
        List<Account> acct = TestDataFactory.createAccounts(5);
        Product2 productOne = TestDataFactory.createProduct('TestItem', 'Prestation');
        PricebookEntry priceBook = TestDataFactory.createPricebookEntry(productOne.Id, 1020);
        List<Order> ord = TestDataFactory.createOrders(2, acct, priceBook);
        List<OrderItem> orderItems = TestDataFactory.createOrderItemsWithRandomQuantity(ord, priceBook);
    }
    
    @isTest
    static void AccountWithOrderShouldBeActive() {
        List<Account> accts = [
            SELECT Id, Active__c
            FROM Account
            WHERE Name LIKE 'TestAccount_%'
        ];
        List<Order> orders = [
            SELECT Id, AccountId
            FROM Order
        ];
        
        System.debug('ORDER SIZE:' + orders.size());
        System.debug('ORDER:' + orders);
        
        Test.startTest();
        update orders;
        Test.stopTest();
        
        for (Account acc : accts) {
            System.assertEquals(true, acc.Active__c);
            System.debug(acc.Active__c);
            
        }
    }
    @isTest
    static void AccountWithNoOrderShouldBeInactive() {
        List <Account> accts = [
            SELECT Id, Active__c, ( SELECT Id FROM Orders )
            FROM Account
            WHERE Name LIKE 'TestAccount_%'
        ];
        for (Account acc : accts) {
            System.assertEquals(true, acc.Active__c);
        }
        Test.startTest();
        for(Account acc : accts){
            for(Order ord : acc.Orders){
                delete ord;
            }}
        Test.stopTest();
        accts = [
            SELECT Id, Active__c
            FROM Account
            WHERE Name LIKE 'TestAccount_%'
        ];
        for (Account acc : accts) {
            System.assertEquals(false, acc.Active__c);
        }
    }
    @IsTest
    static void NoItemsSetInOrderShouldReturnAnErrorTest() {
        List<Order> orders = [
            SELECT Id, AccountId, Status, (
                SELECT Id, UnitPrice, Quantity, OrderId
                FROM OrderItems
            )
            FROM Order
            WHERE Name LIKE 'Order_%'
        ];
        
        for (Order order : orders) {
            order.Status = 'Activated';//We want to change the status to activated
            delete order.OrderItems;//We add to manually delete the order items create by the TestDataFactory
        }
        
        Test.startTest();
        
        try {
            update orders;
            
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
            Boolean expectedMessage = e.getMessage().contains('Please add least one product to the order before changing status') ? true : false;
            
            System.assertEquals(expectedExceptionThrown, true);
            System.assertEquals(expectedMessage, true);
        }
        
        Test.stopTest();
        orders = [
            SELECT Id, AccountId, Status, (
                SELECT Id, UnitPrice, Quantity, OrderId
                FROM OrderItems
            )
            FROM Order
            WHERE Name LIKE 'Order_%'
        ];
        
        for (Order ord : orders) {
            System.assertEquals('Draft', ord.Status);//All orders should have the status draft
        }
    }
    
    @IsTest
    static void ItemsSetInOrderShouldNotReturnAnErrorTest() {
        List<Order> orders = [
            SELECT Id, AccountId, Status, (
                SELECT Id, UnitPrice, Quantity, OrderId
                FROM OrderItems
            )
            FROM Order
            WHERE Name LIKE 'Order_%'
        ];
        
        
        for (Order order : orders) {
            order.Status = 'Activated';
            
        }
        
        Test.startTest();
        try {
            update orders;
            
        } catch (Exception e) {
            
            System.debug(e);
            
        }
        Test.stopTest();
        orders = [
            SELECT Id, AccountId, Status, (
                SELECT Id, UnitPrice, Quantity, OrderId
                FROM OrderItems
            )
            FROM Order
            WHERE Name LIKE 'Order_%'
        ];
        
        for (Order ord : orders) {
            System.assertEquals('Activated', ord.Status);
        }
    }
}