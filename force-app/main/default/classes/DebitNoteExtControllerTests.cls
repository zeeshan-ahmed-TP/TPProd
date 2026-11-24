@isTest
private class DebitNoteExtControllerTests {
    
    testMethod static void testSubmit() {
        blng__DebitNote__c DebitNote = new blng__DebitNote__c();
         Account accObj=new Account();
            accObj.Name='TestAccount';
            accObj.Phone='1234567898';
            insert accObj;
        
            DebitNote.blng__Account__c =accObj.id;
        insert DebitNote;
        
        Test.startTest();
        DebitNoteExtController con = new DebitNoteExtController(new ApexPages.StandardController(DebitNote));
        con.onSubmit();
        DebitNote = [SELECT ApprovalStatus__c FROM blng__DebitNote__c WHERE Id = :DebitNote.Id LIMIT 1];
        Test.stopTest();
         System.assertEquals('Approved', DebitNote.ApprovalStatus__c);
    }
    
   /* testMethod static void testRecall() {
        blng__DebitNote__c DebitNote = new blng__DebitNote__c();
        insert DebitNote;
        Test.startTest();
        DebitNoteExtController con = new DebitNoteExtController(new ApexPages.StandardController(DebitNote));
        con.onRecall();
        DebitNote = [SELECT ApprovalStatus__c FROM blng__DebitNote__c WHERE Id = :DebitNote.Id LIMIT 1];
        Test.stopTest();
        System.assertEquals('Recalled', DebitNote.ApprovalStatus__c);
    }*/
}