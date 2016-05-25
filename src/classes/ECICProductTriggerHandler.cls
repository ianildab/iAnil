public class ECICProductTriggerHandler extends SEPTriggerHandlerAbstract{
    
    private static Map<String, String> packageMapping = new Map<String, String>();
    
    {
        packageMapping.put('Alum Btl Nr Cntr', 'Alum Btl');
        packageMapping.put('Alum Can Nr', 'Can');
        packageMapping.put('Alum Can Nr Cntr', 'Can');
        packageMapping.put('Crbd BIB Nr', 'BIB');
        packageMapping.put('Flx Bag Nr', 'Pouch');
        packageMapping.put('Flx Bpk Nr', 'Tetra');
        packageMapping.put('Glass Btl Nr', 'Glass Not Ref');
        packageMapping.put('Glass Btl Nr Cntr', 'Glass Not Ref');
        packageMapping.put('Glass Btl Nr Dmpl', 'Glass Not Ref');
        packageMapping.put('Glass Btl Nr Prop', 'Glass Not Ref');
        packageMapping.put('Glass Btl Ref', 'Glass Ref');
        packageMapping.put('Glass Btl Ref Cntr', 'Glass Ref');
        packageMapping.put('Glass Btl Ref Dmpl', 'Glass Ref');
        packageMapping.put('Plas Btl Nr', 'Pet');
        packageMapping.put('Plas Btl Nr Cntr', 'Pet');
        packageMapping.put('Plas Btl Nr Dmpl', 'Pet');
        packageMapping.put('Plas Btl Nr Prop', 'Pet');
        packageMapping.put('Plas Btl Nr Spls', 'Pet');
        packageMapping.put('Plas Btl Ref', 'PET Ref');
        packageMapping.put('Plas Btl Ref Cntr', 'PET Ref');
        packageMapping.put('Plas Can Nr', 'Pet');
        packageMapping.put('Plas Drm Nr', 'PET Box');
        packageMapping.put('Sstl Tnk Ref', 'Premix');
        packageMapping.put('Stl Can Nr', 'Can');
        packageMapping.put('Stl Can Nr Prop', 'Can');
    }
    
    public ECICProductTriggerHandler(boolean isTriggerExecuting) {
       super(isTriggerExecuting);
    }
    
    public override void OnBeforeInsert(List<sObject> newValues) {
        onBefore((List<Product__c>)newValues, null, true);
    }
    
    public override void OnBeforeUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        onBefore((List<Product__c>)newValues, (Map<Id, Product__c>)oldValuesMap, false);
    }
    
    
    
    /*
    *   https://tcccdiam.atlassian.net/browse/CIC-302
    */
    private void onBefore(List<Product__c> newObjs, Map<ID, Product__c> oldMap, boolean isInsert) {
        for(Product__c product : newObjs) {
            if (isInsert) {
                product.Name = product.International_Name__c != null ? product.International_Name__c : product.Name;
            } else {
                Product__c old = oldMap.get(product.id);
              /*if (product.International_Name__c != old.International_Name__c) {
                    product.Name = product.International_Name__c;
              }*/
                
                if (!product.Currently_Sold__c && old.Currently_Sold__c && old.Active__c) {
                    product.Active__c = false;
                }
                
                if ( product.Currently_Sold__c && !old.Currently_Sold__c && !old.Active__c && product.Shelf_Life__c != null && product.Unit__c != null) {
                    product.Active__c = true;
                }
            } 
            
            setPackageType(product, Trigger.isInsert ? null : oldMap.get(product.id));  
        }
    }
    
    private void setPackageType(Product__c p, Product__c old) {
        if (Trigger.isInsert || (Trigger.isUpdate && p.Packaging__c != old.Packaging__c)) {            
            p.Package_Type__c = String.isEmpty(p.Packaging__c) ? '' :
                                packageMapping.containsKey(p.Packaging__c) ? packageMapping.get(p.Packaging__c) : 'Unknown';
        }  
    }    
    //TODO: populate ownerLookup ref

}