public with sharing class STMStakeholderHelper {
    private static final String DEFAULT_PICKLISTS_VALUE    = '1';
    private static final String STM_ACTIVE                 = 'STMActive__c';
    private static final String STM_PERSON_ACC_ACTIVE      = 'STMActive__pc';
    private static final String STM_PERSON_CONTACT_ID      = 'PersonContactId';
    private static final String STM_IS_PERSON_ACCOUNT      = 'IsPersonAccount';
    private static final String SPACE                      = ' ';
    private static final String UNDERLINE                  = '_';
    private static final String HYPHEN                     = '-';
    private static final String f_FIRST_NAME               = 'FirstName';
    private static final String f_LAST_NAME                = 'LastName';
    private static final String f_TYPE                     = 'type';
    private static final String f_PERSON_BIRTH_DATE        = 'personBirthDate';
    private static final String BIRTH_DATE                 = 'Birthdate';
    private static final String f_SPECIALIZATION_EXPERTISE = 'STMStkhSpecializationExpertise__c';
    
    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @description  Massive insertion of Stakeholders from an Issue
    *               RelatedTo:
    *                   JIRA issue: STM-163
    *                   https://svnbud.epam.com/tccc-stm2/documents/requirements/[TCCC STMG2] Technical Development.doc 
    * @param        stakeholders list of contacts which will be linked to issue
    * @param        issueId sfdc ID of issue which will be parent for inserted STMIssueScore__c
    * @return       status of operation
    */
    public static String insertIssueScores(List<Contact> stakeholders, String issueId) {
        System.debug(loggingLevel.INFO, 'INFO: STMStakeholderHelper.insertIssueScores is started');
        String result = '';
        List<STMIssueScore__c> issueScoresToInsert = new List<STMIssueScore__c>();
        STMIssueScore__c tmpIssueScore = null;
        
        for (Contact c: stakeholders) {
            tmpIssueScore = null;
            if (c != null) {
                tmpIssueScore = new STMIssueScore__c();
                tmpIssueScore.Contact__c = c.Id;
                tmpIssueScore.SizeSupportBaseFollowersAliances__c   = DEFAULT_PICKLISTS_VALUE;
                tmpIssueScore.InterestInIssuesMatterYou__c          = DEFAULT_PICKLISTS_VALUE;
                tmpIssueScore.GenerallyRecognizedExperts__c         = DEFAULT_PICKLISTS_VALUE;
                tmpIssueScore.LevelInfluencePolicyMakers__c         = DEFAULT_PICKLISTS_VALUE;
                tmpIssueScore.AttitudeCocaCola__c                   = DEFAULT_PICKLISTS_VALUE;
                tmpIssueScore.AttitudeFoodDrinkIindustry__c         = DEFAULT_PICKLISTS_VALUE;
                tmpIssueScore.AbilityLeadShapePublicOpinion__c      = DEFAULT_PICKLISTS_VALUE;
                tmpIssueScore.Issue__c = issueId;
                
                issueScoresToInsert.add(tmpIssueScore);
            }
        }
        
        if (issueScoresToInsert.size() != null) {
            try {
                insert issueScoresToInsert;
                System.debug( Logginglevel.INFO , 'insertIssueScore:issueScoresToInsert.size() == ' 
                        + issueScoresToInsert.size());
                result = issueScoresToInsert.size() + ' issue scores was inserted successfully.';
            } catch (System.DMLException ex) {
                System.debug(loggingLevel.ERROR, 'ERROR:' + ex);
                result = 'the error occurred, contact your system administrator.';
            }
        }  
        return result;
    }
    
    public static String scoreNormalizer(String score) {
        score = score.normalizeSpace();        
        score = score.replace(' ','');
        score = score.replace('.','');
        score = score.replace('0', '');
        return score;
    }
    
    /**
     * @author          Pavel Slepenkov
     * @description     helper method for trigger to delete all Issue Scores records related to Accounts/Contacts deactivated
     *                  update 12 Mar 2013 Jira task STM-425:Triggering: Whenever an Account/Contact is created/updated 
     *                  by a Regular User or Database Administrator.
     * @param           Stakeholders 
     */
    public static void removeRelatedIssueScores(List<sObject> stakeholders) {
        Set<Id> allowedProfiles = (new Map<Id,SObject>([SELECT Id FROM Profile WHERE Name =: STMCommonConstants.PROFILE_STMG_REGULAR_USERS_PAC_TEAM 
                                                        OR Name =: STMCommonConstants.PROFILE_STMG_DATABASE_ADMINISTRATOR
                                                        OR Name =: STMCommonConstants.PROFILE_STMG_CAMPAIGN_MANAGER])).keySet();
        if (allowedProfiles.contains(UserInfo.getProfileId())) {
            List<Id> stakeholdersIds = new List<Id>();
            List<STMIssueScore__c> issueScores = new List<STMIssueScore__c>();
            for (sObject c: stakeholders) {
                if ((Boolean)c.get(STM_IS_PERSON_ACCOUNT)) {
                    if (!(Boolean)c.get(STM_PERSON_ACC_ACTIVE)) {
                        stakeholdersIds.add((Id)c.get(STM_PERSON_CONTACT_ID));
                    }  
                } else if (!(Boolean)c.get(STM_ACTIVE)) {
                    stakeholdersIds.add(c.Id);
                }            
            }
            if (stakeholdersIds != null && stakeholdersIds.size() > 0) {
                issueScores = [SELECT Id FROM STMIssueScore__c WHERE Contact__c IN:stakeholdersIds];
                if (issueScores != null && issueScores.size() > 0) {
                    List<Id> issueScoreIds = new List<Id>();
                    for (STMIssueScore__c issueScore: issueScores) {
                        issueScoreIds.add(issueScore.id);
                    }
                    delete [SELECT Id FROM STMIssueScoreHistory__c WHERE IssueScore__c IN:issueScoreIds];
                    delete issueScores;
                }            
            }
        }
       
    }


    /**
     * @author Pavel Slepenkov
     * @param stakeholdersIds is a list of updated contacts or person account from Trigger.new
     */
    public static void fillStakeholderKey(List<sObject> stakeholders) {
        String key, firstName, lastName,type, personBirthDate, subSpec, birthDate;
        
        for (sObject c: stakeholders) {
            firstName = String.valueOf(c.get(f_FIRST_NAME));
            lastName = String.valueOf(c.get(f_LAST_NAME));
            
            if ((Boolean)c.get(STM_IS_PERSON_ACCOUNT)) {
                               
                type = String.valueOf(c.get(f_TYPE)) != null ? String.valueOf(c.get(f_TYPE)) : '';
                personBirthDate = String.valueOf(c.get(f_PERSON_BIRTH_DATE)) != null ?  String.valueOf(c.get(f_PERSON_BIRTH_DATE)) : '';
                key =  firstName + UNDERLINE + lastName + UNDERLINE + type + UNDERLINE + personBirthDate;
                key = key.replace(SPACE,UNDERLINE);
                key = key.toLowerCase();
                c.put('STMStakeholderKey__pc', key); 
            } else {
                                
                /* @TODO subSpec = String.valueOf(c.get(f_SPECIALIZATION_EXPERTISE)) != null ?
                        String.valueOf(c.get(f_SPECIALIZATION_EXPERTISE)) : '';*/
                birthDate = String.valueOf(c.get(BIRTH_DATE)) != null ? String.valueOf((Date)c.get(BIRTH_DATE)) : '';
                key = firstName + UNDERLINE + lastName + UNDERLINE /*+ subSpec*/ + UNDERLINE + birthDate;
                key = key.replace(SPACE,UNDERLINE);
                key = key.replace(HYPHEN,UNDERLINE);
                key = key.toLowerCase();
                c.put('STMStakeholderKey__c', key); 
            }
        }        
    }
}