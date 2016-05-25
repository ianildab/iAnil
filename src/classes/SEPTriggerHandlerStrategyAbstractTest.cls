@isTest
private class SEPTriggerHandlerStrategyAbstractTest 
{
    class DummyTriggerHandlerStrategy extends SEPTriggerHandlerStrategyAbstract {}

    private static DummyTriggerHandlerStrategy dummyTriggerHandlerStrategy = new DummyTriggerHandlerStrategy();
    
    static testMethod void onBeforeInsertTest()   { system.assert (dummyTriggerHandlerStrategy.onBeforeInsert  (new List<sObject>{}));                             }
    static testMethod void onAfterInsertTest()  { system.assert (dummyTriggerHandlerStrategy.onAfterInsert (new Map<Id, sObject>{}));  }
    static testMethod void onBeforeUpdateTest()   { system.assert (dummyTriggerHandlerStrategy.onBeforeUpdate  (new Map<Id, sObject>{}, new Map<Id, sObject>{}));  }
    static testMethod void onAfterUpdateTest()  { system.assert (dummyTriggerHandlerStrategy.onAfterUpdate (new Map<Id, sObject>{}, new Map<Id, sObject>{}));  }
    static testMethod void onBeforeDeleteTest()   { system.assert (dummyTriggerHandlerStrategy.onBeforeDelete  (new Map<Id, sObject>{}));                          }
    static testMethod void onAfterDeleteTest()    { system.assert (dummyTriggerHandlerStrategy.onAfterDelete   (new Map<Id, sObject>{}));                          }
    static testMethod void onAfterUndeleteTest()  { system.assert (dummyTriggerHandlerStrategy.onAfterUndelete (new Map<Id, sObject>{}));                          }
}