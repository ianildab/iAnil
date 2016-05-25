/**
 * @description Class to help create unique dummy data (in a consistent way [sic]).
 * @author      Brian Kessler <Brian_Kessler@epam.com>
 * @date        2013 July 18
 **/
@isTest
public class TEST_UniqueHelper 
{
    public Integer uniqueInt      	{get; private set;}
    public String  uniqueString   	{get; private set;}
    public String  uniqueSpaceless  {get; private set;}
    
    /** 
    * @description  Constructor, which selects and sets an Integer and a corresponding String.
    * @param        String what : A value which can be included in the unique String to help identify it.
    **/
    public TEST_UniqueHelper (String what)
    {
        this.uniqueInt       = random();
        this.uniqueString    = what + ' ' + this.uniqueInt;
        this.uniqueSpaceless = this.uniqueString.deleteWhitespace(); 
    }
    
    /** 
    * @description  Default Constructor, which selects and sets an Integer and a corresponding String.
    **/
    public TEST_UniqueHelper () { this('Unique'); }
    
    public static Integer random() { return ((Integer) (ECICTestHelperAddon.getUniqueRandom() * 2147483647)); }
}