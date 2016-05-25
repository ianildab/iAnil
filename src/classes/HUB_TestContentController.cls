@isTest
public with sharing class HUB_TestContentController {
	static testMethod void myUnitTest() {
        HUB_Contents__c  c = new HUB_Contents__c ();
        c.Title__c = 'sample content';
        c.Description__c = 'test description';
        c.contentType__c = 'Campaign';
        c.URL__c='www.google.com';
        c.Source__c='DMX';
        c.Date__c=Date.today();
        c.End_Date__c=Date.today().addDays(10);
        insert c;
		
		PageReference pageRef = Page.hub_Content;
		Test.setCurrentPage(pageRef);
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(c);
		ApexPages.currentPage().getParameters().put('id',c.id);
	    HUB_ContentController obj = new HUB_ContentController(sc);
		obj.getFrequency();
        system.assert(obj.frequencyVisibility==null);
		obj.getDailyOptions();
		obj.getMonthlyDays();
		obj.getMonthlyOptions();
        obj.getMonthlyWeeks();
        obj.getYearlyOptions();
        obj.getMonthlyNthDay();
        obj.getYearlyMonth();
        obj.getYearlyDay();
        obj.getYearlyNthDay();
        obj.getYearlyNthDay2();
        obj.getYearlyMonth2();
        obj.getRepeatonweeks();
        obj.SaveMethod();
        

    }
    
    static testMethod void myUnitTestDailyEveryWeekday() {
        HUB_Contents__c  c = new HUB_Contents__c ();
        c.Title__c = 'sample content';
        c.Description__c = 'test description';
        c.contentType__c = 'Campaign';
        c.URL__c='www.google.com';
        c.Source__c='DMX';
        c.Date__c=Date.today();
        c.End_Date__c=Date.today().addDays(10);
        c.Repeat__c=true;
        c.Frequency__c='Daily';
        c.Daily_Options__c='Every Weekday';
        c.repeatStartDate__c=Date.today();
        c.repeatEndDate__c=Date.today().addDays(10);
        insert c;
		
		PageReference pageRef = Page.hub_Content;
		Test.setCurrentPage(pageRef);
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(c);
		ApexPages.currentPage().getParameters().put('id',c.id);
	    HUB_ContentController obj = new HUB_ContentController(sc);
		obj.getFrequency();
        system.assert(obj.frequencyVisibility=='Daily');
		obj.getDailyOptions();
		obj.SaveMethod();
		obj.getWeeks();

    }
    static testMethod void myUnitTestDailyEvery() {
        HUB_Contents__c  c = new HUB_Contents__c ();
        c.Title__c = 'sample content';
        c.Description__c = 'test description';
        c.contentType__c = 'Campaign';
        c.URL__c='www.google.com';
        c.Source__c='DMX';
        c.Date__c=Date.today();
        c.End_Date__c=Date.today().addDays(10);
        c.Repeat__c=true;
        c.Frequency__c='Daily';
        c.Daily_Options__c='Every';
        c.dailyEveryNDays__c=2;
        c.repeatStartDate__c=Date.today();
        c.repeatEndDate__c=Date.today().addDays(10);
        insert c;
		
		PageReference pageRef = Page.hub_Content;
		Test.setCurrentPage(pageRef);
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(c);
		ApexPages.currentPage().getParameters().put('id',c.id);
	    HUB_ContentController obj = new HUB_ContentController(sc);
		obj.getFrequency();
        system.assert(obj.frequencyVisibility=='Daily');
		obj.getDailyOptions();
		obj.SaveMethod();
		

    }
    static testMethod void myUnitTestWeekly() {
        HUB_Contents__c  c = new HUB_Contents__c ();
        c.Title__c = 'sample content';
        c.Description__c = 'test description';
        c.contentType__c = 'Campaign';
        c.URL__c='www.google.com';
        c.Source__c='DMX';
        c.Date__c=Date.today();
        c.End_Date__c=Date.today().addDays(10);
        c.Repeat__c=true;
        c.Frequency__c='Weekly';
        c.weeklyEveryNWeeks__c=String.valueOf(2);
        c.Repeat_RepeatOnWeek__c='Sunday';
        c.repeatStartDate__c=Date.today();
        c.repeatEndDate__c=Date.today().addDays(10);
        insert c;
		
		PageReference pageRef = Page.hub_Content;
		Test.setCurrentPage(pageRef);
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(c);
		ApexPages.currentPage().getParameters().put('id',c.id);
	    HUB_ContentController obj = new HUB_ContentController(sc);
        obj.weeks=new List<String>{c.Repeat_RepeatOnWeek__c};
        system.assert(obj.frequencyVisibility=='Weekly');
        obj.getWeeks();
        obj.getRepeatonweeks();
		obj.SaveMethod();
		

    }
    static testMethod void myUnitTestMonthlyOnDay() {
        HUB_Contents__c  c = new HUB_Contents__c ();
        c.Title__c = 'sample content';
        c.Description__c = 'test description';
        c.contentType__c = 'Campaign';
        c.URL__c='www.google.com';
        c.Source__c='DMX';
        c.Date__c=Date.today();
        c.End_Date__c=Date.today().addDays(10);
        c.Repeat__c=true;
        c.Frequency__c='Monthly';
        c.Monthly_Options__c='On day';
        c.monthlyDays__c='1';
        c.monthlyEveryNMonths__c=Integer.valueOf('1');
        c.repeatStartDate__c=Date.today();
        c.repeatEndDate__c=Date.today().addDays(10);
        insert c;
		
		PageReference pageRef = Page.hub_Content;
		Test.setCurrentPage(pageRef);
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(c);
		ApexPages.currentPage().getParameters().put('id',c.id);
	    HUB_ContentController obj = new HUB_ContentController(sc);
        system.assert(obj.frequencyVisibility=='Monthly');
        obj.getMonthlyOptions();
        obj.getMonthlyDays();
		obj.SaveMethod();
		

    }
    static testMethod void myUnitTestMonthlyOnthe() {
        HUB_Contents__c  c = new HUB_Contents__c ();
        c.Title__c = 'sample content';
        c.Description__c = 'test description';
        c.contentType__c = 'Campaign';
        c.URL__c='www.google.com';
        c.Source__c='DMX';
        c.Date__c=Date.today();
        c.End_Date__c=Date.today().addDays(10);
        c.Repeat__c=true;
        c.Frequency__c='Monthly';
        c.Monthly_Options__c='On the';
        c.monthlyNthDay__c='1st';
        c.monthlyWeeks__c='Sunday';
        c.monthlyEveryNMonths2__c=1;
        c.repeatStartDate__c=Date.today();
        c.repeatEndDate__c=Date.today().addDays(10);
        insert c;
		
		PageReference pageRef = Page.hub_Content;
		Test.setCurrentPage(pageRef);
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(c);
		ApexPages.currentPage().getParameters().put('id',c.id);
	    HUB_ContentController obj = new HUB_ContentController(sc);
        system.assert(obj.frequencyVisibility=='Monthly');
        obj.getMonthlyNthDay();
        obj.getMonthlyWeeks();
		obj.SaveMethod();
		

    }
    
    static testMethod void myUnitTestYearlyOnEvery() {
        HUB_Contents__c  c = new HUB_Contents__c ();
        c.Title__c = 'sample content';
        c.Description__c = 'test description';
        c.contentType__c = 'Campaign';
        c.URL__c='www.google.com';
        c.Source__c='DMX';
        c.Date__c=Date.today();
        c.End_Date__c=Date.today().addDays(10);
        c.Repeat__c=true;
        c.Frequency__c='Yearly';
        c.yearlyOptions__c='On every';
        c.yearlyMonth__c='January';
        c.yearlyDay__c='1';
        c.repeatStartDate__c=Date.today();
        c.repeatEndDate__c=Date.today().addDays(10);
        insert c;
		
		PageReference pageRef = Page.hub_Content;
		Test.setCurrentPage(pageRef);
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(c);
		ApexPages.currentPage().getParameters().put('id',c.id);
	    HUB_ContentController obj = new HUB_ContentController(sc);
        system.assert(obj.frequencyVisibility=='Yearly');
        obj.getYearlyOptions();
        obj.getYearlyMonth();
        obj.getYearlyDay();
		obj.SaveMethod();
		

    }
    static testMethod void myUnitTestYearlyOnthe() {
        HUB_Contents__c  c = new HUB_Contents__c ();
        c.Title__c = 'sample content';
        c.Description__c = 'test description';
        c.contentType__c = 'Campaign';
        c.URL__c='www.google.com';
        c.Source__c='DMX';
        c.Date__c=Date.today();
        c.End_Date__c=Date.today().addDays(10);
        c.Repeat__c=true;
        c.Frequency__c='Yearly';
        c.yearlyOptions__c='On the';
        c.yearlyNthDay__c='1st';
        c.yearlyNthDay2__c='Sunday';
        c.yearlyMonth2__c='January';
        c.repeatStartDate__c=Date.today();
        c.repeatEndDate__c=Date.today().addDays(10);
        insert c;
		
		PageReference pageRef = Page.hub_Content;
		Test.setCurrentPage(pageRef);
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(c);
		ApexPages.currentPage().getParameters().put('id',c.id);
	    HUB_ContentController obj = new HUB_ContentController(sc);
        system.assert(obj.frequencyVisibility=='Yearly');
        obj.getYearlyNthDay();
        obj.getYearlyNthDay2();
        obj.getYearlyMonth2();
		obj.SaveMethod();
		

    }
    
}