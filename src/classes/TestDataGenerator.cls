@isTest
public without sharing class TestDataGenerator {
    private TestDataGenerator() {}

    //Salesforce SObjects
    public static Account createAccount() {
        return createAccount(null);
    }

    public static Account createAccount(String accountNumber) {
        Account account = new Account(
            AccountNumber                      = accountNumber,
            Name                               = 'TESTEO',
        );

        return account;
    }

    public static Contact createContact(Id accountId) {
        Contact contact = new Contact(
            AccountId                      = accountId,
            Email                          = 'a@a.it',
            Fax                            = '+39666666',
            FirstName                      = 'Francesco',
            LastName                       = 'Carmagnola',
            Phone                          = '+39666666',
            Salutation                     = 'Mister'
        );

        return contact;
    }

 
    public static User createUser(String profileName) {
        return createUser(Profiles.ALL_PROFILES_BY_NAME.get(profileName).Id);
    }

    public static User createUser(Id profileId) {
        User user = new User(
            Alias             = 'nustesx',
            Email             = 'newuser@testorg.com',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName          = 'Testing',
            LocaleSidKey      = 'en_US',
            ProfileId         = profileId,
            TimeZoneSidKey    = 'America/Los_Angeles',
            UserName          = 'newuser99@testorg.com.'+UtilTest.createRandomNumber()
        );
        return user;
    }
}