/**
 * ECIC-2216 Infoline Status in Customer Complaint Processes
 */
public class ECICCaseInfolineStatusSetterStrategy extends ECICCaseProcessingStrategyAbstract 
{
    
    @testVisible private Map<Id, User> userByIdMap = null;
    
    public override boolean OnBeforeInsert(List<sObject> newValues) 
    {
        execute((List<Case>)newValues);
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
        execute((List<Case>)newValuesMap.values());
        return true;
    }

    @testVisible private void execute(Case[] casesList)
    {
        userByIdMap = ECICCaseTriggerUserCache.getUserByIdMap();

        if (! userByIdMap.isEmpty())
        {
            for (Case currentCase : casesList)
            {
                if (! ECICCaseHelper.isGroupId(currentCase.ownerId) ) 
                {
                    if (userByIdMap.containsKey(currentCase.ownerId))
                    {
                        setInfolineStatus(currentCase);
                    }
                    else // if Owner is User, but not in Cache: This should never happen.
                    {
                        System.debug(LoggingLevel.WARN, 'Case.infoline_status__c can not be set because owner with UserId ' + currentCase.ownerId + ' is missing from ECICCaseTriggerUserCache.');
                    }
                }
                
            }
        }
    }
    
    @testVisible private void setInfolineStatus(Case currentCase)
    {
        if ( 
               (currentCase.Origin == 'Commercial Dept.') 
            && (
                    //#Profile
                        (userByIdMap.get(currentCase.OwnerId).profile.name == ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY)
                    ||  (Test.isRunningTest() && SEPProfileCache.get(userByIdMap.get(currentCase.OwnerId).profileId).name == ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY) // Needed to minimize SOQL in test.
                ) 
           )
        {
                        currentCase.Infoline_Status__c = null;
                    } 
        else if ( currentCase.Infoline_Status__c == null )
        {
            currentCase.Infoline_Status__c = ECICCommonConstants.STATUS_OPEN;
                }
            }
    
    }