/*
*@ Apex Name         : PreventMultipleOpportunitiesHandler                
*@ CreatedBy         : Allia Butool
*@ CreatedOn         : 11-MAR-2025
*@ Description       : This class prevents users from creating multiple open Opportunities within the same week.
*/
public with sharing class PreventMultipleOpportunitiesHandler {
    public static void validateOpportunities(List<Opportunity> newOppRecords) {
        Set<Id> ownerIds = new Set<Id>();

        
        for (Opportunity opp : newOppRecords) {
            ownerIds.add(opp.OwnerId);
        }

        if (!ownerIds.isEmpty()) {
            
            Map<Id, Opportunity> existingOpportunity = new Map<Id, Opportunity>();
            for (Opportunity existing : [
                SELECT Id, Name, OwnerId, StageName 
                FROM Opportunity 
                WHERE OwnerId IN :ownerIds 
                AND CreatedDate = THIS_WEEK 
                AND StageName NOT IN ('Closed Won', 'Closed Lost')
            ]) {
                existingOpportunity.put(existing.OwnerId, existing);
            }

          
            for (Opportunity opp : newOppRecords) {
                if (existingOpportunity.containsKey(opp.OwnerId)) {
                    Opportunity existingOpp = existingOpportunity.get(opp.OwnerId);
                    
                  
                    String baseUrl = URL.getOrgDomainUrl().toExternalForm();
                    String recordUrl = baseUrl + '/' + existingOpp.Id;
                    
                 
                    opp.addError('You already have an open Opportunity this week! Please close it: <a href="' + recordUrl + '"> ' + existingOpp.Name + ' </a>', false);
                }
            }
        }
    }
}