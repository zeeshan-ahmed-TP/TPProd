@isTest
public class customLookupController_Test {

    @isTest 
    static void testAccount(){
        Account acc = new Account(name='fg');
        insert acc;

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account acc1 = new Account(name='fg', ParentId = acc.Id, RecordTypeId = devRecordTypeId);
        insert acc1;

        Test.startTest();
        List<sObject> checkList1 = customLookUpController.fetchLookUpValues('', acc.Id, 'fg', 'Account', acc.Id);
        Test.stopTest();
    }

    @isTest 
    static void testMLSAssociation_WithMatchingRecord(){
        // Insert a matching MLS_Association__c record so the loop body inside 
        // the "if(String.isNotEmpty(stateVal))" branch actually executes
        MLS_Association__c mls = new MLS_Association__c(
            Name = 'fgAssoc',
            Billing_State_Province__c = 'CA',
            MLS_Status__c = 'Active'
            // add any other required fields your org enforces
        );
        insert mls;

        Test.startTest();
        List<sObject> checkList = customLookUpController.fetchLookUpValues('CA', 'xyz', 'fg', 'MLS_Association__c', 'sfg');
        Test.stopTest();
    }

    @isTest 
    static void testMLSAssociation_EmptyState(){
        Test.startTest();
        List<sObject> checkList = customLookUpController.fetchLookUpValues('', 'xyz', 'fg', 'MLS_Association__c', 'sfg');
        Test.stopTest();
    }

    @isTest
    static void testSubscription_WithMatchingRecord(){
        Account acc = new Account(Name = 'SubTestAcc');
        insert acc;

        // NOTE: adjust these fields to match your org's actual required fields
        // on SBQQ__Subscription__c. If SBQQ__ProductName__c is a formula field
        // in your org (common in CPQ), you'll instead need to create a Product2
        // named 'HouseValues' and link it via SBQQ__Product__c so the formula resolves.
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
            SBQQ__Account__c = acc.Id,
            SBQQ__Quantity__c = 1
        );
        insert sub;

        Test.startTest();
        List<sObject> checkList = customLookUpController.fetchLookUpValues('', acc.Id, 'fg', 'SBQQ__Subscription__c', 'sfg');
        Test.stopTest();
    }

    @isTest
    static void testUnrecognizedObjectName(){
        Test.startTest();
        List<sObject> checkList = customLookUpController.fetchLookUpValues('', 'xyz', 'fg', 'SomeOtherObject__c', 'sfg');
        Test.stopTest();
    }
}