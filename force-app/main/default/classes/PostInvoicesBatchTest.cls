@IsTest
private class PostInvoicesBatchTest {

    @IsTest
    static void testPostInvoicesBatch() {

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'blng__Invoice__c'
            AND Name = 'Top Producer'
            LIMIT 1
        ];

        // ONLY 1 matching record → prevents multiple batch executions
        blng__Invoice__c inv = new blng__Invoice__c(
            blng__Account__c = acc.Id,
            RecordTypeId = rt.Id,
            blng__DueDate__c = Date.today(),
            blng__InvoiceStatus__c = 'Draft'
        );

        insert inv;

        Test.startTest();
        Database.executeBatch(new PostInvoicesBatch(), 200);
        Test.stopTest();

        blng__Invoice__c result = [
            SELECT blng__InvoiceStatus__c
            FROM blng__Invoice__c
            WHERE Id = :inv.Id
        ];

        System.assertEquals('Posted', result.blng__InvoiceStatus__c);
    }
}