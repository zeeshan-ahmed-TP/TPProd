@isTest
private class LeadConvertClass_Test {
    @isTest
    static void linkAccountLead_Test(){
        try{
            Account accObj=new Account();
            accObj.Name='TestAccount';
            accObj.Email__c='test@gmail.com';
            accObj.Phone='1234567898';
            insert accObj;
            
           Campaign campaignObj=new Campaign();
            campaignObj.Name='TestCampaign';
            insert campaignObj; 
            
            Lead leadObj=new Lead();
            leadObj.LastName='TestLead';
            leadObj.Account__c=accObj.id;
            leadObj.Status='New';
            leadObj.Company='Cloud';
            leadObj.Campaign__c=campaignObj.id;
            leadObj.Campaign_Name__c=campaignObj.Name;
            leadObj.Email='test@gmail.com';
            leadObj.Phone='1234567898';
            
            Test.startTest();
            insert leadObj;
            update leadObj;
            Test.stopTest();
            
            
        }catch(Exception e){
            System.debug('Exception due to-->: '+e.getCause()+'----'+e.getLineNumber()+'------'+e.getMessage());
        }
    }

}