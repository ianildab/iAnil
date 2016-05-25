// It's posibly that some methods may exist on other Class from other prooject stream, like ECIC.., etc,
 // Do not merge it, because applications may to move to other org separately
@isTest
public class STMTestHelper {
  
  public static final User currentUser = [SELECT Id, Country_Code__c FROM User WHERE Id = :UserInfo.getUserId()];
  
    public static final String STAKEHOLDER_CONTACT_NAME                 = 'contactStakeholder';
    public static final String STAKEHOLDER_ACCOUNT_NAME                 = 'accountStakeholder';
    public static final String BUSINESS_ACCOUNT_NAME                    = 'TestBusinessAccount';
    public static final String STAKEHOLDER_SPECIALIZATION_EXPERTISE     = 'Newspaper';
    public static final String STAKEHOLDER_SUBSPECIALIZATION_SUBEXPERTI = 'General';
    public static final String ENGAGEMENT_STATUS                        = 'Neutral';
    public static final String BUSINESS_ACCAUNT_TYPE                    = 'Media';
    public static final String DEFAULT_SCORE                            = '1';
    public static final String ISSUE_CATEGORY                           = 'Health & Wellness';
    public static final String ISSUE_OBJECT                             = 'Active Lifestyle';
    public static final String ISSUE_TAG                                = 'Sports';
    public static final String EMAIL                                    = 'test@test.test';
    public static final Integer AMOUNT_TEST_RECORDS                     = 200;
    
    
    public static Contact contact;
    public static Account businessAccount;
    public static Account personAccount;
    public static STMIssue__c issue;
    public static STMIssueScore__c issueScore;
    
    public static List<Contact> contacts;
    public static List<Account> accounts;
    public static List<Account> personAccounts;
    public static List<STMIssue__c> issues;
    public static List<STMIssueScore__c> issueScores;
    
    
    
    public static void initTestEnvironment(Boolean isBulk) {
      if (isBulk) {
            accounts        = new List<Account>();
            personAccounts  = new List<Account>();
            contacts        = new List<Contact>();
            issues          = new List<STMIssue__c>();
            issueScores     = new List<STMIssueScore__c>();
        
            for (Integer i = 0; i < AMOUNT_TEST_RECORDS; i++) {
                if (i < AMOUNT_TEST_RECORDS/2) {
                    accounts.add(createCompany(BUSINESS_ACCOUNT_NAME + i));
                } else {
                    personAccounts.add(createPersonAccount(STAKEHOLDER_ACCOUNT_NAME+i));
                }
            }
          insert accounts;
          insert personAccounts;
          
          Contact tmpContact;
          for (Integer i = 0; i < AMOUNT_TEST_RECORDS/2; i++) {
              tmpContact = createStkhContact(STAKEHOLDER_CONTACT_NAME + i, accounts[i] );
              tmpContact.STMActive__c = false;
              contacts.add(tmpContact);
          }
          insert contacts;
          List<STMG_Type__c> types = new List<STMG_Type__c>();
          for (Integer i = 0; i < contacts.size(); i++) {
              types.add(createType(contacts[i]));
              contacts[i].STMActive__c = true;
          }
          Database.insert(types);
          Database.update(contacts);
          
          issues.add(createIssue());
          insert issues;
          
          for (STMIssue__c i: issues) {
            Integer j = 0;
            while (j < AMOUNT_TEST_RECORDS/2) {
                issueScores.add(createIssueScore(personAccounts[j],i));
              issueScores.add(createIssueScore(contacts[j],i));
                j++;
            }
          }
          insert issueScores;
          
      } else {
        contact = getStkhContact();
        businessAccount = getCompany();
        personAccount = getPersonAccount();
        issue = getIssue();
        insert createIssueScore(contact, issue);
        insert createIssueScore(personAccount, issue);
        
      }        
    }
    
