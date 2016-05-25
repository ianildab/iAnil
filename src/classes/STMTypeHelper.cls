/**
*   This class is contains the methods which is uses by STMTypeTriggerHandler. 
*
*/
public class STMTypeHelper {
  private final static Integer KEY_PART_SIZE = 4;
  private final static String KEY_ACCOUNTS = 'Accounts';
  private final static String KEY_CONTACTS = 'Contacts';
  private final static String F_STMTYPES_LIST = 'STMTypes_list__c';
  
  /**
  * @author      Pavel Slepenkov (Pavel_Slepenkov@epam.com)
  * @date        25 Mar 2013
  * @param       List<STMG_Type__c> inserted objects which should be validated before insert or update
  * @param       List<STMG_Type__c> old records of inserted objects
  */
    public static void checkTypeDuplication(List<STMG_Type__c> toValidate, Map<Id,STMG_Type__c> oldMap) {
        Set<Id> stakeholderIds = collectStakeholdersId(toValidate);
        //select STMG_Type__c which is contains the same account or contacts as the inserted records
        List<STMG_Type__c> existTypes = [SELECT Id,
                                                STMStakeholderAccount__c,
                                                STMStakeholder_Contact__c,
                                                Stakeholder_type__c,
                                                Stakeholder_subspecialization__c,
                                                Stakeholder_specialization__c
                                            FROM STMG_Type__c 
                                            WHERE STMStakeholderAccount__c IN: stakeholderIds
                                                  OR STMStakeholder_Contact__c IN: stakeholderIds];
        // Arrange STMG_Type__c by Accounts or Contacts
        Set<String> tmp;
        Map<Id, Set<String>> existingTypesByStakeholders = new Map<Id, Set<String>>();
        for (STMG_Type__c type: existTypes) {
            tmp = new Set<String>();
            // STMStakeholderAccount__c && STMStakeholder_Contact__c couldn't be filled in the same time
            if (type.STMStakeholderAccount__c != null) {
                if (existingTypesByStakeholders.containsKey((Id)type.STMStakeholderAccount__c)) {
                    tmp = existingTypesByStakeholders.get((Id)type.STMStakeholderAccount__c);
                    tmp.add(generateSTMTypeKey(type));
                    existingTypesByStakeholders.put((Id)type.STMStakeholderAccount__c, tmp);
                } else {
                    tmp.add(generateSTMTypeKey(type));
                    existingTypesByStakeholders.put((Id)type.STMStakeholderAccount__c, tmp);
                }
            } else if (type.STMStakeholder_Contact__c != null) {
                if (existingTypesByStakeholders.containsKey((Id)type.STMStakeholder_Contact__c)) {
                    tmp = existingTypesByStakeholders.get((Id)type.STMStakeholder_Contact__c);
                    tmp.add(generateSTMTypeKey(type));
                    existingTypesByStakeholders.put((Id)type.STMStakeholder_Contact__c, tmp);
                } else {
                    tmp.add(generateSTMTypeKey(type));
                    existingTypesByStakeholders.put((Id)type.STMStakeholder_Contact__c, tmp);
                }
            }
        }
        // validate incomming STMG_Type__c
        String key = '';
        for (STMG_Type__c type: toValidate) {
          if (oldMap != null) {
             STMG_Type__c old = oldMap.get(type.Id);
             if (old.Stakeholder_type__c == type.Stakeholder_type__c &&
                 old.Stakeholder_specialization__c == type.Stakeholder_specialization__c &&
                 old.Stakeholder_subspecialization__c == type.Stakeholder_subspecialization__c) {
                 continue;
             }
          }
            tmp = new Set<String>();
            key = generateSTMTypeKey(type);
            // STMStakeholderAccount__c && STMStakeholder_Contact__c couldn't be filled in the same time
            // Validation checks that no other Type is exist with the same key as the key of current Type  
            if (type.STMStakeholderAccount__c != null) {
                tmp = existingTypesByStakeholders.get((Id)type.STMStakeholderAccount__c);
                if (tmp != null && tmp.contains(key)) {
                   type.addError(System.Label.typeDuplication);
                }
            } else if (type.STMStakeholder_Contact__c != null) {
                tmp = existingTypesByStakeholders.get((Id)type.STMStakeholder_Contact__c);
                if (tmp != null && tmp.contains(key)) {
                    type.addError(System.Label.typeDuplication);
                }
            }
        }
        
    }
    
    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         28 Mar 2013
    */
    public static void updateTypeListOnStakeholder(List<STMG_Type__c> newTypes, Map<Id,STMG_Type__c> oldMap, Boolean isDelete) {
        Map<String, Map<Id,sObject>> stakeholderIds = separateStakeholders(newTypes);
        updateTypeList(stakeholderIds.get(KEY_CONTACTS), newTypes, oldMap, isDelete);
        updateTypeList(stakeholderIds.get(KEY_ACCOUNTS), newTypes, oldMap, isDelete);
    }
    
