@isTest
private class PaymentExtControllerTests {
    
    testMethod static void testSubmit() {
        blng__Payment__c payment = new blng__Payment__c();
         Account accObj=new Account();
            accObj.Name='TestAccount';
            accObj.Phone='1234567898';
            insert accObj;
        
            payment.blng__Account__c =accObj.id;
            payment.blng__Amount__c=100;
        insert payment;
        
        Test.startTest();
        PaymentExtController con = new PaymentExtController(new ApexPages.StandardController(payment));
        con.onSubmit();
        payment = [SELECT ApprovalStatus__c FROM blng__Payment__c WHERE Id = :payment.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', payment.ApprovalStatus__c);
    }
    
  /*  testMethod static void testRecall() {
        blng__Payment__c payment = new blng__Payment__c();
        insert payment;
        
        Test.startTest();
        PaymentExtController con = new PaymentExtController(new ApexPages.StandardController(payment));
        con.onRecall();
        payment = [SELECT ApprovalStatus__c FROM blng__Payment__c WHERE Id = :payment.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Recalled', payment.ApprovalStatus__c);
    }*/
}