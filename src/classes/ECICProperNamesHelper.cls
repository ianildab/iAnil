public class ECICProperNamesHelper {
    public static final String FIRSTNAME = 'firstName';
    public static final String LASTNAME = 'lastName';
    
    public static void updateNames(sObject contact) {  
        String countryCode = (String) contact.get('Country_code__c') ; 
        
        if (String.isEmpty(countryCode)) {
            return;
        }
        else {
            countryCode = countryCode.toUppercase();
        }
        
        Country_Specific_Settings__c cs = Country_Specific_Settings__c.getValues(countryCode);
        Set<String> exceptions = (cs != null && !String.isEmpty(cs.Exception_list__c)) ? new Set<String>(cs.Exception_list__c.split(';', 0)) : null;        
        String fn = (String) contact.get(FIRSTNAME);
        String ln = (String) contact.get(LASTNAME);
        
        if ('ES'.equals(countryCode)) {
            contact.put(FIRSTNAME, capitalizeES(fn, exceptions, true));
            contact.put(LASTNAME, capitalizeES(ln, exceptions, String.isEmpty(fn)));
        }
        else {
            contact.put(FIRSTNAME, capitalize(fn, exceptions, true));
            contact.put(LASTNAME, capitalize(ln, exceptions, String.isEmpty(fn)));
        }
    } 
    
    /**
    *    Capitalize ES proper nouns
    */
    public static String capitalizeES(String name, Set<String> exceptions, boolean capFirst) {
        if (String.isEmpty(name)) {
            return name;
        }
        
        String result = '';
        if (exceptions != null && !exceptions.isEmpty()) {
            for (String word : exceptions) {
                if (word.containsWhitespace() && name.containsIgnoreCase(word)) {
                    String before = capitalize(name.substringBefore(word), exceptions, true);
                    String after = capitalize(name.substringAfter(word), exceptions, true);
                    word = (String.isEmpty(before) && capFirst) ? word.capitalize() : word.uncapitalize();
                    
                    return String.join(new String[]{before, word, after}, ' '); 
                }
            }  
        }    
              
        return capitalize(name, exceptions, capFirst);
    }
    
    public static String capitalize(String name, Set<String> exceptions, boolean capFirst) {
        if (String.isEmpty(name)) {
            return name;
        }
        
        String[] words = name.trim().splitByCharacterTypeCamelCase();        
        String result = '';
        Iterator<String> it = words.iterator();
            
        if (capFirst) {
            result += it.next().capitalize();
        }
        
        while(it.hasNext()){
            String word = it.next();
            if (String.isNotEmpty(word)) {
                result += (exceptions != null && exceptions.contains(word)) ? word.uncapitalize() : word.capitalize();
            }
        }
        
        return result;
    }
    
    public static boolean isNameChanged (sObject old, sObject o) {
        String oldFn = (String) old.get(FIRSTNAME);
        String fn = (String) o.get(FIRSTNAME);
        String oldLn = (String) old.get(LASTNAME);
        String ln = (String) o.get(LASTNAME);
        return (oldFn != null && !oldFn.equals(fn)) ||  (oldLn != null && !oldLn.equals(ln)) ;
    }
}