    // find out a stakeholders by their type: contact or account and separate it:
    // account is pushed to the one map and contacts to another one.
    private static Map<String, Map<Id,sObject>> separateStakeholders(List<STMG_Type__c> types) {
        Map<String, Map<Id,sObject>> result = new Map<String, Map<Id,sObject>>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (STMG_Type__c type: types) {
            if (type.STMStakeholderAccount__c != null) {
                accountIds.add((Id)type.STMStakeholderAccount__c);
            } else if (type.STMStakeholder_Contact__c != null) {
                contactIds.add((Id)type.STMStakeholder_Contact__c);
            }
        }
        Map<Id,sObject> contactByIds = new Map<Id,sObject>(database.query('SELECT Id, STMTypes_list__c FROM Contact WHERE Id IN: contactIds'));
        Map<Id,sObject> accountByIds = new Map<Id,sObject>(database.query('SELECT Id, STMTypes_list__c FROM Account WHERE Id IN: accountIds'));
        result.put(KEY_CONTACTS, contactByIds);
        result.put(KEY_ACCOUNTS, accountByIds);
        return result;
    }
    
    private static Map<String, Set<Id>> findExistingSTMTypesWithSameTypeField(Map<Id,sObject> stakeholdeByIds, List<STMG_Type__c> newTypes) {
        Set<String> typeFieldValues = new Set<String>();
        Set<Id> stakeholderIds = new Set<Id>();
        for (sObject obj: stakeholdeByIds.values()) {
            if (!stakeholderIds.contains((Id)obj.get('Id'))) {
                stakeholderIds.add((Id)obj.get('Id'));
            }
        }
        for(STMG_Type__c type: newTypes) {
            if (!typeFieldValues.contains(type.Stakeholder_type__c)) {
                typeFieldValues.add(type.Stakeholder_type__c);
            }
        }
      
        Map<String, Set<Id>> result = new Map<String, Set<Id>>();
        List<STMG_Type__c> existingTypes = [SELECT Id,
                                                   STMStakeholderAccount__c,
                                                   STMStakeholder_Contact__c,
                                                   Stakeholder_type__c 
                                            FROM STMG_Type__c
                                                  WHERE (STMStakeholderAccount__c IN:stakeholderIds
                                                      OR STMStakeholder_Contact__c IN: stakeholderIds) 
                                                  AND Stakeholder_type__c IN:typeFieldValues];
        Set<Id> tmp;
        String key;
        for (STMG_Type__c type: existingTypes) {
            key = generateStakeholderTypeKey(type);
            tmp = new Set<Id>();
            if (result.containsKey(key)) {
                tmp = result.get(key);
                tmp.add(type.Id);
                result.put(key, tmp);
            } else {
                tmp.add(type.Id);
                result.put(key, tmp);
            }
        }
        
        for (STMG_Type__c type: newTypes) {
            key = generateStakeholderTypeKey(type);
            tmp = new Set<Id>();
            if (result.containsKey(key)) {
                tmp = result.get(key);
                tmp.add(type.Id);
                result.put(key, tmp);
            } else {
                tmp.add(type.Id);
                result.put(key, tmp);
            }
        }
        return result;
    }
    
