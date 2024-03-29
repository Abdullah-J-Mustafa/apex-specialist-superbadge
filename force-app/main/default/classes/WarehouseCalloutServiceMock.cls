@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock {
  global HTTPResponse respond(HTTPRequest request) {
    System.assertEquals('https://th-superbadge-apex.herokuapp.com/equipment', request.getEndpoint(), 'Verifying the endpoint');
    System.assertEquals('GET', request.getMethod(), 'Verifying the HTTP method of the request');

    HttpResponse response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');
    response.setBody('[{ "_id": "eu123456", "quantity": 5, "name": "GenZ 1000 kW", "maintenanceperiod": 500, "lifespan": 120, "cost": 5000}]');
    response.setStatusCode(200);
    return response;
  }
}
