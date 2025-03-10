@isTest
public class AccountContactController_Test {
    
    @testSetup
    static void setupTestData() {
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
       
        Contact testContact1 = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@test.com', 
                                           MobilePhone = '1234567890', AccountId = testAccount.Id);
        Contact testContact2 = new Contact(FirstName = 'Jane', LastName = 'Smith', Email = 'jane.smith@test.com', 
                                           MobilePhone = '0987654321', AccountId = testAccount.Id);
        insert new List<Contact>{testContact1, testContact2};
    }
    
    @isTest
    static void testGetAccounts() {
        
        Test.startTest();
        List<Account> accounts = AccountContactController.getAccounts();
        Test.stopTest();
        
        System.assertEquals('Test Account', accounts[0].Name, 'Expected account name to match');
    }
    
    @isTest
    static void testGetContactsByAccountId() {
       
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
     
        Test.startTest();
        List<Contact> contacts = AccountContactController.getContactsByAccountId(testAccount.Id);
        Test.stopTest();
        
        System.assertEquals(2, contacts.size(), 'Expected 2 contacts for the test account');
    }
}