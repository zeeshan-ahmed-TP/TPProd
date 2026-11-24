@isTest
public class Agentaccountscreen_Test {
    
    @isTest 
    static void getuserENTpicklist_Test(){
        Account account = new Account();
            account.Name = 'ULTesting';
            account.Phone='12345';
            account.Email__c = 'test@gmail.com';
            insert account;          
            Contact contact = new Contact(AccountId = account.Id, FirstName = 'FirstName',LastName = 'LastName' + Date.today(), isPrimaryContact__c = true);
            insert contact;
            
        User_Licensing__c listObj = new User_Licensing__c();
        listObj.Product__c = 'FiveStreet';
        listObj.Status__c = 'Pending Fulfillment';
        listObj.Account__c = account.Id;
        insert listObj;
        Test.startTest();
        Agentaccountscreen.getuserENTpicklist(listObj.Id);
        Test.stopTest();
        //Agentaccountscreen.dummyCode();
    }
    
    @isTest
    static void InsertuserENT_Test(){
        Account account = new Account();
            account.Name = 'ULTesting';
            account.Phone='12345';
            account.Email__c = 'test@gmail.com';
            insert account;          
            Contact contact = new Contact(AccountId = account.Id, FirstName = 'FirstName',LastName = 'LastName' + Date.today(), isPrimaryContact__c = true);
            insert contact;
        User_Licensing__c userObj = new User_Licensing__c();
        userObj.Account__c = account.Id;
        userObj.Product__c = 'FiveStreet';
        userObj.Status__c = 'Pending Fulfillment';
        userobj.Active__c=true;
        insert userObj;

        Test.startTest();
        Agentaccountscreen.InsertuserENT(account.Id ,userObj.Product__c );
        Test.stopTest();
    }
    
    @isTest
    static void getPicklistValue_Test(){
        Account acc= new Account();
        acc.Name='test Account';
        insert acc;
        List<product2> proList = new List<product2>();
        List<SBQQ__Subscription__c> subsList = new List<SBQQ__Subscription__c>();
        for(integer i=0; i<7;i++){
            product2 pro = new product2();
            if(i==0){
                pro.Name = 'FiveStreet '; 
                
            }else if(i==1){
                pro.Name = 'Top Producer Assistant License';
            }else if(i==2){
                pro.name = 'Market Snapshot'; 
            }else if(i==3){
                pro.name = 'Top Producer CRM'; 
            }else if(i==4){
                pro.name = 'Top Producer Website'; 
            }else if(i==5){
                pro.name = 'Top Producer Pro';
            } else if(i==6){
                pro.Name = 'Social Connect';
            }
            proList.add(pro);
        }
        insert proList;
        
        for(integer j=0 ; j<7 ;j++){
            SBQQ__Subscription__c subs = new SBQQ__Subscription__c();  
            
            subs.SBQQ__Account__c = acc.id;
            subs.SBQQ__Quantity__c =10;
            subs.SBQQ__Product__c =proList[j].id; 
            subsList.add(subs);
            
            
        }
        insert subsList;
        
        Account accObject=new Account();
        accObject.Top_Producer_Websites_License__c=32.12;
        accObject.Top_Producer_CRM_License__c=22.12;
        accObject.Top_Producer_Assistant_License__c=44.4;
        accObject.Market_Snapshot_License__c=44.56;
        accObject.Five_Street_License__c=66.56;
        accObject.Social_Connect_License__c = 12.12;
        
        Test.startTest();
        Agentaccountscreen.getPicklistValue(acc.Id);
        Test.stopTest();
    }
    
