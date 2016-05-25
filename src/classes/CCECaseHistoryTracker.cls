public with sharing class CCECaseHistoryTracker{
 
public static void updateCaseHistoryTracker(List<Case> newValues,List<Case> oldValues){
 List<Schema.FieldSetMember> trackedFields =     SObjectType.Case.FieldSets.HistoryTracking.getFields();
if (trackedFields.isEmpty()) return;

List<Case_History_Tracking__c> fieldChanges = new List<Case_History_Tracking__c>();
Map<Id,Case> OldMapCase = new Map<Id,Case>();
for (Case caseold : oldValues) {
OldMapCase.put(caseold.Id,caseold);
}

List<string> apiNameList = new List<string>();
       
for (Case aNew : newValues) {

Case aOld = OldMapCase.get(aNew.Id);

for (Schema.FieldSetMember fsm : trackedFields) {

 String fieldName  = fsm.getFieldPath();
String fieldLabel = fsm.getLabel();

if (aNew.get(fieldName) != aOld.get(fieldName)) {

String oldValue = String.valueOf(aOld.get(fieldName));
String newValue = String.valueOf(aNew.get(fieldName));
if (oldValue != null && oldValue.length()>32768) oldValue = oldValue.substring(0,32768);
if (newValue != null && newValue.length()>32768) newValue = newValue.substring(0,32768); 

 Case_History_Tracking__c aht = new Case_History_Tracking__c();
aht.name         = fieldLabel;
aht.apiName__c   = fieldName;
//aht.User__c      = aNew.CaseNumber;
aht.ChangedBy__c = UserInfo.getName();
aht.OldValue__c  = oldValue;
aht.NewValue__c  = newValue;
aht.Action__c = Label.Changed + ' ' + fieldLabel + ' ' + Label.from + ' \'' + oldValue + '\' ' + Label.to1 + ' \'' + newValue + '\'';
aht.CaseNumber__c      = aNew.Id;  

 apiNameList.add(aht.apiName__c);
 fieldChanges.add(aht);
}        
}
}

if (!fieldChanges.isEmpty()) {
 insert fieldChanges;
 }
 }

}