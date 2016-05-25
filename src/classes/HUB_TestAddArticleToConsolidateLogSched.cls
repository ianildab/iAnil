@isTest
public with sharing class HUB_TestAddArticleToConsolidateLogSched {
	@isTest static void testSchedular(){
		SchedulableContext sc =  null;
		HUB_AddArticleToConsolidateLogSchedular objClass = new HUB_AddArticleToConsolidateLogSchedular();
		objClass.execute(sc);
		HUB_AddArticleToConsolidateLogSchedular.Start();
	}
	
}