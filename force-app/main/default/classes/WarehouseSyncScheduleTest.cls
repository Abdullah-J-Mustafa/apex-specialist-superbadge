@IsTest
private class WarehouseSyncScheduleTest {
    public static String CRON_EXP = '0 0 0 1 1 ? 2040';
    
    @IsTest
    static void testScheduledJob() {
		Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());   
        
        Test.startTest();
        String jobID = System.schedule('WarehouseSyncScheduleTest', CRON_EXP, new WarehouseSyncSchedule());
        AsyncApexJob[] apexJobsListBeforeScheduleJobCompleted = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob];
 		CronTrigger[] cronJobsList = [SELECT Id FROM CronTrigger WHERE Id = :jobID];
        System.assertEquals(1, cronJobsList.size(), 'The job is inserted in the queue');
        Test.stopTest();
        
        // As we can't test nested async jobs, so will only test if the queue job is properly enqueued
        AsyncApexJob[] apexJobsListafterScheduleJobCompleted = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob];
        System.assertEquals(apexJobsListafterScheduleJobCompleted.size(), apexJobsListBeforeScheduleJobCompleted.size() + 1, 'A new apex job is added by the scheduler');
    }
}