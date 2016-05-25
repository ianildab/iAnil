/*
 *This class is used for recursive call of trigger
 */

public class TriggerContextUtility {

    private static boolean firstRun = true;
     public static String log = 'Log Started';
    
    private static boolean isInserted = true; 
    private static boolean isUpdated = true; 

    public static boolean isFirstRun() {
        return firstRun;
    }
    public static void setFirstRunFalse(){
        firstRun = false;
    }
    
     public static boolean isInserted() {
        return isInserted;
    }
    public static void setIsInserted(){
        isInserted = false;
    }
    
    public static boolean isUpdated() {
        return isUpdated;
    }
    public static void setIsUpdated(){
        isUpdated = false;
    }
}