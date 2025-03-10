@isTest
public class PreventMultipleOpportunitiesHandlerTest {
    
    @testSetup
    static void setupTestData() {
     
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'testusr',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Opportunity existingOpp = new Opportunity(
            Name = 'Existing Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            OwnerId = testUser.Id
        );
        insert existingOpp;
    }

    @isTest
    static void testPreventMultipleOpportunities() {
       
        User testUser = [SELECT Id FROM User WHERE Email LIKE 'testuser@example.com%' LIMIT 1];

       
        Opportunity newOpp = new Opportunity(
            Name = 'New Opportunity',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(15),
            OwnerId = testUser.Id
        );

   
        Test.startTest();
        try {
            insert newOpp;
            System.assert(false, 'Expected an exception but none was thrown.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('You already have an open Opportunity this week!'),
                'Expected validation error message not found.');
        }
        Test.stopTest();
    }

    @isTest
    static void testAllowNewOpportunityIfNoExistingOne() {
  
        User newUser = new User(
            FirstName = 'New',
            LastName = 'User',
            Email = 'newuser@example.com',
            Username = 'newuser@example.com' + System.currentTimeMillis(),
            Alias = 'newusr',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert newUser;

       
        Opportunity newOpp = new Opportunity(
            Name = 'Fresh Opportunity',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(10),
            OwnerId = newUser.Id
        );

      
        Test.startTest();
        insert newOpp;
        Test.stopTest();

        
        Opportunity insertedOpp = [SELECT Id FROM Opportunity WHERE Name = 'Fresh Opportunity' LIMIT 1];
        System.assertNotEquals(null, insertedOpp, 'Opportunity should have been inserted successfully.');
    }
}