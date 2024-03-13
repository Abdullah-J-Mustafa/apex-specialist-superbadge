public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    public void execute(QueueableContext context) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        List<Product2> prodsToUpdate = new List<Product2>();
        
        if(response.getStatusCode() == 200) { 
            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
            
            for (Object obj : results) {
                Map<String, Object> prodObj = (Map<String, Object>)obj;
                Product2 prodToUpdate = new Product2(Warehouse_SKU__c = (String) prodObj.get('_id'), 
                                                    Name = (String) prodObj.get('name'),
                                                   	Lifespan_Months__c = (Decimal) prodObj.get('lifespan'),
                                                    Replacement_Part__c = True,
                                                    Cost__c = (Decimal) prodObj.get('cost'),
                                                   	Current_Inventory__c = (Decimal) prodObj.get('quantity'),
                                                   	Maintenance_Cycle__c = (Decimal) prodObj.get('maintenanceperiod'));
                prodsToUpdate.add(prodToUpdate);
            }
        }
        
        if (!prodsToUpdate.isEmpty()) {
            upsert prodsToUpdate Warehouse_SKU__c;
        }
    }
}