    /**
    * @author          Pavel Slepenkov (Pavel_Slepenkov@epam.com).
    * @date            13 Feb 2013
    * @description     The vrapper method for createTestUser() & initTestEnvironment() methods
    * @param           String masterDataMode define a mode of insertion Action Plan related objects
    * @param           String[] userParam - parameters for user creation: username, profileName, userRole, countryCode
    * @return          User which is owner of masterData objects & custom settings
    */
    public static User initTestEnvironmentByUser(Boolean isBulk, String[] userParam) {
        User u = createTestUser(userParam[0], userParam[1], userParam[2], userParam[3]);
        System.runAs(u) {
            initTestEnvironment(isBulk);
        }
        return u;
    }
  
//*********************************************** Account & Contact section ********************************************
    
    public static Account createCompany(String name) {
        return new Account( RecordTypeId    = STMCommonConstants.STMG_BUS_ACC_RECTYPE_ID,
                            Type            = BUSINESS_ACCAUNT_TYPE,
                            Name            = name
                );
    }
    
    public static Account getCompany() {
        Account account = createCompany('testAccount');
        insert account;
        return [SELECT Id,Name, Type, isPersonAccount FROM Account WHERE Id =:account.Id];
    }
    
    public static Account createStkhAccount(String name) {
        return new Account( RecordTypeId    = STMCommonConstants.PERS_ACC_ACTIVE_RECTYPE_ID,
                            firstName       = name,
                            lastName        = 'last' + name,
                            PersonEmail     = EMAIL);
    }
    
    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         25 Feb 2013
    * @description  Default stm test personal account creation
    */
    public static Account createPersonAccount(String name) {
       return new Account(RecordTypeId    = (Id)STMCommonConstants.PERS_ACC_ACTIVE_RECTYPE_ID,
                          firstName       = generateUniqueName(name),
                          lastName        = generateUniqueName(name),
                          STMActive__pc   = false,
                          PersonEmail     = EMAIL);
    }
    
    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         25 Feb 2013
    * @description  create and  insert default person account to DB
    */
    public static Account getPersonAccount() {
        if (personAccount == null) {
            personAccount = createPersonAccount('Person Account');
            System.debug( '@#@#@#' + personAccount.IsPersonAccount );
            insert personAccount;
            insert createType([SELECT id, PersonContactId, RecordTypeId, Name, isPersonAccount, Active__c FROM Account WHERE Id =: personAccount.Id]);
            personAccount.STMActive__pc = true;
            update personAccount;
        }
        return [SELECT id, PersonContactId, RecordTypeId, Name, isPersonAccount, Active__c  FROM Account WHERE Id =: personAccount.Id];
    }
    
    public static Contact createStkhContact(String name, Account account) {
        return new Contact( firstName                         = name,
                            lastName                          = 'last'+name,
                            Account                           = account,
                            STMActive__c                      = false,
                            Email                             = EMAIL
                );
    }
    
    public static Contact getStkhContact() {
        if (contact == null) {
            contact = createStkhContact('testContact', getCompany());
            insert contact;
            insert createType(contact);
            contact.STMActive__c = true;
            update contact;
            return [SELECT Id, Name 
                    FROM Contact
                    WHERE Id =:contact.Id];
        } else {
            return contact;
        }        
    }
    
//*********************************************** Issue section ********************************************************
    
    public static STMIssue__c createIssue() {
        return new STMIssue__c( Name             = 'Issue' + String.valueOf(ECICTestHelperAddon.getUniqueRandom() * 1000),
                                IssueCategory__c = ISSUE_CATEGORY,
                                IssueObject__c   = ISSUE_OBJECT,
                                IssueTag__c      = ISSUE_TAG
                );
    }
    
