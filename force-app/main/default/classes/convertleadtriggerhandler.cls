public class convertleadtriggerhandler {
    public static boolean stoptrigger = false; 
    public static void leadAccountInsert(list<lead> leadList){
        
    }
    public static void leadupdate(list<lead> leadlist)
    {   
        try
        {  
            list<contact> contactexistListupdate = new list<contact>();
            list<contact> DeletExtraContact = new list<contact>();
            List<Account> accList=new List<Account>();
            List<Account> DeleteaccList=new List<Account>();
            List<Account> insertAccList = new List<Account>();
            list<SBQQ__Quote__c> quotelist = new list<SBQQ__Quote__c>();
            list<opportunity> Opplist = new list<opportunity>();
            List<Account> AccountListupdate = new List<Account>();
            List<contact> contactListupdate = new List<contact>();
            list<lead> AccountExistLeadList = new list<lead>();
            list<lead> AccountNotExistLeadList = new list<lead>();
            list<opportunity> ifOpplist = new list<opportunity>();
            Id BrokerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
            Id AgentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            Id TeamRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Team').getRecordTypeId();
            string Accounttypeid = '';
            string updateexistaccountid = '';
            string emails = '';
            string Phones = '';
            list<lead> leadobjList = new list<lead>([select id,Converted__c, Email, Phone , Account_type__c,Company, name,Account__r.Name , Account__c,Account__r.recordTypeId,IsConverted, Status from lead where id in: leadlist And IsConverted=FALSE WITH SECURITY_ENFORCED]);
            
            
            /*    for(lead l : leadobjList)
{

updateexistaccountid = l.Account__c;
emails = l.Email;
Phones = l.Phone;
} */
            
            Set<id> AccId = new Set<Id>();
            
            for(lead leadobj : leadobjList )
            {
                if(leadobj.Account_type__c == 'Broker'){
                    Accounttypeid = BrokerRecordTypeId;
                    //  system.debug('Broker account type == >> '+Accounttypeid);
                }else if(leadobj.Account_type__c == 'Agent') {
                    Accounttypeid = AgentRecordTypeId;
                    //  system.debug('Agent type == >> '+Accounttypeid);
                }else if(leadobj.Account_type__c == 'Team'){
                    Accounttypeid =  TeamRecordTypeId;
                    //   system.debug('Team type == >> '+Accounttypeid);
                }
                
                AccId.add(leadobj.Account__c);
                
            }
            
            
            
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            
            for(lead leadstats:leadobjList )
            {  	
                
                if(leadstats.Status == 'Working - Open Deal' && leadstats.IsConverted == false)
                {   
                    if(leadstats.Account__c!=null  )
                    {
                        AccountExistLeadList.add(leadstats);
                    }
                    else
                    {
                        
                        AccountNotExistLeadList.add(leadstats);
                        
                    } 
                }
            }
            
            for(lead ExistAcclead: AccountExistLeadList)
            {
                
               
                List<Database.LeadConvert> convertedResult=new List<Database.LeadConvert>();
                Database.LeadConvert lc = new Database.LeadConvert();
                
                lc.setLeadId(ExistAcclead.id);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                convertedResult.add(lc);
                
                convertleadtriggerhandler.stoptrigger = true;
                
                set<id> setAccountID=new set<Id>();
                updateexistaccountid = ExistAcclead.Account__c ;
                string oppid='';
                string conid = '';
                string Accountid = '';
                
                
                for(Database.LeadConvertResult lctemp:  Database.convertLead(convertedResult))
                {
                    
                    oppid = lctemp.getOpportunityId();
                    
                    setAccountID.add(lctemp.getAccountId());
                    
                    conid = lctemp.getContactId();
                    Accountid = lctemp.getAccountId();
                    
                    contact con = new contact();
                    con = [Select id,Email, Phone, FirstName, LastName, isPrimaryContact__c  from contact where id=:conid];
                    con.isPrimaryContact__c = true;
                    con.AccountId = updateexistaccountid;
                    system.debug('Contact id ==>>'+con.id);
                    contactexistListupdate.add(con);
                    
                    
                    Account accountObj = new account();
                    accountObj = [Select  Email__c, Phone  from Account where id=:lctemp.getAccountId()];
                    DeleteaccList.add(accountObj);
                    
                    opportunity opp = new opportunity(id =oppid,  name = 'Opp '+ date.today().format(), StageName = 'In Progress');
                    opp = [Select name, StageName from opportunity where id=:lctemp.getOpportunityId()];
                    opp.name = ExistAcclead.Company;
                    opp.AccountId = updateexistaccountid;
                    opp.StageName = 'In Progress';
                    system.debug('Opportunity id ==>>'+opp.id);
                    
                    ifOpplist.add(opp);
                }
                
                
            }
            
            for(lead NotExistAcclead: AccountNotExistLeadList)
            {
                List<Database.LeadConvert> convertedResult=new List<Database.LeadConvert>();
                Database.LeadConvert lc = new Database.LeadConvert();
                
                lc.setLeadId(NotExistAcclead.id);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                convertedResult.add(lc);
                
                convertleadtriggerhandler.stoptrigger = true;
                
                set<id> setAccountID=new set<Id>();
                
                string oppid='';
                string conid = '';
                string Accountid = '';
                updateexistaccountid = NotExistAcclead.Account__c;
                emails = NotExistAcclead.Email;
                Phones = NotExistAcclead.Phone;
                NotExistAcclead.Converted__c = true;
                
                for(Database.LeadConvertResult lctemp:  Database.convertLead(convertedResult))
                {
                    
                    oppid = lctemp.getOpportunityId();
                    
                    setAccountID.add(lctemp.getAccountId());
                    
                    
                    conid = lctemp.getContactId();
                    Accountid = lctemp.getAccountId();
                    contact con = new contact();
                    con = [Select Email, Phone, FirstName, LastName, isPrimaryContact__c from contact where id=:conid];
                    con.isPrimaryContact__c = true;
                     system.debug('Opportunity id ==>>'+con.id);
                    contactListupdate.add(con);
                    
                    
                    Account accountObj = new account();
                    accountObj = [Select Converted__c, name,Email__c, Phone  from Account where id=:Accountid];
                    system.debug('Check converted '+accountObj.Converted__c);
                    accountObj.Email__c = emails;
                    accountObj.Phone = Phones;
                    accountObj.blng__BillToContact__c = conid;
                    string Accname = accountObj.name;
                    //     system.debug('Account names ====>>>>>> '+Accname);                 
               //     DeletExtraContact = [SELECT id, name from contact where AccountId =: Accountid AND (name =: Accname)];
                    //     system.debug('contact names ====>>>>>> '+DeletExtraContact);
                    
                    if(Accounttypeid != null)
                    {
                        accountObj.RecordTypeId = Accounttypeid;
                    }
                    else
                    {
                        accountObj.RecordTypeId = BrokerRecordTypeId;
                    }
                    AccountListupdate.add(accountObj);
                    
                    opportunity opp = new opportunity();
                    opp = [Select name, StageName from opportunity where id=:lctemp.getOpportunityId()];
                    opp.name = 'Opp '+ date.today().format();
                     system.debug('Opportunity id ==>>'+opp.id);
                    opp.StageName = 'In Progress';
                    
                    Opplist.add(opp);
                }
                
                
            }
            update Opplist;
            update AccountListupdate;
            update contactexistListupdate;
            update contactListupdate;
            update ifOpplist;
        //    delete DeletExtraContact;
            //   insert oppList;
            update acclist;
            insert quotelist;
            update AccountExistLeadList;
            delete DeleteaccList;
            
        }
        catch(Exception e){
            System.debug('Error1-->'+e.getMessage());
            System.debug('Linme-->'+e.getLineNumber());
        }
    }
    
}