@isTest
public class PorductOnAccountFromSubsHandler_Test {
    @isTest static void PorductOnAccountFromSubsHandler_Method1(){
        
        
         Account acc = new account();
        acc.name = 'account1';
        insert acc ;
        
        contract contr = new contract();
        contr.AccountId = acc.id;
        contr.Status = 'draft';
        contr.StartDate = date.today() ;
        contr.ContractTerm = 2 ;
        contr.SBQQ__Evergreen__c = true;
        insert contr ;
        
        
        
        
        List<product2> proList = new List<product2>();
        for(integer i=0 ; i<11 ; i++){
            product2 pro = new product2();
            if(i==0){
                pro.Name = 'FiveStreet';
            }else if(i==1){
                pro.Name = 'Market Snapshot';
       	     }else if(i==2){
                pro.Name = 'Top Producer Assistant License';
            }else if(i==3){
                pro.Name = 'Top Producer CRM';
            }else if(i==4){
                pro.Name = 'Top Producer Pro';
                pro.ProductCode = 'TPPRO-001';
            }else if(i==5){
                pro.Name = 'Top Producer Pro Plus';
                pro.ProductCode = 'TPPROP-001';
            }else if(i==6){
                pro.Name = ProductNames.TPHI;
                pro.ProductCode = 'HI-001';
            }else if(i==7){
                pro.Name = 'Social Connect 500';
                pro.ProductCode = 'SC-002';
            }else if(i==8){
                pro.Name = 'House Values';
                pro.ProductCode = 'HV-001';
            }else if(i==9){
                pro.Name = 'HomeIntelle Hub';
                pro.ProductCode = 'HIH-001';
            }
            else{
              pro.Name = 'Top Producer Website';  
            }
            proList.add(pro);
        }
        insert proList;
        
        Id stdId = Test.getStandardPricebookId();
       //pricebook2 pb = [select id from pricebook2 where id =:str];
        
        List<PriceBookEntry> pbEntryList = new List<PriceBookEntry>();
        for(product2 pro : proList){
            PriceBookEntry pbEntry = new PriceBookEntry();
            pbEntry.Pricebook2Id =stdId;
            pbEntry.Product2Id = pro.id;
            pbEntry.UnitPrice = 1;
            pbEntry.IsActive = true;
            pbEntryList.add(pbEntry);
        }
        insert pbEntryList;		
        
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
        for(product2 pro :proList){
        SBQQ__Subscription__c subscrb = new SBQQ__Subscription__c();
        subscrb.SBQQ__Account__c = acc.Id ;
        subscrb.SBQQ__Contract__c = contr.Id ;
        subscrb.SBQQ__Quantity__c = 2 ;
        subscrb.SBQQ__Product__c = pro.Id ;
        subscriptionList.add(subscrb);
        } 
        
        
        insert subscriptionList ;
        
        
        List<SBQQ__Subscription__c> subscriptionList2 = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c subs : subscriptionList){
            subs.SBQQ__Quantity__c = 1;
            subscriptionList2.add(subs);
        }
        Test.startTest();
        update subscriptionList2 ;
        Test.stopTest();
        
    }
    @isTest static void PorductOnAccountFromSubsHandler_Method2(){
        
        
         Account acc = new account();
        acc.name = 'account1';
        insert acc ;
        
        contract contr = new contract();
        contr.AccountId = acc.id;
        contr.Status = 'draft';
        contr.StartDate = date.today() ;
        contr.ContractTerm = 2 ;
        contr.SBQQ__Evergreen__c = true;
        insert contr ;
        
        
        
        
        List<product2> proList = new List<product2>();
        for(integer i=0 ; i<11 ; i++){
            product2 pro = new product2();
            if(i==0){
                pro.Name = 'FiveStreet';
            }else if(i==1){
                pro.Name = 'Market Snapshot';
       	     }else if(i==2){
                pro.Name = 'Top Producer Assistant License';
            }else if(i==3){
                pro.Name = 'Top Producer CRM';
            }else if(i==4){
                pro.Name = 'Top Producer Pro';
            }else if(i==5){
                pro.Name = 'Top Producer Pro Plus';
            }else if(i==6){
                pro.Name = ProductNames.TPHI;
            }else if(i==7){
                pro.Name = 'Social Connect 500';
            }else if(i==8){
                pro.Name = 'House Values';
                pro.ProductCode = 'HV-001';
            }else if(i==9){
                pro.Name = 'HomeIntelle Hub';
                pro.ProductCode = 'HIH-001';
            }
            else{
              pro.Name = 'Top Producer Website';  
            }
            proList.add(pro);
        }
        insert proList;
        
        Id stdId = Test.getStandardPricebookId();
       //pricebook2 pb = [select id from pricebook2 where id =:str];
        
        List<PriceBookEntry> pbEntryList = new List<PriceBookEntry>();
        for(product2 pro : proList){
            PriceBookEntry pbEntry = new PriceBookEntry();
            pbEntry.Pricebook2Id =stdId;
            pbEntry.Product2Id = pro.id;
            pbEntry.UnitPrice = 1;
            pbEntry.IsActive = true;
            pbEntryList.add(pbEntry);
        }
        insert pbEntryList;		
        
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
        for(product2 pro :proList){
        SBQQ__Subscription__c subscrb = new SBQQ__Subscription__c();
        subscrb.SBQQ__Account__c = acc.Id ;
        subscrb.SBQQ__Contract__c = contr.Id ;
        subscrb.SBQQ__Quantity__c = 2 ;
        subscrb.SBQQ__Product__c = pro.Id ;
        subscriptionList.add(subscrb);
        } 
        
        
        insert subscriptionList ;
        
        
        List<SBQQ__Subscription__c> subscriptionList2 = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c subs : subscriptionList){
            subs.SBQQ__Quantity__c = 4;
            subscriptionList2.add(subs);
        }
        Test.startTest();
        update subscriptionList2 ;
        Test.stopTest();
        
    }
}