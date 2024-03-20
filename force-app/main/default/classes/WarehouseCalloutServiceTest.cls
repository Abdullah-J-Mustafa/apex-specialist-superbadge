@IsTest
private class WarehouseCalloutServiceTest {

  @IsTest
  static void testQueueable() {
    Product2 equipment = new Product2(Warehouse_SKU__c = 'eu123456', name = 'Fuse 20B',
                                      Current_Inventory__c = 2 ,Cost__c = 1000, Maintenance_Cycle__c = 30);
    insert equipment;
    System.assertEquals(2, equipment.Current_Inventory__c, 'Quantity of equipment before the callout is made');

    WarehouseCalloutService warehouseCall = new WarehouseCalloutService();
    Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

    // startTest/stopTest block to force async processes to run
    Test.startTest();
    System.enqueueJob(warehouseCall);
    Test.stopTest();

    Product2 equipmentAfterJob = [SELECT Warehouse_SKU__c, Current_Inventory__c FROM Product2 WHERE Warehouse_SKU__c = 'eu123456'];
    System.assertEquals(5, equipmentAfterJob.Current_Inventory__c, 'Quantity of equipment after the callout is made');
  }
}
