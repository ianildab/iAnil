/**
 * @description Class to help dummy factories choose between config values and default values.
 * @author      Brian Kessler <Brian_Kessler@epam.com>
 * @date        2013 July 18
 **/
 @isTest
public class TEST_ConfigHelper 
{
    public static final String     INTENTIONAL_NULL               = '01p110000000IYq';
    public static final Integer    INTENTIONAL_NULL_FOR_NUMBER    = -909090909;
   // public static final Date       INTENTIONAL_NULL_FOR_DATE      = Date.newInstance(1900, 01, 01);
    public static final Date       INTENTIONAL_NULL_FOR_DATE      = System.today() - 7;
    
    /** 
    * @description  Method to choose between Strings.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 July 18
    * @param        String configValue  : Value from Config (Inner Class) 
    * @param        String defaultValue : Value to use as default (if Config value is null);
    * @return       String
    **/
    public static String chooseValue(String configValue, String defaultValue)
    {
        if (configValue == INTENTIONAL_NULL) 
        { 
            return null; 
        }
        return (configValue != null)
                ? configValue
                : defaultValue;
    }

    public static Id chooseValue(Id configValue, Id defaultValue)
    {
        if (configValue == INTENTIONAL_NULL) 
        { 
            return null; 
        }
        return (configValue != null)
                ? configValue
                : defaultValue;
    }

    public static String chooseValue(String configValue, SObject defaultObject, String fieldName)
    {
        if (configValue != null)
        {
            return (configValue != INTENTIONAL_NULL)
                    ? configValue
                    : null;
        }
        else
        {
            return (defaultObject != null) 
                ? (String) defaultObject.get(fieldName)
                : null;
        }
        return null; 
    }


    
    public static Id chooseValue(Id configValue, SObject defaultObject)
    {
        if (configValue != null)
        {
            return (configValue != INTENTIONAL_NULL)
                    ? configValue
                    : null;
        }
        else
        {
            return (defaultObject != null) 
                ? (Id) defaultObject.get('id')
                : null;
        }
        return null; 
    }


    /** 
    * @description  Method to choose between Integer.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 July 18
    * @param        Integer configValue  : Value from Config (Inner Class) 
    * @param        Integer defaultValue : Value to use as default (if Config value is null);
    * @return       Integer
    **/
    public static Integer chooseValue(Integer configValue, Integer defaultValue)
    {
        if (configValue == INTENTIONAL_NULL_FOR_NUMBER) 
        { 
            return null; 
        }
        
        return (configValue != null)
                ? configValue
                : defaultValue;
    }

    /** 
    * @description  Method to choose between Double.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 July 18
    * @param        Double configValue  : Value from Config (Inner Class) 
    * @param        Double defaultValue : Value to use as default (if Config value is null);
    * @return       Double
    **/
    public static Double chooseValue(Double configValue, Double defaultValue)
    {
        if (configValue == INTENTIONAL_NULL_FOR_NUMBER) 
        { 
            return null; 
        }

        return (configValue != null)
                ? configValue
                : defaultValue;
    }

    /** 
    * @description  Method to choose between Decimal.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 July 18
    * @param        Decimal configValue  : Value from Config (Inner Class) 
    * @param        Decimal defaultValue : Value to use as default (if Config value is null);
    * @return       Decimal
    **/
    public static Decimal chooseValue(Decimal configValue, Decimal defaultValue)
    {
        if (configValue == INTENTIONAL_NULL_FOR_NUMBER) 
        { 
            return null; 
        }

        return (configValue != null)
                ? configValue
                : defaultValue;
    }

    /** 
    * @description  Method to choose between Date.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 August 13
    * @param        Date configValue  : Value from Config (Inner Class) 
    * @param        Date defaultValue : Value to use as default (if Config value is null);
    * @return       Date
    **/
    public static Date chooseValue(Date configValue, Date defaultValue)
    {
        if (configValue == INTENTIONAL_NULL_FOR_DATE) 
        { 
            return null; 
        }
        return (configValue != null)
                ? configValue
                : defaultValue;
    }

    /** 
    * @description  Method to choose between Date.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 October 29
    * @param        DateTime configValue  : Value from Config (Inner Class) 
    * @param        DateTime defaultValue : Value to use as default (if Config value is null);
    * @return       DateTime
    **/
    public static DateTime chooseValue(DateTime configValue, DateTime defaultValue)
    {
        return (configValue != null)
                ? configValue
                : defaultValue;
    }

    /** 
    * @description  Method to choose between Boolean.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 September 24
    * @param        Boolean configValue  : Value from Config (Inner Class) 
    * @param        Boolean defaultValue : Value to use as default (if Config value is null);
    * @return       Boolean
    **/
    public static Boolean chooseValue(Boolean configValue, Boolean defaultValue)
    {
        return (configValue != null)
                ? configValue
                : defaultValue;
    }

    /** 
    * @description  Method to choose between sObject.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 July 18
    * @param        sObject configValue  : Value from Config (Inner Class) 
    * @param        sObject defaultValue : Value to use as default (if Config value is null);
    * @return       sObject
    **/
    public static sObject chooseValue(sObject configValue, sObject defaultValue)
    {
        return (configValue != null)
                ? configValue
                : defaultValue;
    }

}