trigger MaintenanceRequest on Case (before update, after update) {
    // ToDo: Call MaintenanceRequestHelper.updateWorkOrders

	if (Trigger.isAfter) {
        List<Case> casesToUpdate = [SELECT Id, Case.Vehicle__r.Id, (SELECT Equipment_Maintenance_Item__c.Maintenance_Request__c, Equipment_Maintenance_Item__c.Equipment__c, Equipment_Maintenance_Item__c.Equipment__r.Maintenance_Cycle__c 
		                                FROM Case.Equipment_Maintenance_Items__r ORDER BY Equipment_Maintenance_Item__c.Equipment__r.Maintenance_Cycle__c ASC) FROM Case 
        		                    WHERE Id IN :Trigger.new AND Status = 'Closed' AND Type IN ('Repair', 'Routine Maintenance')];
        
        if (casesToUpdate.size() > 0) {
        	MaintenanceRequestHelper.updateWorkOrders(casesToUpdate);   
        }
    }  
}