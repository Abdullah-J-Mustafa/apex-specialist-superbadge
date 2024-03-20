@isTest
private class MaintenanceRequestHelperTest {

  @isTest
  static void testCloseCaseOfRepairAndRoutineMainReq() {
    CreateDefaultData.createDefaultData();
    List<Id> equipmentForClosedMainReq = new List<Id>();
    List<Id> equipmentForNewMainReq = new List<Id>();

    Case maintenanceRequest = [SELECT Id, Case.Vehicle__c, (SELECT Equipment_Maintenance_Item__c.Equipment__c,
                              Equipment_Maintenance_Item__c.Equipment__r.Maintenance_Cycle__c
                              FROM Case.Equipment_Maintenance_Items__r
                              ORDER BY Equipment_Maintenance_Item__c.Equipment__r.Maintenance_Cycle__c ASC)
                              FROM Case WHERE Type = 'Routine Maintenance' LIMIT 1];
    Integer leastDate = maintenanceRequest.Equipment_Maintenance_Items__r[0].Equipment__r.Maintenance_Cycle__c.intValue();

    Test.startTest();
    maintenanceRequest.status = 'Closed';
    update maintenanceRequest;
    Test.stopTest();

    List<Case> mrs = [SELECT Id,  Case.Vehicle__c, Date_Due__c, (SELECT Equipment_Maintenance_Item__c.Equipment__c
                      FROM Case.Equipment_Maintenance_Items__r) FROM Case WHERE Subject = 'Automatic Maintenance Request'];

    for(Equipment_Maintenance_Item__c emi : maintenanceRequest.Equipment_Maintenance_Items__r) {
          equipmentForClosedMainReq.add(emi.Equipment__c);
    }

    for(Equipment_Maintenance_Item__c emi : mrs[0].Equipment_Maintenance_Items__r) {
          equipmentForNewMainReq.add(emi.Equipment__c);
    }

    System.assertEquals(mrs.size(), 1, 'As 1 MR was closed, a new MR was automatically created');
    System.assertEquals(mrs[0].Vehicle__c, maintenanceRequest.Vehicle__c, 'Vehicles for both Maintenance Requests are same');
    System.assertEquals(mrs[0].Equipment_Maintenance_Items__r.size(), maintenanceRequest.Equipment_Maintenance_Items__r.size(), 'The new MR has the same number of EMIs as the closed case');
    System.assertEquals(equipmentForClosedMainReq, equipmentForNewMainReq, 'Both MRs have the same equipment assigned');
  }

  @isTest
  static void testCloseCaseOfOtherMainReq() {
    CreateDefaultData.createDefaultData();
    List<Case> maintenanceRequests = [SELECT Id, Status FROM Case WHERE Status = 'New'];

    Test.startTest();
    maintenanceRequests[0].status = 'Working';
    update maintenanceRequests[0];
    Test.stopTest();

    List<Case> mrs = [SELECT Id, Status FROM Case];
    System.assertEquals(maintenanceRequests.size(), mrs.size(), 'Comparing lengths of both lists');
  }

  @isTest
  static void testBulkMainReqs() {
    List<Case> maintenanceReqs = CreateDefaultData.createBulkData();

    Test.startTest();
    for(Integer i = 0; i < maintenanceReqs.size(); i++) {
        maintenanceReqs[i].status = 'Closed';
    }
    update maintenanceReqs;
    Test.stopTest();

    List<Case> mrs = [SELECT Id FROM Case WHERE Subject = 'Automatic Maintenance Request'];
    System.assertEquals(mrs.size(), 300, 'As 300 MR were closed, 300 new MR were automatically created');
  }
}
