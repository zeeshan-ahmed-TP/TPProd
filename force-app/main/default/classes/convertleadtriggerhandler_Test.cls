@isTest
private class convertleadtriggerhandler_Test {
    @isTest
    static void leadAccountInsert_test(){
        try{
            List<Lead> leadList=new List<Lead>();
            Account accObj=new Account();
            accObj.Name='TestAccount';
            accObj.Email__c='test@gmail.com';
            accObj.Phone='1234567898';
            insert accObj;
           
            Lead leadObj=new Lead();
            leadObj.LastName='TestLead';
            leadObj.Account__c=accObj.id;
            leadObj.Status='Working - Open Deal';
            leadObj.IsConverted=false;
            leadObj.Company='Cloud';
            leadObj.Email='test@gmail.com';
            leadObj.Phone='1234567898';
        
            Test.startTest();
            insert leadObj;
            system.debug('leadObj-->:  '+leadObj);
            leadObj.IsConverted=true;
            leadObj.Account__c=accObj.id;
            update leadObj;
            Test.stopTest();
            
        }catch(Exception e){
            System.debug('Exception due to-->: '+e.getCause()+'----'+e.getLineNumber()+'------'+e.getMessage());
        }
        
    }
     @isTest
    static void leadAccountInsert_test1(){
        try{
            Lead leadObj=new Lead();
            leadObj.LastName='TestLead';
            leadObj.Status='Working - Open Deal';
            leadObj.Company='Cloud';
            leadObj.IsConverted=false;
            
            Test.startTest();
            insert leadObj;
            update leadObj;
            Test.stopTest();
           
        }catch(Exception e){
            System.debug('Exception due to-->: '+e.getCause()+'----'+e.getLineNumber()+'------'+e.getMessage());
        }
        
    }

    
}