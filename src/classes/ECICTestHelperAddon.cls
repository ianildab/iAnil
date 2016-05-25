public with sharing class ECICTestHelperAddon{
    private static Set<Integer> existRandomKeys = New Set<Integer>{};   

/* 
 *  return unique (from parent class) a positive 0 < Double < 1 
 */
    public static double getUniqueRandom(){
        Double uniqKey = 0;
        do{
            uniqKey = Math.Random();
        }while(existRandomKeys.contains((Integer)(uniqKey * 2147483647)));             
        existRandomKeys.add((Integer)(uniqKey * 2147483647));
        return uniqKey;
    }
}