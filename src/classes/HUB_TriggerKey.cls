/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : May 28, 2013
* Description : This class is used to prevent trigger from running more than once within one event 
*
* REVISION HISTORY
*
* Author,email :
* Date Revised :
* Description :
*
*
* FOR HUB 1.2
*/
public class HUB_TriggerKey {
    private Static Map<String,Boolean> stateMap = new Map<String,Boolean>();
    
    public static Boolean getFired(String id) {
        if (!stateMap.containsKey(id)) {
            stateMap.put(id,false);
        }
        
        return stateMap.get(id);        
    }
    
    public static void setFired(String id) {
        if (Test.isRunningTest()) return;
        stateMap.put(id,true);
    }
    
}