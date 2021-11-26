trigger OrderTrigger on Order (before insert, before update, before delete, after insert, after delete) {
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        // Process before update
        HandlerManager.checkActivatedOrders(Trigger.newMap, Trigger.oldMap);
    } else if (Trigger.isAfter && Trigger.isInsert) {
        // Process after insert
        HandlerManager.setOrdersAccountActive(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isDelete) {
        // Process after delete
        HandlerManager.checkAccountsForOrders(Trigger.old);
    }   
}