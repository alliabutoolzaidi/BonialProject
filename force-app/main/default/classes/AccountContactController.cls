/*
*@ Apex Name         : "AccountContactController"                
*@ CreatedBy         : Allia Butool
*@ CreatedOn         : 11-MAR-2025
*@ Description       : This class is used to fetch Accounts and their related Contacts.
*/
public with sharing class AccountContactController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name FROM Account];
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByAccountId(String accountId) {
        return [SELECT Id, FirstName, LastName,Email, MobilePhone, AccountId FROM Contact WHERE AccountId = :accountId];
        
    }
}