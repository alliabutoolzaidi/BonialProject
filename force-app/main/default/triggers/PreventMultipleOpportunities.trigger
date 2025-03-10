/**
 * @description Trigger to prevent users from creating multiple open Opportunities within the same week.
 * @trigger PreventMultipleOpportunities
 * @author Allia Butool
 * @date 10th March 2025

 * This trigger checks if a user has already created an open Opportunity 
 * in the current week (excluding 'Closed Won' and 'Closed Lost' stages). If so, it prevents 
 * the insertion of a new Opportunity and provides an error message with a link to the existing record.
 * You will be able to navigate to the link in Classic but not in Lightning. In Lightning it will be shown as a plain text.
**/
trigger PreventMultipleOpportunities on Opportunity (before insert) {
    PreventMultipleOpportunitiesHandler.validateOpportunities(Trigger.new);
}