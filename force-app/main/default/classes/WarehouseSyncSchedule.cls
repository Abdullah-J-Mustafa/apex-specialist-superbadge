public with sharing class WarehouseSyncSchedule implements Schedulable {
    public void execute(SchedulableContext ctx) {
        System.enqueueJob(new WarehouseCalloutService());
    }
}