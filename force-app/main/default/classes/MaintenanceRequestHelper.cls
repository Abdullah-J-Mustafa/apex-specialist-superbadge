public with sharing class MaintenanceRequestHelper {

  public static void updateWorkOrders(List<Case> mrsToUpdate) {
    try {
      Map<ID, Case> newCasesWithOldCaseIds= new Map<ID, Case>();
      List<Case> casesToCreateList = new List<Case>();
      List<Equipment_Maintenance_Item__c> emisToClone = new List<Equipment_Maintenance_Item__c>();
      List<Equipment_Maintenance_Item__c> emisToCreateList = new List<Equipment_Maintenance_Item__c>();

      for (Case mainReq : mrsToUpdate) {
        Integer leastDate = mainReq.Equipment_Maintenance_Items__r[0].Equipment__r.Maintenance_Cycle__c.intValue();
        Case newMainReq = new Case(Vehicle__c = mainReq.Vehicle__r.Id, Type = 'Routine Maintenance',
                                    Subject = 'Automatic Maintenance Request', Date_Reported__c = Date.today(),
                                    Date_Due__c = Date.today().addDays(leastDate));

        casesToCreateList.add(newMainReq);
        newCasesWithOldCaseIds.put(mainReq.id, newMainReq);

        for (Equipment_Maintenance_Item__c emi : mainReq.Equipment_Maintenance_Items__r) {
          emisToClone.add(emi);
        }
      }

      if (!casesToCreateList.isEmpty()) {
        if (Schema.sObjectType.Case.isCreateable()) {
          insert casesToCreateList;
        } else {
          System.debug('User lacks Create permission on Cases');
        }
      }

      for (Equipment_Maintenance_Item__c emi : emisToClone) {
          Equipment_Maintenance_Item__c clonedEmi = emi.clone(false, true, false, false);
          clonedEmi.Maintenance_Request__c = newCasesWithOldCaseIds.get(emi.Maintenance_Request__c).id;
          clonedEmi.Equipment__c = emi.Equipment__r.Id;
          emisToCreateList.add(clonedEmi);
      }

      if (!emisToCreateList.isEmpty()) {
        if (Schema.sObjectType.Equipment_Maintenance_Item__c.isCreateable()) {
          insert emisToCreateList;
        } else {
          System.debug('User lacks Create permission on Equipment Maintenance Items');
        }
      }
    } catch (Exception ex) {
      // Log the error, send notification, etc.
      System.debug('Error in MaintenanceRequestHelper: ' + ex.getMessage());
    }
	}
}