    // generate key for searching in existing STMTypes with same type field map
    // (Account/Contact).Id + Stakeholder_type__c
    private static String generateStakeholderTypeKey(STMG_Type__c type) {
        Id tmpStakeholderId = type.STMStakeholder_Contact__c == null ? (Id)type.STMStakeholderAccount__c :
                                                                        (Id)type.STMStakeholder_Contact__c;
        return tmpStakeholderId + type.Stakeholder_type__c;
    }
    
    private static void updateTypeList(Map<Id,sObject> stakeholdeByIds, List<STMG_Type__c> newTypes, Map<Id,STMG_Type__c> oldMap, Boolean isDelete) {
        if (stakeholdeByIds.isEmpty()) {
            return;
        }
        Map<String, Set<Id>> existSTMTypesWithSameTypeByTypeField = findExistingSTMTypesWithSameTypeField(stakeholdeByIds,newTypes);
        String oldTypeListValue;
        String newTypeListValue;
        Id currentStakeholderId;
        Set<sObject> toUpdate = new Set<sObject>();
        List<sObject> listToUpdate = new List<sObject>();
        sObject tmp;
        Set<Id> sameTypeIds;
        String oldTypeValue;
        for (STMG_Type__c type: newTypes) {
            currentStakeholderId = (type.STMStakeholder_Contact__c != null) ? (Id)type.STMStakeholder_Contact__c:
                                   (Id)type.STMStakeholderAccount__c;
            tmp = stakeholdeByIds.get(currentStakeholderId); // get account/contact for current STM_Type__c 
            // get old value from STMTypes_list__c field from Account/Contact
            oldTypeListValue = (String)tmp.get(F_STMTYPES_LIST) == null ? '': (String)tmp.get(F_STMTYPES_LIST); 
            
            if (oldMap == null) { // INSERT
                newTypeListValue = oldTypeListValue;
                if (!oldTypeListValue.contains(type.Stakeholder_type__c)) {
                    newTypeListValue += (type.Stakeholder_type__c + ';');
                }
                tmp.put(F_STMTYPES_LIST, newTypeListValue);
                toUpdate.add(tmp);
            } else if(isDelete) { // DELETE
                if (newTypes.size() == 1) {
                    // this case valid for single dml operation and shouldn't be applyed for bulk dml
                    // on case with bulk dml the error msg is in the exception format and it should be ok for admin user
                    // therefore SOQLs in for loop is OK
                    // all these code were written in the deadline's period, and if you have a time to write awesome code please do 
                    // this code is the result of changing requirements on the final distance before release
                    Integer stkhlldAmount = 0;
                    Boolean isActiveStakeholder = true;
                    String countSoql = 'SELECT count() FROM STMG_Type__c WHERE ';
                    if (String.valueOf(tmp.getSObjectType()) == 'Account') {
                        countSoql += 'STMStakeholderAccount__c = \'' + currentStakeholderId + '\'';
                        Account acc = [SELECT STMActive__pc FROM Account WHERE id =:currentStakeholderId];
                        isActiveStakeholder = acc.STMActive__pc;
                    } else {
                        countSoql += 'STMStakeholder_Contact__c = \'' + currentStakeholderId + '\'';
                        Contact cont = [SELECT STMActive__c FROM Contact WHERE id =:currentStakeholderId];
                        isActiveStakeholder = cont.STMActive__c;
                    }
                    stkhlldAmount = Database.countQuery(countSoql);
                    
                    if (stkhlldAmount <= 1 && isActiveStakeholder) {
                        newTypes[0].addError('This Type cannot be deleted from this Active Stakeholder, because a Stakeholder should have at least one Type defined.');
                        return;
                    }
                }
                
                sameTypeIds = existSTMTypesWithSameTypeByTypeField.get(generateStakeholderTypeKey(type));
                if (!sameTypeIds.isEmpty() && sameTypeIds.size() > 1) { // STMG_Type__c objects with same type field value linked to this stakeholder
                    continue;
                }
                STMG_Type__c old = oldMap.get(type.Id);
                newTypeListValue = oldTypeListValue.remove(old.Stakeholder_type__c + ';');
                tmp.put(F_STMTYPES_LIST, newTypeListValue);
                if (!toUpdate.contains(tmp)) {
                    toUpdate.add(tmp);
                }
            } else {// UPDATE
                STMG_Type__c old = oldMap.get(type.Id);
                if (old.Stakeholder_type__c != type.Stakeholder_type__c) {
                    newTypeListValue = oldTypeListValue;
                    //if (oldTypeListValue != (old.Stakeholder_type__c + ';')) { // remove old value from STMTypes_list__c
                    sameTypeIds = existSTMTypesWithSameTypeByTypeField.get(generateStakeholderTypeKey(old));
                    if (sameTypeIds != null && !sameTypeIds.isEmpty() && sameTypeIds.size() <= 1) { // STMG_Type__c objects with same type field value linked to this stakeholder
                        oldTypeValue = old.Stakeholder_type__c + ';';
                        newTypeListValue = oldTypeListValue.remove(oldTypeValue);
                    }
                    if (!oldTypeListValue.contains(type.Stakeholder_type__c)) { //add new value
                        newTypeListValue += (type.Stakeholder_type__c + ';');
                    }
                    tmp.put(F_STMTYPES_LIST, newTypeListValue);
                    toUpdate.add(tmp);
                }
            }
        }
        listToUpdate.addAll(toUpdate);
        update listToUpdate;
    }
    
//----------------------------------------------------------------------------------------------------------------------
    // key generates by 3 fields, by the following way:
    // first <KEY_PART_SIZE> chars from every field will be supplemented by '0' and will be concatenated 
    // e.g. Thi0Exp0Env0Ins0Ind0Con0Dis0Ene0Eng0Foo0Inf0Law0Mar0Mot0Rea0Ser0Tec0Tel0Tex0Tra0Tou0Wel0
    // key generated by 20 subTypes
    private static String generateSTMTypeKey(STMG_Type__c type) {
        String key = '';
        key = generateKeyPart(type.Stakeholder_type__c) + generateKeyPart(type.Stakeholder_specialization__c) + 
        processSubSpec(type.Stakeholder_subspecialization__c);
        return key;
    }
    