    public static STMIssue__c getIssue() {
        if (issue == null) {
            issue = createIssue();
            insert issue;
            return [SELECT  Id,
                            Name,
                            IssueCategory__c,
                            IssueObject__c,
                            IssueTag__c
                    FROM STMIssue__c
                    WHERE Id =:issue.Id];
        } else {
            return issue;
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------
    /**
  * @author     Pavel Slepenkov (Pavel_Slepenkov@epam.com)
  * @date           26 Feb 2013
  * @description    create STMIssueScore__c record based on stakeholder & issue
  */
  public static STMIssueScore__c createIssueScore(sObject stakeholder, STMIssue__c parentIssue) {
    if (String.valueOf(stakeholder.getSObjectType()) != 'Account' && String.valueOf(stakeholder.getSObjectType()) != 'Contact') {
        throw new STMException('Incorrect sObject type was passed to createIssueScore():: expected: Account or Contact, but was found:' 
        + String.valueOf(stakeholder.getSObjectType()));
    } else {
      Id stkhId = String.valueOf(stakeholder.getSObjectType()) == 'Contact' ? (Id)stakeholder.get('Id') : (Id)stakeholder.get('PersonContactId');
      return new STMIssueScore__c( 
                                Issue__c                            = parentIssue.Id,
                                Contact__c                          = stkhId,
                                Position__c                         = 'Neutral',
                                AttitudeCocaCola__c                 = DEFAULT_SCORE,
                                AbilityLeadShapePublicOpinion__c    = DEFAULT_SCORE,
                                AttitudeFoodDrinkIindustry__c       = DEFAULT_SCORE,
                                GenerallyRecognizedExperts__c       = DEFAULT_SCORE,
                                InterestInIssuesMatterYou__c        = DEFAULT_SCORE,
                                LevelInfluencePolicyMakers__c       = DEFAULT_SCORE,
                                SizeSupportBaseFollowersAliances__c = DEFAULT_SCORE            
                );   
    }
  }
    
    
    public static STMIssueScore__c createIssueScore(STMIssue__c parentIssue) {
        return new STMIssueScore__c( 
                                Issue__c                            = parentIssue.Id,
                                Contact__c                          = getStkhContact().Id,
                                Position__c                         = 'Neutral',
                                AttitudeCocaCola__c                 = DEFAULT_SCORE,
                                AbilityLeadShapePublicOpinion__c    = DEFAULT_SCORE,
                                AttitudeFoodDrinkIindustry__c       = DEFAULT_SCORE,
                                GenerallyRecognizedExperts__c       = DEFAULT_SCORE,
                                InterestInIssuesMatterYou__c        = DEFAULT_SCORE,
                                LevelInfluencePolicyMakers__c       = DEFAULT_SCORE,
                                SizeSupportBaseFollowersAliances__c = DEFAULT_SCORE            
                );        
    }
    
    public static STMIssueScore__c createIssueScore() {
       return  createIssueScore(getIssue());
    }

    public static STMIssueScore__c getIssueScore() {
        STMIssueScore__c result= createIssueScore();
        insert result;
        return [SELECT 
                        Issue__c,
                        Contact__c,
                        Position__c,
                        AttitudeCocaCola__c,
                        AbilityLeadShapePublicOpinion__c,
                        AttitudeFoodDrinkIindustry__c,
                        GenerallyRecognizedExperts__c,
                        InterestInIssuesMatterYou__c,
                        LevelInfluencePolicyMakers__c,
                        SizeSupportBaseFollowersAliances__c,
                        AttitudeScore__c,
                        InfluenceScore__c
                    FROM STMIssueScore__c 
                    WHERE Id =: result.Id];

    }
    
    
    public static void addIssueScoresToSpecifiedIssue(STMIssue__c parentIssue, Integer amountOfIssueScores) {
       List<STMIssueScore__c> linkedIssueScores = new List<STMIssueScore__c>();
       for (Integer i = 0; i < amountOfIssueScores; i++) {
           linkedIssueScores .add(createIssueScore(parentIssue));
       }
       if (linkedIssueScores != null) {
           insert linkedIssueScores;
       }
    }
    
 //********************************************** STMG_Type__c section *************************************************
 
    public static STMG_Type__c createType(sObject linkedObject) {
        STMG_Type__c result = new STMG_Type__c(
                                                Stakeholder_type__c = 'Non-Govenmental Organizations',
                                                Stakeholder_specialization__c = 'Humanitarian',
                                                Stakeholder_subspecialization__c = 'Humanitarian / Emergency aid;Food bank;Human rights;' +
                                                'Social / Economic developement;Education;Social/ working integration;Reasearch;'+
                                                'Environment;Health;Awareness;Volunteering'
                                                );
                     
        if (String.valueOf(linkedObject.getSObjectType()) == 'Account') {
            if (linkedObject.get('IsPersonAccount') == true) {
                result.STMStakeholder_Contact__c = (Id)linkedObject.get('PersonContactId');
            } else {
                result.STMStakeholderAccount__c = (Id)linkedObject.get('Id');
            }
        } else if (String.valueOf(linkedObject.getSObjectType()) == 'Contact') {
            result.STMStakeholder_Contact__c = (Id)linkedObject.get('Id');
        } else {
            throw new STMException('ERROR:: STMTestHelper.createType have got parameter with incorrect type. Correct types: Account & Contact');
        }
        
       return result;
    }


 //------------------------------------Utility methods------------------------------------------------------------------   
   
    /**
  * @author     Pavel Slepenkov (Pavel_Slepenkov@epam.com)
  * @date           25 Feb 2013
  * @description    generate unique name (For test purposes only)
  */
  public static String generateUniqueName(String[] args, Integer maxLength) {
    String result = '';
        for (Integer i = 0; i < args.size(); i++) {
            result += ((args[i]) + '_');
            if (result.length() >= (maxLength - 5)) {
                return (result.substring(maxLength - 5) + (Integer)(ECICTestHelperAddon.getUniqueRandom() * 10000));
            }
        }
        return result;
  }
  
  /**
  * @author     Pavel Slepenkov (Pavel_Slepenkov@epam.com)
  * @date           25 Feb 2013
  * @description    Simplyfied wrapper for generateUniqueName()
  */
  public static String generateUniqueName(String name) {
    return generateUniqueName(new String[]{name}, STMCommonConstants.DEFAULT_NAME_FIELD_LENGTH);
  }
  
    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         1 March 2013
    * @description  The specified email wrapper for generateUniquename
    */
    public static String generateUniqueEmail(String name) {
        return generateUniqueName(new String[]{name}, STMCommonConstants.DEFAULT_NAME_FIELD_LENGTH) + '@test.test';
    }
    
    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         28 Feb 2013
    */
    private static User createTestUser(String profileName, String userRole) {
        User testUser = null;
        //try {
            testUser = new User(Username      = 'test.tccc.cic@test.test',
                            Alias             = 'tccccic', 
                            Email             = EMAIL, 
                            FirstName         = 'John', 
                            LastName          = 'Doe',
                            ProfileId         = [SELECT id FROM profile WHERE Name =: profileName LIMIT 1].id,  
                            UserRoleId        = [SELECT id FROM UserRole WHERE DeveloperName =: userRole LIMIT 1].id,
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey      = 'en_US',
                            EmailEncodingKey  = 'UTF-8',
                            TimeZoneSidKey    = 'America/Los_Angeles');
       /* } catch(System.QueryException qEx) {
            System.debug(loggingLevel.ERROR, 'STMTestHelper.createTestUser:' + qEx);
        }*/
        system.debug('@@@@@@@@' + testUser);
        return testUser;
    }

    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com).
    * @date         28 Feb 2013
    * @description  Method is uses for test purposes. All tests SHOULD use this method for creating appropriate user, which
    *               are runs the test. Method can be used if a tested functionality is role-independent
    * @param        the name of profile which will assigned to new user
    * @return       User with specified profile and DEFAULT role
    */
    public static User createTestUser(String profileName) {
      User testUser;
        System.runAs (currentUser) {
            testUser = createTestUser(profileName, STMCommonConstants.ROLE_DEFAULT);
            insert testUser;
        }       
        return testUser;
    }    
    
  /**
    * @author        Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date          28 Feb 2013
    * @description   Method is uses for test purposes. All tests SHOULD use this method for creating appropriate user, which
    *                are runs the test. Method SHOULD be used if a tested functionality is role-dependent. 
    * @param         username SHOULD be UNIQUE if the method is involved a few times in an one test case.
    * @param         profilename - the name of profile which will assigned to new user
    * @param         userRole - the DeveloperName of role which will assigned to new user
    * @param         countryCode - the Country code which will assigned to new user
    * @return        User with specified userName, profile, userRole, countryCode 
    */
    public static User createTestUser(String username, String profileName, String userRole, String countryCode) {
        User testUser;
        System.runAs (currentUser) { // @TODO What for?
            testUser = createTestUser(profileName, userRole);
            testUser.userName = username;
            testUser.Country_Code__c = countryCode;
            insert testUser;
        }
        return testUser;
    }
    
}