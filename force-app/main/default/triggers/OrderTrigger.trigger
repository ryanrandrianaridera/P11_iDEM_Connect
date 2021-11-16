trigger OrderTrigger on Order (before update, before insert, before delete, after delete) {

    //Empecher Status Activated si pas d'item order + msg error

    /*
    if (trigger.isBefore && trigger.isUpdate){
        
        OrderManager.checkActivatedOrders(Trigger.new);
    }
    */
    if (Trigger.isAfter && Trigger.isInsert) {
		// Process avant insertion
		OrderManager.setOrdersAccountActive(Trigger.new);
	} else if (Trigger.isAfter && Trigger.isDelete) {
		// Process avant suppression
		OrderManager.checkAccountsForOrders(Trigger.old);
	} else if (Trigger.isBefore && Trigger.isUpdate) {
		// Process après update
		List<Order> ordersToCheck = new List<Order>();
		for (Order updatedOrder : Trigger.new) {
			if (updatedOrder.Status == 'Activated' && Trigger.oldMap.get(updatedOrder.id).Status == 'Draft') {
				ordersToCheck.add(updatedOrder);
			}
		}
		if (ordersToCheck.size() > 0) {
			OrderManager.checkActivatedOrders(ordersToCheck);
		}
	}
}