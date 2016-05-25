public class ECICOpenAlertCaseListHeaderController 
{
    public String   controllerCountryCode {get;set;}
    public Datetime controllerStartDate   {get;set;}
    public Datetime controllerEndDate     {get;set;}
    
    public ECICOpenAlertCaseListHeaderController()
    {
    	
    }
   
    public String getListHeader()
    {
    	return (controllerCountryCode == 'FR')
    	           ? (Label.Analyzed_period +': ' + controllerStartDate + '-' + controllerEndDate)
    	           : (Label.Cases_met_defined_criteria);
    }    

}