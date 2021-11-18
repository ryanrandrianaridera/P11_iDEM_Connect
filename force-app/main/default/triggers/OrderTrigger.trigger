trigger OrderTrigger on Order (before insert, before update, before delete, after insert, after delete) {

	if (Trigger.isBefore && Trigger.isUpdate) {
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
		} else if (Trigger.isAfter && Trigger.isInsert) {
		// Process avant insertion
		OrderManager.setOrdersAccountActive(Trigger.new);
		} else if (Trigger.isAfter && Trigger.isDelete) {
		// Process avant suppression
		OrderManager.checkAccountsForOrders(Trigger.old);
	}   
}