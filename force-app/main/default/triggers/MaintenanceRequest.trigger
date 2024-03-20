trigger MaintenanceRequest on Case (before update, after update) {

	if (Trigger.isAfter) {
    List<Case> closedRepairMaintenanceCases = [SELECT Id, Case.Vehicle__r.Id, (SELECT Equipment_Maintenance_Item__c.Maintenance_Request__c,
                                                Equipment_Maintenance_Item__c.Equipment__c, Equipment_Maintenance_Item__c.Equipment__r.Maintenance_Cycle__c
                                                FROM Case.Equipment_Maintenance_Items__r ORDER BY Equipment_Maintenance_Item__c.Equipment__r.Maintenance_Cycle__c ASC)
                                                FROM Case WHERE Id IN :Trigger.new AND Status = 'Closed' AND Type IN ('Repair', 'Routine Maintenance')
                                                WITH SECURITY_ENFORCED];

    if (closedRepairMaintenanceCases.size() > 0) {
      try {
        MaintenanceRequestHelper.updateWorkOrders(closedRepairMaintenanceCases);
      } catch (Exception ex) {
        // Log the error, send notification, etc.
        System.debug('Error updating Work Orders: ' + ex.getMessage());
      }
    }
  }
}