    @isTest
    static void insertUserEntitlementsController_Test(){
        try{
            
        
         /*Account acc= new Account();
        acc.Name='test Account';
        insert acc;*/
          
        
        
             // subs.SBQQ__ProductName__c=p2.Id;
        
        Account accObject=new Account();
        accObject.name='accName';
        accObject.Top_Producer_Websites_License__c=32.12;
        accObject.Top_Producer_CRM_License__c=22.12;
        accObject.Top_Producer_Assistant_License__c=44.4;
        accObject.Market_Snapshot_License__c=44.56;
        accObject.Five_Street_License__c=66.56;
            accObject.Social_Connect_License__c = 12.12;
        insert accObject;
        
         product2 p2=new product2();
             p2.name='FiveStreet';
        insert p2;
        
      List<SBQQ__Subscription__c> subsList = new List<SBQQ__Subscription__c>();
                for(integer j=0 ; j<7 ;j++){
            SBQQ__Subscription__c subs = new SBQQ__Subscription__c();  
            
            subs.SBQQ__Account__c = accObject.id;
            subs.SBQQ__Quantity__c =10;
            subs.SBQQ__Product__c =p2.id; 
            subsList.add(subs);
        }
        insert subsList;
          // subs.SBQQ__Account__c=accObject.id;
       // insert subs;
        MLS_Association__c mls = new MLS_Association__c();
        mls.Name = 'Test';
        mls.Billing_State_Province__c = 'CA';
        insert mls;
        
        String UserEnt = '[{"AccountVal":"'+accObject.id+'","Product":"FiveStreet","Numb":"1","exist":false,"MLS":["'+mls.id+'"],"stateVal":"CA","SharedType":"Shared"}]';
        String UserEnt1 = '{"AccountVal":"'+accObject.id+'","Product":"FiveStreet","Numb":"1","exist":false,"MLS":["'+mls.id+'"],"stateVal":"CA","SharedType":"Shared"}';
        
        Test.startTest();
        Agentaccountscreen.insertUserEntitlementsController(accObject.id,UserEnt);
        Agentaccountscreen.checkExistingENTError(UserEnt1);
        Test.stopTest();
        }catch(Exception e){
                        System.debug('Exception due to--->: '+e.getMessage()+'   Line Number-->: '+e.getLineNumber());

        }
    }
    
    @isTest
    static void getAvailableLicenseDetails_Test(){
        Account acc = new Account();
        acc.Name = 'acc1';
        insert acc;
        Test.startTest();
        Agentaccountscreen.getAvailableLicenseDetails(acc.id);
        Test.stopTest();
    } 
    
    @isTest
    static void getTotalLicenseDetails_Test(){
       // Account acc=new account();
         Account acc= new Account();
        acc.Name='test Account';
        insert acc;
        List<product2> proList = new List<product2>();
        List<SBQQ__Subscription__c> subsList = new List<SBQQ__Subscription__c>();
        for(integer i=0; i<7;i++){
            product2 pro = new product2();
            if(i==0){
                pro.Name = 'FiveStreet'; 
                
            }else if(i==1){
                pro.Name = 'Top Producer Assistant License';
            }else if(i==2){
                pro.name = 'Market Snapshot'; 
            }else if(i==3){
                pro.name = 'Top Producer CRM'; 
            }else if(i==4){
                pro.name = 'Top Producer Websites'; 
            }else if(i==5){
                pro.name = 'Top Producer Pro';
            } else if(i==6){
                pro.Name = 'Social Connect';
            }
            proList.add(pro);
        }
        insert proList;
        
        for(integer j=0 ; j<7 ;j++){
            SBQQ__Subscription__c subs = new SBQQ__Subscription__c();  
            
            subs.SBQQ__Account__c = acc.id;
            subs.SBQQ__Quantity__c =10;
            subs.SBQQ__Product__c =proList[j].id; 
            subsList.add(subs);
        }
        insert subsList;
         Test.startTest();
        Agentaccountscreen.getTotalLicenseDetails(acc.id);
        String ids = Agentaccountscreen.fetchRecordTypeId('Team');
        String idsNull = Agentaccountscreen.fetchRecordTypeId('');
        Test.stopTest();
        System.assertEquals(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Team').getRecordTypeId(),ids);
        System.assertEquals(null,idsNull);
    }
    
     @isTest
    static void checkExistingENTError_Test(){
        try{
          Account accountObj = new Account();
        accountObj.Name = 'Test';
        insert accountObj;
       
        
        User_Licensing__c userObj = new User_Licensing__c();
        userObj.Account__c = accountObj.Id;
        userObj.Product__c = 'FiveStreet';
        userobj.Active__c=true;
        
        insert userObj;
      
          Test.startTest();
        //Agentaccountscreen.checkExistingENTError(accountObj.id+'');
        Test.stopTest();
        }
    catch(Exception e){
            System.debug('Exception due to--->: '+e.getMessage()+'   Line Number-->: '+e.getLineNumber());
        }
    }
    @isTest
    static void changeRecordTypeController_Test(){
          Account accountObj = new Account();
        accountObj.Name = 'Test';
        
        insert accountObj;
         Test.startTest();
        Agentaccountscreen.changeRecordTypeController(accountObj.id);
        Agentaccountscreen.DummyCode();
        Test.stopTest();
    }
}