    private static String generateKeyPart(String toGenerate) {
        String result = '';
        toGenerate = normalizeString(toGenerate);
      if (toGenerate != null && toGenerate != '') {
        if (toGenerate.length() >= KEY_PART_SIZE) {
             result =  toGenerate.subString(0, KEY_PART_SIZE) + '0';
        } else {
               result += toGenerate + '0';
            }
      } 
      return result;
    }
    
    //STMType subspec field is multipicklist
    private static String processSubSpec(String subSpec) {
        subSpec = normalizeString(subSpec);
        String result = '';
        if (subSpec != null) {
           String[] subSpecs = subSpec.split(';');
           for (String s: subSpecs) {
                if (s != null && s != '') {
                    if (s.length() >= KEY_PART_SIZE) {
                        result += (s.substring(0, KEY_PART_SIZE) + '0');
                    } else {
                        result += s + '0';
                    }
                }
           }
        }
        return result;
    }
    
    private static String normalizeString(String toNormalize) {
        String result = toNormalize;
        if (KEY_PART_SIZE > 3) { 
            result = '';
            if (toNormalize != null) {
                result = toNormalize.normalizeSpace();
                result = result.replace(' ','');
            }
        }
        return result;
    }
    
    private static Set<id> collectStakeholdersId(List<STMG_Type__c> types) {
        Set<Id> stakeholderIds = new Set<Id>();
        for (STMG_Type__c type: types) {
            if (type.STMStakeholderAccount__c != null) {
                stakeholderIds.add((Id)type.STMStakeholderAccount__c);
            } else if (type.STMStakeholder_Contact__c != null) {
                stakeholderIds.add((Id)type.STMStakeholder_Contact__c);
            }
        }
        return stakeholderIds;
    }
    


}