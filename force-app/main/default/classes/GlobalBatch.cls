/*
Developer: Zeeshan Ahmed
Created on: 08 April 2022
Description: This is a Batcher calles the calculator Class implementing the ICalculate Interface
*******************************************************************************************************************
Purpose:-
This class a general purpose Batcher class and will be used for executing any Batch Apex,
It expects the 2 parameters. The Calculator Class and the SOQL query in the String form.
This class will be called from a Scheduler class (the class which implements Schedulable interface)
At the End if there is any failure then it sends an Email to the User (under which the Job is scheduled) 

*/
global class GlobalBatch implements Database.Batchable<SObject>, Database.Stateful , Database.AllowsCallouts
{  
    Private String query; 
    ICalculate Calculator;
    public GlobalBatch(string q,  ICalculate calc) 
    {
        query = q;
        Calculator = calc;
        System.debug('query: '+query);
    }
    
    global Database.Querylocator start(Database.BatchableContext context){    
        return Database.getQueryLocator(query);  }  
    
    global void execute(Database.BatchableContext context, List<SObject> records){       
        try{
            Calculator.calculate(records);
        }  
        catch(system.Exception exp)
        { 
            system.debug('Gloabl Batch error message: ' +exp.getMessage());
            throw exp;
        }            
    }
    global void finish(Database.BatchableContext context){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id =:context.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.  
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Sharing Recalculation ' + a.Status);
        mail.setHtmlBody('The batch Apex job for '+ Calculator.Name() +' processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.<br/><br/>'+a.ExtendedStatus);
        if(a.NumberOfErrors > 0)
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }  
}