@isTest
private class CreditNoteExtControllerTests {
    
    testMethod static void testSubmit() {
        blng__CreditNote__c CreditNote = new blng__CreditNote__c();
         //system.debug('Started');
         Account accObj=new Account();
            accObj.Name='TestAccount';
            accObj.Phone='1234567898';
            insert accObj;
        
            CreditNote.blng__Account__c =accObj.id;
            CreditNote.blng__CreditNoteDate__c=DATE.TODAY();
        insert CreditNote;
       // system.debug('Inserted');


        Test.startTest();
        CreditNoteExtController con = new CreditNoteExtController(new ApexPages.StandardController(CreditNote));
        con.onSubmit();
        CreditNote = [SELECT ApprovalStatus__c FROM blng__CreditNote__c WHERE Id = :CreditNote.Id LIMIT 1];
        Test.stopTest();
         System.assertEquals('Approved', CreditNote.ApprovalStatus__c);
    }
    
   /* testMethod static void testRecall() {
        blng__CreditNote__c CreditNote = new blng__CreditNote__c();
        system.debug('Started');
            CreditNote.blng__Account__c ='0017i000013Ryd2AAC';
            CreditNote.blng__CreditNoteDate__c=DATE.TODAY();
        insert CreditNote;
        Test.startTest();
        CreditNoteExtController con = new CreditNoteExtController(new ApexPages.StandardController(CreditNote));
        con.onRecall();
        CreditNote = [SELECT ApprovalStatus__c FROM blng__CreditNote__c WHERE Id = :CreditNote.Id LIMIT 1];
        Test.stopTest();
        System.assertEquals('Recalled', CreditNote.ApprovalStatus__c);
    }*/
}