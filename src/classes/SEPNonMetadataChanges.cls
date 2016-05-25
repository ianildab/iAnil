@isTest
/*
    Non-Metadata Configuration Changes
    This document outlines changes that have been made to the system that cannot be propagate via the Force.com metadata API.

    =============================================================================================================================================
    | Deployment Troubleshoot section                                                                                                            |
    =============================================================================================================================================
    
    Sympthom: Schedulable class has jobs pending or in progress
    Solution: Delete the 'ClosedTrend' Schedule under Yourname | Setup | Administration Setup | Monitoring | Scheduled Jobs  OR ...salesforce.com/08e
    
    ---------------------------------------------------------------------------------------------------------------------------------------------
    
    Sympthom: System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Name]: [Name]
    Solution: (Workaround) Fill out your User's Country_Code__c field. (Final) Don't rely on the CurrentUser's Country_Code__c in the TestClasses.
    
    
    =============================================================================================================================================
    | Active Changes                                                                                                                            |
    =============================================================================================================================================

    These changes have not yet been deployed to production and will not be present after a sandbox refresh.
    As such, it is important to ensure that these are replicated when deploying releases to new environments.
    Once deployed to production, changes should be moved out the Active Changes section and into the historical changes section.

    Type - PP (Need to be done before PreDeploy) Pre (Required before Deploy) M (Manual Change after Deploy) Post (Steps after PostDeploy) D (Developer sandbox configuration only - Not required for PROD deploy)
    Date - Enter the date that the change was made (YYYY-MM-DD)
    Changed by - Name of developer/admin
    Change Description - Brief description of what was changed
    Workstream - CIC, CRM, STMG, etc...
    Document Reference - If the change steps are too long to be listed here, provide a link to an SVN document outlining the change in detail.

    Id (Type)    Date         Changed by           Change Description                                            Workstream    Document Reference   Jira Reference      Comments
    ===========  ===========  =================    ===========================================================   ===========   ===================  ===============  ===================

    1            2013-08-22     Zsolt Penzes        Automated smoke suite was changed cause by PT roll out          CRM                             CRM-1201            Only for Smoke test suite use 
                                                    2 new list view and 1 new public group needed
                                                    - create a new public group "Smoke test case list view group"
                                                        - Zsolt Penzes
                                                        - Nora Papp
                                                        - Mate Kokenyesi
                                                        - Gyula Sipos
                                                        
                                                    Create 2 new list view on the Account tab
                                                        - View Name: ES CRM Account Test
                                                        - All accounts
                                                        - Filters:
                                                            - Field: Account Ext Id, Operator: starts with, Value: COKEID
                                                            - Field: Nationality, Operator: equals, Value: Spain
                                                        - Selected Fields:
                                                            - Account Name
                                                            - Nationality                                                            
                                                        - Restrict Visibility:
                                                            - Group: Smoke test case list view group
                                                            
                                                        - View Name: PT CRM Account Test
                                                        - All accounts
                                                        - Filters:
                                                            - Field: Account Ext Id, Operator: starts with, Value: COKEID
                                                            - Field: Nationality, Operator: equals, Value: Portugal
                                                        - Selected Fields:                                                            
                                                            - Account Name
                                                            - Nationality
                                                        - Restrict Visibility:
                                                            - Group: Smoke test case list view group    
                                                            
     2        2013-10-09        Brian Kessler        "Changed" Potential_Risk__c from checkbox to picklist                ECIC                            CIC-586
                                                     1. Deactivated and deleted all Validation Rules, Workflows,
                                                         and other metadata dependant upon original 
                                                         "Potential_Risk__c" checkbox field.
                                                         (These will all be replaced with modified equivalents
                                                             when the metadata is deployed.)
                                                     2. Renamed "Potential_Risk__c" checkbox to "Old_Potential_Risk__c".
                                                     3. Created new "Potential_Risk__c" picklist with values:
                                                         * No Risk
                                                         * Medium Risk
                                                         * High Risk
                                                        
    3        2013-10-14        Krishna Kandula            "Changed" View All Permissions on ECIC_Support profile to 'Read Only' Permissions                CIC-633
                                                    1. Edited the Object Settings and changed View All Object permissions to Read.
                                                    
                                                    2. Unchecked the View All Data check box in the System Permissions.
                                                                                               
     4        2013-10-15        Yury Zaranok        "Changed" Country_Code__c from Text(2) to Picklist                    ECIC                                CIC-629
                                                     1. Deactivated and deleted all Validation Rules, Workflows,
                                                         and other metadata dependant upon original 
                                                         "Country_Code__c" text field.
                                                         (These will all be replaced with modified equivalents
                                                             when the metadata is deployed.)
                                                     2. Renamed "Country_Code__c" checkbox to "Old_Country_Code__c".
                                                    
    5        2013-10-16        Iga Chworostowska        "Changed" 
                                                         1. Added below profiles to "CSE_Senior_Roles" Public Group
                                                         "CSE_CIC_Operative_Roles" Public Group (Item16)
                                                         CSE CIC Social Media K&I Manager
                                                         Coca-Cola CSE 
                                                         2. Added below profiles to "CSE_Junior_Roles" Public Group    
                                                         CSE CIC SM Junior Manager - Austria
                                                         CSE CIC SM Junior Manager - Bulgaria
                                                         CSE CIC SM Junior Manager - Czech Republic
                                                         CSE CIC SM Junior Manager - Greece
                                                         CSE CIC SM Junior Manager - Hungary
                                                         CSE CIC SM Junior Manager - Italy
                                                         CSE CIC SM Junior Manager - Poland
                                                         CSE CIC SM Junior Manager - Romania
                                                         CSE CIC SM Junior Manager - Serbia
                                                         CSE CIC SM Junior Manager - Switzerland
                                                         
     6        2013-10-18        Yury Zaranok        Changes ID value for the pages:                                ECIC                                CIC-629
                                                    - ECICContactNewAction
                                                    - ECICAccountNewAction
                                                    To proper work those pages you need to replace all occurrences 
                                                    of the value '00N11000000SgZs' to a new value in accordance 
                                                    with the environment:
                                                     - The new value for the DEV env: 00N11000000OQej
                                                     - The new value for the INT env: 00N11000000SpFr
                                                    For other environments, to find the Id to use follow these steps:
                                                     - Click on Setup - Customize - Contacts - Fields;
                                                     - Click on the name of the custom field - 'Country Code' picklist.
                                                     - Look at your browser’s address bar, you’ll see something like: https://ecic--dev.cs18.my.salesforce.com/00N11000000OQej?setupid=ContactFields
                                                     - The 15 digit code that appears immediately after  https://ecic--dev.cs18.my.salesforce.com/ is the ID of that custom field; in this case the ID of the custom field is 00N11000000OQej
                                                     
     7        2013-10-23        Andrey Pshenichnikov                                                            ECIC                CIC-542
                                                     Activate CSE Languages:
                                                     1. Go Setup -> Customize -> Knowledge -> Settings:
                                                     2. Click Edit
                                                     3. In 'Language Settings' section add the following CSE Languages as Active:
                                                        - German
                                                        - Bulgarian
                                                        - Czech
                                                        - Greek
                                                        - Hungarian
                                                        - Italian
                                                        - Polish
                                                        - Romanian
                                                        - Serbian
                                                        - French
                                                      4. Save Knowledge Settings
     
     8        2013-10-23        Andrey Pshenichnikov                                                            ECIC                CIC-548
                                                     After Deployment:
                                                     
                                                     1)Mapping of CSE Roles to 'Markets' data categories
                                                     
                                                     To establish KB article visibility based on BU/Market,          
                                                     the following mapping of CSE roles to categories in the
                                                     'Markets' data category group have to be performed:
                                                     -----------------------------------------------------------------------------------------------------------------------------------------
                                                     | Role                                                         | Type              | Category within 'Markets' category group                 |
                                                     -----------------------------------------------------------------------------------------------------------------------------------------
                                                     | Coca-Cola CSE                                             | Custom          | > Europe > Central & Southern Europe                     |                             
                                                    |     CSE CIC Marketing Manager                                | Inherited from | Coca-Cola CSE                                            |
                                                    |         CSE CIC Social Media K&I Manager                      | Inherited from | Coca-Cola CSE                                            |
                                                    |               CSE CIC SM Area Manager                            | Inherited from | Coca-Cola CSE                                            |
                                                    |                CSE CIC SM Junior Manager - Austria            | Custom         | > Europe > Central & Southern Europe > Austria            |
                                                    |                CSE CIC SM Junior Manager - Bulgaria        | Custom         | > Europe > Central & Southern Europe > Bulgaria            |
                                                    |                CSE CIC SM Junior Manager - Czech Republic    | Custom         | > Europe > Central & Southern Europe > Czech Republic    |
                                                    |                CSE CIC SM Junior Manager - Greece            | Custom         | > Europe > Central & Southern Europe > Greece            |
                                                    |                CSE CIC SM Junior Manager - Hungary            | Custom         | > Europe > Central & Southern Europe > Hungary            |
                                                    |                CSE CIC SM Junior Manager - Italy            | Custom         | > Europe > Central & Southern Europe > Italy                |
                                                    |                CSE CIC SM Junior Manager - Poland            | Custom         | > Europe > Central & Southern Europe > Poland            |
                                                    |                CSE CIC SM Junior Manager - Romania            | Custom         | > Europe > Central & Southern Europe > Romania            |
                                                    |                CSE CIC SM Junior Manager - Serbia            | Custom         | > Europe > Central & Southern Europe > Serbia            |
                                                    |                CSE CIC SM Junior Manager - Switzerland        | Custom         | > Europe > Central & Southern Europe > Switzerland        |
                                                    -----------------------------------------------------------------------------------------------------------------------------------------
                                                    
                                                    2) Assignment to Groups
                                                    To provide users with access to KB Reports and to provide
                                                    AM and SM with all available Article Actions:
                                                    - Junior SM Managers to be added to the 
                                                      'KB - Knowledge Users' group - to get access to
                                                       KB Knowledge Reports and Dashboards
                                                    - K&I Managers to be added to the 
                                                      'KB - Knowledge Managers' group - to get access to
                                                       KB Management reports and Dashboards
                                                    - SM Marketing Manager and Area Managers - to be added to
                                                      the 'KB - Knowledge Publishers' group - to get access to
                                                      all Knowledge Actions and to KB Management reports
                                                      and Dashboards.
                                                    They can be added via Role.
                                                    
                                                    3) Assignment of Permission Sets to Users:
                                                    To provide users with access to new fields on 'Question and Answer'
                                                    article type the following new permission sets were created:
                                                    ---------------------------------------------------------------------------------------
                                                    | Permission Set                         | Article Type     | Field                 | Access |
                                                    ---------------------------------------------------------------------------------------
                                                    | KB - External Approval - Read         | kbFAQ            | Approved_By__c     | Read      |
                                                    |                                        |                | Approved_On__c     | Read   |
                                                    ---------------------------------------------------------------------------------------
                                                    | KB - External Approval - Edit         | kbFAQ            | Approved_By__c     | Edit   |
                                                    |                                        |                | Approved_On__c     | Edit   |
                                                    ---------------------------------------------------------------------------------------
                                                    | KB - Multiple Countries L10N - Read    | kbFAQ            | Target_Country__c  | Read   |
                                                    |                                        |                | Origin_Ref__c         | Read   |
                                                    ---------------------------------------------------------------------------------------
                                                    | KB - Multiple Countries L10N - Edit    | kbFAQ            | Target_Country__c  | Edit   |
                                                    |                                        |                | Origin_Ref__c         | Edit   |
                                                    ---------------------------------------------------------------------------------------
                                                    The following new and existing permission sets must be assigned to CSE Users:
                                                    - Junior SM Managers: 
                                                       - 'KB - External Approval - Read',
                                                       - 'KB - Multiple Countries L10N - Read'
                                                       - 'KB - All Article Types - Read'
                                                       - 'KB - Use Knowledge App'
                                                       - 'KB - View Articles and Reports tabs'
                                                       
                                                    - SM K&I Manager:
                                                       - 'KB - External Approval - Read',
                                                       - 'KB - Multiple Countries L10N - Read'
                                                       - 'KB - KB Management - Salesforce License'
                                                       - 'KB - All Article Types - Read'
                                                       - 'KB - Use Knowledge App'
                                                       - 'KB - View Articles and Reports tabs'
                                                        
                                                    - Area Managers and Marketing Manager: 
                                                       - 'KB - External Approval - Edit'
                                                       - 'KB - Multiple Countries L10N - Edit'
                                                       - 'KB - All Article Types - All Actions'
                                                       - 'KB - KB Management - Salesforce License'
                                                       - 'KB - Use Knowledge App'
                                                       - 'KB - View Articles and Reports tabs'
                                                    
                                                    Permission sets providing access to 'Permissions' data categories
                                                    are set based on forms filled in by specific users.
                                                    
                                                    4) Knowledge Licences
                                                    Since Winter'14, Knowledge licences are required for Knowledge Managers only:
                                                    - Junior SM Managers - no KB license required
                                                    - SM K&I Manager, Area Managers and Marketing Manager will require assignment of Knowledge license.       
                                                       
                                                    
    9        2013-10-24                Yury Tyryshkin                                                        ECIC                            CIC-607
                                                    After deployment please fill groups by next values:
                                                    ___________________________________________________________________
                                                    |    Group                |            Values                          |
                                                    |                        |                                          |
                                                    -------------------------------------------------------------------
                                                    |    AT ECIC All            |CSE CIC SM Junior Manager - Austria(Role)|
                                                    |                        |CSE Senior Roles (Group)                  |
                                                    --------------------------------------------------------------------
                                                    |    BG ECIC All            |CSE CIC SM Junior Manager - Bulgaria(Role)|
                                                    |                        |CSE Senior Roles    (Group)                   |
                                                    --------------------------------------------------------------------------
                                                    |    CZ ECIC All            |CSE CIC SM Junior Manager - Czech Republic(Role)|
                                                    |                        |CSE Senior Roles    (Group)                        |
                                                    --------------------------------------------------------------------------
                                                    |    CH ECIC All            |CSE CIC SM Junior Manager - Switzerland (Role)|
                                                    |                        |CSE Senior Roles    (Group)                       |
                                                    ------------------------------------------------------------------------
                                                    |    GR ECIC All            |CSE CIC SM Junior Manager - Greece (Role)|
                                                    |                        |CSE Senior Roles                (Group)      |
                                                    --------------------------------------------------------------------
                                                    |    HU ECIC All            |CSE CIC SM Junior Manager - Hungary (Role)|
                                                    |                        |CSE Senior Roles                    (Group)|
                                                    --------------------------------------------------------------------
                                                    |    IT ECIC All            |CSE CIC SM Junior Manager - Italy  (Role)|
                                                    |                        |CSE Senior Roles                   (Group)|
                                                    --------------------------------------------------------------------
                                                    |    PL ECIC All            |CSE CIC SM Junior Manager - Poland (Role) |
                                                    |                        |CSE Senior Roles                    (Group)|
                                                    -------------------------------------------------------------------
                                                    |    RO ECIC All            |CSE CIC SM Junior Manager - Romania(Role)|
                                                    |                        |CSE Senior Roles                   (Group)|
                                                    --------------------------------------------------------------------
                                                    |    RS ECIC All            |CSE CIC SM Junior Manager - Serbia (Role) |
                                                    |                        |CSE Senior Roles                    (Group)|
                                                    --------------------------------------------------------------------
                                                    |    ECIC All            |AT ECIC All, BG ECIC All, CZ ECIC All,|
                                                    |                        |CH ECIC All, GR ECIC All, HU ECIC All,|
                                                    |                        |IT ECIC All, PL ECIC All, RO ECIC All,|
                                                    |                        |RS ECIC All, ES ECIC All, PT ECIC All.|
                                                    |                        |AT_Support, BG_Support, CZ_Support,   |
                                                    |                        |CH_Support, GR_Support, HU_Support,   |
                                                    |                        |IT_Support, PL_Support, RO_Support,   |
                                                    |                        |RS_Support, PT_Support, ES_Support.   |
                                                    ----------------------------------------------------------------
                                                    
    10        2013-11-06        Brian Kessler        Case.Record_Type_Name__C must be changed from formula-field to text-field.
                                                    1. Renamed old Record_Type_Name__C to Old_Record_Type_Name__C  (probably unnecessary to keep this as the field isn't used and the formula is broken).
                                                    2. Created new Record_Type_Name__C text field (size 50; 30 is probably more than enough, but the extra is just future-proofing).
                                                    
    11        2013-11-13        Brian Kessler        Country_Specific_settings__c.Quality_Complaint_Record_Type_Id__c has to be filled for all countries 
                                                    (including ES and PT)
                                                    There should (eventually) be a "base file" at: trunk\data\Country-Specific_Settings.csv
                                                    ES and PT need "Quality Complaint" RecordType id: possibly 01220000000JMHl (but this depends on the sandbox)
                                                    AT,BG,CH,CZ,GR,HU,IT,PL,RO,RS need "Simplified Quality Complaint" RecordType id: ????????
                                                    
    12        2013-11-14        Mate Kokenyesi        Set 'Enable Email Drafts' on the Case Support Setting page ( /_ui/support/organization/SupportOrganizationSetupUi/d )
                                                    
    
    13      2013-11-14      Zsolt Penzes            Replace values in the extract fields before update the Account records again         CRM-1236
                                                    note: Nodepad++ helps you in it.
                                                        0, set credential in 
                                                           "trunk/data/field_consolidation_data_migration_scripts/scripts/config.properties" file to production
                                                        1, run the "extract_field_data_from_the_old_field.sh" in the
                                                           "trunk/data/field_consolidation_data_migration_scripts/scripts/" folder
                                                        2, success/ExtractContactSTMBirthday__c.csv
                                                           replace all date with the following regular expression order
                                                           from "(\d\d\d\d-\d\d-\d\d)" to "\1T00:00:00.000Z"
                                                        3, success/ExtractContactSTMGender__c.csv
                                                           from "Male" to " male"
                                                           from "Female" to "female"
                                                        4, success/ExtractContactSTMYearBirth__c.csv
                                                           from date to only year
                                                           note the consolidated field is a Number(4,0) field instead of Date
                                                        5, success/ExtractOnlyCRMRelatedFieldData.csv
                                                           from "(\d\d\d\d-\d\d-\d\d)" to "\1T00:00:00.000Z"
                                                           from "M" to "male"
                                                           from "F" to "female"
                                                           from "N" to "unknown"
                                                           from "0" to "Active"
                                                           from "1" to "Inactive"
                                                           from "2" to "Blocked"
                                                           from "3" to "Deleted"
                                                        6, run the "update_field_data_from_the_old_field.sh" in the
                                                           "trunk/data/field_consolidation_data_migration_scripts/scripts/" folder
                                                        7, after that the post deploy could be run   

    14        2013-11-18    Yury Tyryshkin            Permission set "Junior SM Managers Specific permissions " should be assigned on "CSE Junior SM Manager" users     CIC-755            ECIC
    
    15        2013-11-18        Mate Kokenyesi        AT,BG,CH,CZ,GR,HU,IT,PL,RO,RS queues must contains the     followings:                            CIC-758
                                                    * CSE CIC SM Junior Manager (of the country)
                                                    * CSE CIC SM Area Manager (of the country)
    
    16        2013-11-18        Mate Kokenyesi        CSE_CIC_Operative_Roles should contains the following roles:
                                                    CSE CIC Marketing Manager
                                                    CSE CIC SM Area ManagerS!
                                                    
    17        2013-11-19        Mate Kokenyesi        Case Feed Enabled has to be a manual step for the Profiles (Infoline Agent, Infoline Supervisor, ECIC_External Relations) CIC-623
    
    18        2013-11-22        Mate Kokenyesi        Case.Type labels need to be changed to 'Case Type'
    
    19         2013-11-24         Krishna Kandula        Existing Active Users details in the organization are updated by running                     CIC-776
                                                the following query in the developer console.
                                                ECICUserSignatureUpdater obj = new ECICUserSignatureUpdater();
                                                obj.UpdateUsers();
                                                
                                                This query calls the ECICuserupdate class which updates the email signature id of ES and 
                                                PT profiles users based on country specific and the rest of the profile users on user specific.
                                                The query needs to be run only once after the deployment is done. This is to assist the 
                                                updating of users details especially their E_Mail_Signature_Id in relation to CIC-564 and 
                                                CIC-711 for Email Templates for catching ids from Country Specific Settings. 
                                                For the Users which will be created newly the SEPUserTrigger deals with it.
    
    20        2013-11-24        Andrey Pshenichnikov    CSE: KB - Reporting & Analytics                                                            CIC-555        ECIC
                                                    I.    Running user for the following dashboard should be manually set to a user with
                                                        'CSE CIC SM Marketing Manager' role:
                                                            Dashboard folder: CSE CIC KB Dashboards
                                                            Dashboard: Q&A Articles (Dashboard Unique Name: KB_kbFAQ)
                                                    II. Since dashboards implemented in previous releases were modified (updated with a set of
                                                        new languages), their deployment will reset the 'Drill Down' property to a default
                                                        value on each table component. 
                                                        The following manual changes are needed to restore the behavior 
                                                        (article titles should be a link following to detail views of the article):
                                                            - Open dashboards in edit mode and for each affected component:
                                                              in Component Editor ->'Component Data' tab: 
                                                              in the 'Drill Down to' drop-down list chose 'Record Detail Page'.
                                                            Affected Dashboards and their components:
                                                                Folder: KB - Knowledge Dashboards
                                                                    Dashboard: Knowledge Articles Overview
                                                                        Component: all components
                                                                    Dashboard: Top Published Articles
                                                                        Component: all components
                                                                Folder: KB - Knowledge Management Dashboards
                                                                    Dashboard: Knowledge Manager Overview
                                                                        Component: Last Modified Article Versions
                                                                    Dashboard: Knowledge Maintenance
                                                                        Component: Last Modified Article Versions
                                                                        Component: Oldest Knowledge Articles (20 Articles based on Last Published Date)
                                                                        Component: Articles with Lowest Score (20 Articles - Calculated from User Votes)
                                                                    Dashboard: Use of Articles in Cases
                                                                        Component: Articles Used in Cases - Publ.This Month
                                                                        Component: Articles Used in Cases - Publ. This Year
                                                                        Component: Articles Used in Cases - All Time
                                                                        
    21        2013-11-25        Yury Tyryshkin                'Social Setup' object is unavailable for Senior SM managers                 CIC-835                ECIC
                                                                         
                                                        Assign "SF FOR SM For Senior CSE Roles" permission set to Senior CSE Roles users.
    
    22      2013-11-25      Gergely Molnar              Create new entry in Profiles_Mapping__c. Key: 'System Administrator' Value (ID__c) : system admin profile ID
    
    23        2013-12-04        Yury Tyryshkin                [UAT] Make Case Country Code editable for Senior CSE Roles                    CIC-898                ECIC
                                            
                                                        Assign "Multi-country Case Management" permission set to Senior CSE Roles users

    24      2013-10-12      Gergely Molnar              Country_Specific_Settings__c.Laboratory_of_Analysis__c must be filled in for ES and PT (only):
                                                            ES: 0012000000tIKIr (PROD value)
                                                            PT: 0012000000tIEOu (PROD value)
                                                            
                                                        These values are added to .../trunk/data/Country-Specific_Settings.csv
                                                        Btw, USER_ROLE_LIST__C column has been dropped from CSV (as we found it never used).
                                                        
    25        2013-12-11        Iga Chworostowska            Create new Organization-Wide Email Addresses for CSE countries:
                                                            Display Name                Email Address            Allowed Profiles
                                                            Coca-Cola Österreich        at.cic@coca-cola.com    ECIC_Infoline Agent, ECIC_Infoline Supervisor
                                                            Coca-Cola България            bg.cic@coca-cola.com    ECIC_Infoline Agent, ECIC_Infoline Supervisor
                                                            Coca-Cola Česká Republika    cz.cic@coca-cola.com    ECIC_Infoline Agent, ECIC_Infoline Supervisor
                                                            Coca-Cola Hellas            gr.cic@coca-cola.com    ECIC_Infoline Agent, ECIC_Infoline Supervisor
                                                            Coca-Cola Magyarország        hu.cic@coca-cola.com    ECIC_Infoline Agent, ECIC_Infoline Supervisor
                                                            Coca-Cola Italia            it.cic@coca-cola.com    ECIC_Infoline Agent, ECIC_Infoline Supervisor
                                                            Coca-Cola Polska            pl.cic@coca-cola.com    ECIC_Infoline Agent, ECIC_Infoline Supervisor
                                                            Coca-Cola Romania            ro.cic@coca-cola.com    ECIC_Infoline Agent, ECIC_Infoline Supervisor
                                                            Coca-Cola Srbija            rs.cic@coca-cola.com    ECIC_Infoline Agent, ECIC_Infoline Supervisor
                                                            Coca-Cola Switzerland        ch.cic@coca-cola.com    ECIC_Infoline Agent, ECIC_Infoline Supervisor
                                                            
    26        2014-02-06        Iga Chworostowska            CIC-983 - Create country configuration (Case Trigger Configuration): saved in CaseTriggerConfiguration folder (D:\UTIL\trunk\data)                                                       
                                                            AT.csv
                                                            BG.csv
                                                            CH.csv
                                                            CZ.csv
                                                            FR.csv
                                                            GR.csv
                                                            HU.csv
                                                            IT.csv
                                                            PL.csv
                                                            RO.csv
                                                            RS.csv
                                                            ES.csv
                                                            PT.csv
                                                            Case Trigger Configuration - DataLoader Scenario.sdl
    --------------------------------------------------------------------
     ---------- CIC NWEN FR Release                         ------------
    --------------------------------------------------------------------
                                                            
                                                            
    1    2014-02-27        Yury Tyryshkin           Activate French translation                    (CIC-1165)
                                                    - go to Setup->Administration Setup->Translation Workbench->Translation Settings
                                                    - click "Edit" on French record
                                                    - set Active checkbox in true state
                                                        
    2    2014-03-13        Mate Kokenyesi           CIC Iberia Release did some modification in the User Roles, and Public groups: Iberia
                                                    If you receive an error message like  
                                                    Error: In field: group - no Group named Iberia_Support found (line 5499, column 19)
                                                                    Iberia Roles
                                                    
                                                    Please run the PreDeploy to introduce the new Roles and Public Groups.
                                                    
    3  2014-03-26          Mate Kokenyesi           ant preDeploy (To Delete Sharing rules, update classes that are referencing to Country_Code__c field)

                                                    Delete the Case Assignment rule /setup/own/entityrulelist.jsp?rtype=1&entity=Case

                                                    CC change: Click Change Type -> Picklist -> Value: ES for example (will be filled later) SAVE
                                                    https://ecic.my.salesforce.com/00N20000003b7Gx/e - Account
                                                    https://ecic.my.salesforce.com/00N20000003ZhOE/e - Case
                                                    https://ecic.my.salesforce.com/00N20000003Zgfj/e - Action Plan
                                                    https://ecic.my.salesforce.com/00N20000003b7Ha/e - Plant__c
                                                    https://ecic.my.salesforce.com/00N20000003b7Hb/e - Product*
                                                    https://ecic.my.salesforce.com/00N20000003b7Hd/e - Production Line
                                                    https://ecic.my.salesforce.com/00N20000003b7Hf/e - Promotion
                                                    https://ecic.my.salesforce.com/00N20000003b7He/e - Promotion Type
                                                    https://ecic.my.salesforce.com/00N20000003b7Hg/e - Region
                                                    https://ecic.my.salesforce.com/00N20000003ZhOX/e - Trend
                                                    
                                                    RENAME
                                                    https://ecic.my.salesforce.com/00N20000002xSJp/e Change Case.Damage_Caused -> Old_Damage_Caused ((Old) Damage Caused)
                                                    
                                                    DELETE
                                                    On the Property__c object /01I20000000MoUj please delete the Property_ID_del__c field
                                                     
                                                    Reintroduce the Case Assignment Rule /setup/own/entityrulelist.jsp?rtype=1&entity=Case

                                                    ant deploy

                                                    Set EUDB Workflow field update.
 
    4    2014-04-02            Brian Kessler        Change Field Type for both Open_Alert_Case__c Lookup fields to Master-Detail fields.
 
                                                    https://ecic.my.salesforce.com/00N20000003L19L/e - Case
                                                    https://ecic.my.salesforce.com/00N20000003L19N/e - Open_Alert__c
                                                    
                                                    (Click the "Change Field Type" button; accept default values.)
                                                    
                                                    
                                                    
    5  2014-04-04          Krishna Kandula         France_CIC Queue must contain the following roles set after the deployment:                           CIC-1099
                                                    -- FR CIC Manager
                                                    -- FR CIC Supervisor
                                                    -- FR CIC Agent
                                                    
    6  2014-04-08            Krishna kandula        Quick Service Restaurant-QSR Picklist Value in Account.Trade_Channel__c field should                  CIC-1135
                                                    be replaced with the Fast Service Restaurant Picklist value in Account.Trade_Channel__c 
                                                    after the deployment.
                                                    The process is :- After the deployment navigate to 
                                                    Setup--> Customize-->Acciunts-->Fields-->Trade channel-->
                                                    1.Click the replace option at the top of the picklist values 
                                                    2.Exact Value Changing from should be filled with Quick Service Restaurant-QSR
                                                    3.Select Value Changing to should be filled with Fast Service Restaurant
                                                    4.Replace all blank values should NOT be checked.
                                                    5.Click replace.
                                                    
                                                    After replacing the value Quick Service Restaurant should be deleted from the sandbox
                                                    This value has been included in the PostDeply/desctructiveChanges.xml
                                                    
                                                    
    7    2014-04-10            Iga Chworostowska    Case.workflow ccEmails in FR_Potential_Risk_Quality alert should be changed            PROD ONLY       CIC-1408
                                                    from:
                                                        <ccEmails>pcordebar@cokecce.com.invalid</ccEmails>
                                                        <ccEmails>cmalderez@cokecce.com.invalid</ccEmails>
                                                    to:
                                                        <ccEmails>pcordebar@cokecce.com</ccEmails>
                                                        <ccEmails>cmalderez@cokecce.com</ccEmails>    

    8    2014-04-11            Iga Chworostowska    CIC-1503 - Create scheduled reports                                                                       CIC-1503
                                                    Liste des dossiers ouverts (5 jours)
                                                    Liste des dossiers ouverts (1 mois)
                                                    Report schedule:
                                                    Running user: FR CIC Manager 
                                                    Send to Roles: FR CIC Manager and FR CIC Supervisor
                                                    Frequency: every weekday, End date: 1/1/2050, time: 8am
                                                    
    9    2014-04-11             Iga Chworostowska   CIC-1502 - Create SM profiles                                                                            CIC-1502
                                                    New "ECIC SM Agent" and "ECIC SM Supervisor" profiles will replace ECIC Infoline Agent and ECIC Infoline Supervisor in CSE countries.
                                                    
                                                    
    10    2014-04-14            Yury Tyryshkin      CIC-1505: Create new org. wide email address                                                            CIC-1505
                                                    Add manually new org. wide email address for France : Setup-> Administration Setup-> Email Administration -> Organization-Wide Addresses
                                                    ---------------------------------------------------------------------------------------
                                                    | Display Name  |    Coca-Cola France                                                  |
                                                    | Email Address |    fr.ciccontact@coca-cola.com                                          |
                                                    | Profiles         |  ECIC_Infoline Agent, ECIC_Infoline Supervisor, System Administrator|
                                                    ---------------------------------------------------------------------------------------
                                                    
    11    2014-04-15            Iga Chworostowska   FR email templates (VF emails and Components) need to be updated with IDs to images (headers/footers added to Documents)    CIC-1406
                                                    
                                                    Image Name (NWEN Images Documents Folder)  |dev2 ID (used in templates) |SIT ID (used in templates) |UAT ID (used in templates)
                                                    FR_E_Mail_Footer_Image                     |015110000009HRK             |0151100000010eZ            |0151100000015lG
                                                    FR_E_Mail_Footer_Image_Letter              |015110000009Hyi             |0151100000010ea            |0151100000015lH
                                                    FR_E_Mail_Header_Image                     |015110000009HR5             |0151100000010eb            |0151100000015lI
                                                    FR_E_Mail_Paper_Recycling                  |015110000009HzH             |0151100000010ec            |0151100000015lJ
                                                    FR_E_Mail_Signature_Image                  |015110000009HRF             |0151100000010ed            |0151100000015lK
                                                    
                                                    in Components also change the link:
                                                    from 
                                                    https://ecic--sit--c.cs18.content.force.com 
                                                    to 
                                                    https://ecic--...--c.cs18.content.force.com
    
    12    2014-04-16            Iga Chworostowska   Updating Custom Object Permissions on Profiles for Package Object                                        CIC-1472

                                                    Profile                         Tab Settings        Read    Create   Edit    Delete    View All Modify All 
                                                    ECIC_Administrator                Default Off       FALSE   FALSE   FALSE    FALSE    FALSE    FALSE
                                                    ECIC_Bottler Quality            Tab Hidden          TRUE    FALSE   FALSE    FALSE    FALSE    FALSE
                                                    ECIC_Coca-Cola Quality            Tab Hidden        TRUE    FALSE   TRUE     FALSE    FALSE    FALSE
                                                    ECIC_External Relations            Tab Hidden       TRUE    FALSE   FALSE    FALSE    FALSE    FALSE
                                                    ECIC_Infoline Agent                Default Off      TRUE    FALSE   FALSE    FALSE    FALSE    FALSE
                                                    ECIC_Infoline Supervisor        Default Off         TRUE    FALSE   TRUE     FALSE    FALSE    FALSE
                                                    ECIC_SM_Agent                    Default Off        TRUE    FALSE   FALSE    FALSE    FALSE    FALSE
                                                    ECIC_SM_Supervisor                Default Off       TRUE    FALSE   TRUE     FALSE    FALSE    FALSE
                                                    ECIC_Support                    Tab Hidden          TRUE    FALSE   FALSE    FALSE    FALSE    FALSE
                                                    System Administrator            Default Off         TRUE    TRUE    TRUE     TRUE     TRUE     TRUE

    13    2014-04-18        Alexandre Felisberto    Removed reference to Active_OR_Master_Product_Null__c in Product* Sharing Rules Criteria                                            CIC-1472
                                                    
                                                    Component Failures:
                                                    1.  objects/Product__c.object (Product__c.Active_OR_Master_Product_Null__c) -- Error: This custom field is reference
                                                    elsewhere in Salesforce.com. : Criteria-based Sharing Rules .
                                                    
                                                    Modify Sharing rule criteria for Product*:
                                                    
                                                    (Product*: Country CodeEQUALSES) AND (Product*: Active OR Master Product NullEQUALSTrue) => (Product*: Country CodeEQUALSES)

                                                    (Product*: Country CodeEQUALSPT) AND (Product*: Active OR Master Product NullEQUALSTrue) => (Product*: Country CodeEQUALSPT)
                                                    
    14    2014-04-21            Yury Tyryshkin      Change Case Level 1 from "Thanks" to "Compliment"; Merge new Case categories                            CIC-1516; CIC-1529
    
                                                Before deploying changes please do manual changes described below:
                                
                                                1. Rename Case RTs "Thanks" to "Compliment" and "Joke / Useless" to "Useless"
                                                2. Create CaseRecordType__c.COMPLIMENT_RECORD_TYPE_ID and CaseRecordType__c.USELESS_RECORD_TYPE_ID(with same properties to THANKS_RECORD_TYPE_ID and JOKE_USELESS_RECORD_TYPE_ID)
                                                3. Set ID value of Case RTs "Compliment" to CaseRecordType__c.COMPLIMENT_RECORD_TYPE_ID and "Useless" to CaseRecordType__c.USELESS_RECORD_TYPE_ID
                                                4. Rename Case.RecordType = 'Thanks' to Case.RecordType = 'Compliment' and Case.RecordType = 'Joke / Useless' to Case.RecordType = 'Useless'
                                                5. Change references from CaseRecordType_c.THANKS_RECORD_TYPE_ID to CaseRecordType_c.COMPLIMENT_RECORD_TYPE_ID
                                                6. Rename 'Thanks' and 'Joke / Useless' in Case.Type to 'Compliment' and 'Useless'
                                                7. Rename "Compliment" to 'Thanks' in Case.Reason
                                                    
    
    15    2014-04-21            Iga Chworostowska   Related to Id (Type): 6 added by Yury Zaranok on 2013-10-18: "Changes ID value for the pages" CIC-629                        CIC-1507
                                                Update below pages with relevant IDs
                                                - ECICContactNewAction
                                                - ECICAccountNewAction
                                                Replace '00N11000000SpFr' value to a new value in accordance with the environment:
                                                     - The new value for the SIT env: 00N20000003LWLi
                                                     - The new value for the UAT env: 00N20000003LWLi
    
    16  13/03/2014   Iga Chworostowska          Below Case.AssignmentRules have been deleted from DEV8:                                            CIC-1101       Type - PP (Need to be done before PreDeploy     
        04/06/2014   Alexandre Felisberto                                                                                                          CIC - 1681       added assignment rule for FR cases
                                                Action Order    Criteria                                                  Assign To
                                                1   Spain_CIC
AND(ISPICKVAL(Country_Code__c , 'ES'), ISPICKVAL(Origin, 'Web'),OR(PRIORVALUE( OwnerId ) == '00G20000001hBNs',OwnerId = '00520000002b4rH'))
                                                2   Spain_CIC
AND(ISPICKVAL(Country_Code__c , 'ES'), OR( ISPICKVAL( Origin , "Facebook"),ISPICKVAL(Origin, "Twitter") ),NOT( ISBLANK( ContactId ) ), PRIORVALUE( OwnerId ) == '00G20000001hBNs' )
                                                3   Spain_Supervisor
AND(ISPICKVAL(Country_Code__c , 'ES'), ISPICKVAL(Origin , 'External Relations'), NOT( ISBLANK( ContactId ) ), PRIORVALUE( OwnerId ) == '00G20000001hBNs' )
                                                4   Spain Coca-Cola Quality
AND(OR(ISPICKVAL(Country_Code__c , 'ES'),ISPICKVAL(Country_Code__c , 'PT')), ISPICKVAL(Origin, 'Commercial Dept.') , NOT( ISBLANK( ContactId ) ), PRIORVALUE( OwnerId ) == '00G20000001hBNs')
                                                5   Portugal_CIC
AND(ISPICKVAL(Country_Code__c , 'PT'), ISPICKVAL(Origin, 'Web'),OR(PRIORVALUE( OwnerId ) == '00G20000001hBNs',OwnerId = '00520000002b4rH', OwnerId ='00G20000001H494'))
                                                6   Portugal_CIC
AND(ISPICKVAL(Country_Code__c , 'PT'), OR( ISPICKVAL( Origin , "Facebook"),ISPICKVAL(Origin, "Twitter") ), NOT( ISBLANK( ContactId ) ), PRIORVALUE( OwnerId ) == '00G20000001hBNs')
                                                7   France_CIC
AND(ISPICKVAL(Country_Code__c , 'FR'), ISPICKVAL(Origin, 'Web'),OR(PRIORVALUE( OwnerId ) == '00G20000001hBNs',OwnerId = '00520000002b4rH'))                                                
                                                8   Same User
NOT(ISBLANK(Country_Code__c ))
                                                
                                                
                                                Case.AssignmentRules no 3 email template used: External Relations Notification to Inf Supervisor
                                                Case.AssignmentRules no 4 email template used: Key Customer Complaint Notification
                                                
                                                They need to be added back after succesful Country Code change from text field to picklist     

    17-PRE  2014-04-11   Krishna Kandula           RENAME                                                                           CIC-1116     TYPE-Pre (Required before Deploy)
                                                 Change Case.Damage_Caused -> Old_Damage_Caused ((Old) Damage Caused)
                                                 It is to avoid the following error message while deploying Cannot change type due to existing data
                                                 Case.Damage_Caused__c field has reference in Case.Insurance__c formula field 
                                                 There is a sub task CIC-1117 to change the formula so that Damage_Caused__c field reference is modified 
                                                 from Check box to picklist type in the Case.Insurance__c formula field.                                                
                                                Here click 'Edit' button and uncheck 'Edit Read Only Fields' permission


    18    2014-04-23            Alexandre Felisberto         Public group 'FR_ECIC_All' created for Sharing rule 'FR_ECIC_Service_Manager_Account_Access'                        CIC-1514
                                                            ALL FR roles should be included in this group. (This Group need to be added to ECIC_All group)

    19-D  2014-04-30        Alexandre Felisberto            OWD for Package__c.object must be set to PRIVATE.                                                                CIC-1549
    
    20    2014-05-01            Iga Chworostowska    New field was added to Country_Specific_Settings__c: Quality_Complaint_Export_Recipient__c
                                                        Description:    Recipient email address of Quality Complaint cases' daily export
                                                        Type:           Email
                                                        This field will be filled in only for FR, but we do not have the recipient address yet.
                                                        Country-Specific_Settings.csv file (/trunk/data/) is updated with new column, but doesn't have a value yet.            CIC-1111
                                                        
    21    2014-05-01            Iga Chworostowska    1. Change Drill Down URL in below Dashboard Components:                                                                        CIC-1533
                                                -    FR_Cases_By_Region.dashboard: 
                                                    “/00O11000000ScWK” should be changed to “Cases By Region" Report ID (saved in “FR CIC Reports” folder)
                                                
                                                -    FR_Cases_Per_Brand.dashboard:
                                                    “/00O11000000Sbu6” should be changed to “QA Complaints Per Brand" Report ID (saved in “FR CIC Reports” folder)
                                                    “/00O11000000Sbuz” should be changed to “Inquiries Per Brand" Report ID (saved in “FR CIC Reports” folder)
                                                    “/00O11000000SbwM” should be changed to “Non-Q Complaints Per Brand" Report ID (saved in “FR CIC Reports” folder)

                                                -    FR_Complaints.dashboard:
                                                    “/00O11000000ScCj” should be changed to “Complaints By Cat. Level 3" Report ID (saved in “FR CIC Reports” folder)
                                                    “/00O11000000ScEL” should be changed to “QA Complaints By Top Plants" Report ID (saved in “FR CIC Reports” folder)
                                                    “/00O11000000ScEf” should be changed to “Analysis - Commercial&Distribution Cases" Report ID (saved in “FR CIC Reports” folder)
                                                    “/00O11000000ScBW” should be changed to “Complaints By Package,POS Key Account" Report ID (saved in “FR CIC Reports” folder)
                                                    “/00O11000000ScFT” should be changed to “Complaints By Case Reason" Report ID (saved in “FR CIC Reports” folder)
                                                    “/00O11000000ScAi” should be changed to “CIC Complaints" Report ID (saved in “FR CIC Reports” folder)
                                                    
                                                -    FR_Fanta_Cases.dashboard:
                                                    “/00O11000000ScRy” should be changed to “Fanta Cases" Report ID (saved in “FR CIC Reports” folder)

                                                -    FR_Inquiries.dashboard:
                                                    “/00O11000000SbXb” should be changed to “Consumer Interests By Category" Report ID (saved in “FR CIC Reports” folder)

                                                -    FR_My_Coke_Cases.dashboard:
                                                    “/00O11000000SboS” should be changed to “Coca-Cola Cases" Report ID (saved in “FR CIC Reports” folder)

                                                -    FR_Powerade_Cases.dashboard:
                                                    “/00O11000000ScVH” should be changed to “Powerade Cases" Report ID (saved in “FR CIC Reports” folder)

                                                -    FR_Promotions.dashboard:
                                                    “/00O11000000SbX2” should be changed to “Promos By Name" Report ID (saved in “FR CIC Reports” folder)
                                                    “/00O11000000SbX7” should be changed to “Promos by Cat3" Report ID (saved in “FR CIC Reports” folder)
                                                    “/00O11000000SbXC” should be changed to “Comparison Promotion Cases" Report ID (saved in “FR CIC Reports” folder)
                                                    “/00O11000000Sc9p” should be changed to “Promos By PoS Key Accounts" Report ID (saved in “FR CIC Reports” folder)

                                                -    FR_Sensitive_Topics.dashboard:
                                                    “/00O11000000ScdB” should be changed to “Health and Nutrition Inquiries" Report ID (saved in “FR CIC Reports” folder)
                                                    “/00O11000000Scdu” should be changed to “Formula – Ingredients Inquiries" Report ID (saved in “FR CIC Reports” folder)

                                                2. Change Running User 
                                                from: celine.moreau@coca-cola.com.sit
                                                to: User with "FR CIC Manager" Role
                                                
                                                in all FR dashboards:
                                                    FR_Cases_Per_Brand
                                                    FR_Cases_By_Product_Type
                                                    FR_Cases_By_Region
                                                    FR_Cases_Opened_In_Last_3_Months
                                                    FR_Complaints
                                                    FR_Fanta_Cases
                                                    FR_Inquiries
                                                    FR_My_Coke_Cases
                                                    FR_Powerade_Cases
                                                    FR_Promotions
                                                    FR_Sensitive_Topics
                                                    FR_TCCC_CIC_Open_and_Overdue_Cases
    22        2014-05-07        Andrey Pshenichnikov                                                            ECIC                CIC-650
                                                     After Deployment:
                                                     
                                                     1)Mapping of FR Roles to data categories in 'Markets' data category group
                                                     
                                                     To establish KB article visibility based on BU/Market,          
                                                     the following mapping of FR roles to categories in the
                                                     'Markets' data category group have to be performed:
                                                     ---------------------------------------------------------------------------------------------------------
                                                     | Role                            | Type                 | Category within 'Markets' category group      |
                                                     ---------------------------------------------------------------------------------------------------------
                                                     | Coca-Cola NWEN                   | Custom              | > Europe > Northwest Europe & Nordic          |                             
                                                     |     Coca-Cola France               | Custom                 | > Europe > Northwest Europe & Nordic > France |
                                                     |         FR CIC Manager          | Inherited from       | Coca-Cola France                              |
                                                     |               FR CIC Supervisor | Inherited from       | Coca-Cola France                              |
                                                     |                   FR CIC Agent   | Inherited from      | Coca-Cola France                                |
                                                     ---------------------------------------------------------------------------------------------------------
                                                    
                                                    2) Assignment to Groups
                                                    To provide KB users with access to KB Reports 
                                                    and to provide Knowledge Managers with all available Article Actions:
                                                    
                                                    - FR CIC Agent users (Knowledge Users) to be added to the 
                                                      'KB - Knowledge Users' group - to get access to KB Knowledge Reports and Dashboards
                                                      
                                                    - FR CIC Supervisors and FR CIC Manager (Knowledge Managers with publishing rights)- to be added to
                                                      the 'KB - Knowledge Publishers' group - to get access to all Knowledge Actions and to KB Management reports
                                                      and Dashboards.
                                                    
                                                    
                                                    3) Assignment of Permission Sets to Users:
                                                    
                                                    To support "external" approval, 'Approved On' and 'Approved By' fields were added to all article types. 
                                                    To provide users with access to these fields on all article types the following permission sets were updated:
                                                    ---------------------------------------------------------------------------------------
                                                    | Permission Set                | Article Type      | Field                 | Access |
                                                    ---------------------------------------------------------------------------------------
                                                    | KB - External Approval - Read | all article types | Approved_By__c        | Read   |
                                                    |                               |                   | Approved_On__c        | Read   |
                                                    ---------------------------------------------------------------------------------------
                                                    | KB - External Approval - Edit | all article types | Approved_By__c        | Edit   |
                                                    |                               |                   | Approved_On__c        | Edit   |
                                                    ---------------------------------------------------------------------------------------

                                                    The following new and existing permission sets should be assigned to FR Users:
                                                    - FR CIC Agent: 
                                                       - 'KB - External Approval - Read',
                                                       - 'KB - All Article Types - Read'
                                                       - 'KB - Permission - ALL Security Levels'
                                                       - 'KB - Use Knowledge App'
                                                       - 'KB - View Articles and Reports tabs'
                                                       
                                                    - Area Managers and Marketing Manager: 
                                                       - 'KB - External Approval - Edit'
                                                       - 'KB - All Article Types - All Actions'
                                                       - 'KB - KB Management - Salesforce License'
                                                       - 'KB - Permission - ALL Security Levels'
                                                       - 'KB - Use Knowledge App'
                                                       - 'KB - View Articles and Reports tabs'
                                                    
                                                    Note: if forms filled in for registration of some users are available, permission sets 
                                                    providing access to 'Permissions' data categories are set based on filled in forms.
                                                    
                                                    4) Knowledge Licences
                                                    Since Winter'14 Salesforce release, Knowledge licences are required for Knowledge Managers only.
                                                    
                                                    5) Knowledge Dashboards
                                                       Some dashboards were not fully setup in previous release or the settings were reset as the result of some deployment.
                                                       The following manual fixes are needed
                                                    
                                                    I.  Running user for the following dashboard is currently wrong, it should be manually set to a user with
                                                        'CSE CIC SM Marketing Manager' role (Sandra Barbir not System Administrator):
                                                            Dashboard folder: CSE CIC KB Dashboards
                                                            Dashboard: Q&A Articles (Dashboard Unique Name: KB_kbFAQ)
                                                    II. The following manual changes are needed to restore the 'Drill Down' property 
                                                        (article titles should be a link following to detail view of the article):
                                                            - Open dashboards in edit mode and for each affected component:
                                                              in Component Editor ->'Component Data' tab: 
                                                              in the 'Drill Down to' drop-down list chose 'Record Detail Page'.
                                                            Affected Dashboards and their components:
                                                                Folder: KB - Knowledge Dashboards
                                                                    Dashboard: Knowledge Articles Overview
                                                                        Component: all components
                                                                    Dashboard: Top Published Articles
                                                                        Component: all components
                                                                Folder: KB - Knowledge Management Dashboards
                                                                    Dashboard: Knowledge Manager Overview
                                                                        Component: Last Modified Article Versions
                                                                    Dashboard: Knowledge Maintenance
                                                                        Component: Last Modified Article Versions
                                                                        Component: Oldest Knowledge Articles (20 Articles based on Last Published Date)
                                                                        Component: Articles with Lowest Score (20 Articles - Calculated from User Votes)
                                                                    Dashboard: Use of Articles in Cases
                                                                        Component: Articles Used in Cases - Publ.This Month
                                                                        Component: Articles Used in Cases - Publ. This Year
                                                                        Component: Articles Used in Cases - All Time
                                                      
    23    2014-05-12            Iga Chworostowska   Report on number of cases and incoming emails and phone calls should be handled as a support request,                CIC-1533
                                                    so we just need SOQL queries.
                                                    User would need an access to DataLoader or Developer Console to run 1st two queries 
                                                    and access to Developer Console to run last two queries (as DataLoader does not support nested queries).
                                                    
                                                    These SOQL queries are saved in svn in …\trunk\data\NWEN\FR\CIC-1533-SOQL report folder 
                                                    
                                                    Number of incoming emails (by Case Record Type):
                                                    SELECT count(id), parent.recordtype.name
                                                    FROM EmailMessage
                                                    WHERE Incoming = true
                                                    AND parent.createddate = Last_Month
                                                    GROUP BY parent.recordtype.name
                                                    HAVING count(id) > 1

                                                    No. of cases with more than 1 incoming email:
                                                    SELECT count(id), parent.recordtype.name,parentid
                                                    FROM EmailMessage
                                                    WHERE Incoming = true
                                                    AND parent.createddate = Last_Month
                                                    GROUP BY parent.recordtype.name,parentid
                                                    HAVING count(id) > 1

                                                    Number of incoming calls (by Case Record Type):
                                                    SELECT count(id), parent.recordtype.name, ( SELECT
                                                    ActivityDate
                                                    ,ActivityType
                                                    ,Description
                                                    ,CreatedBy.Name
                                                    ,Status
                                                    ,WhatId
                                                    FROM ActivityHistories
                                                    WHERE Status = 'Call'
                                                    )
                                                    FROM Case
                                                    WHERE parent.createddate = Last_Month
                                                    GROUP BY parent.recordtype.name
                                                    HAVING count(id) > 1

                                                    No. of cases with more than 1 incoming call:
                                                    SELECT count(id), parent.recordtype.name,parentid, ( SELECT
                                                    ActivityDate
                                                    ,ActivityType
                                                    ,Description
                                                    ,CreatedBy.Name
                                                    ,Status
                                                    ,WhatId
                                                    FROM ActivityHistories
                                                    WHERE ActivityType IN :included_activity_history_types
                                                    AND Status = 'Call'
                                                    )
                                                    FROM Case
                                                    WHERE parent.createddate = Last_Month
                                                    GROUP BY parent.recordtype.name,parentid
                                                    HAVING count(id) > 1
                                                    
    24    2014-05-12            Yury Tyryshkin      Create Scheduled Event to Notify Trend Owner that Open Alert will expire and be deactivated.            CIC-1586
    
                                                    For creating scheduled job choose: Setup->App Setup->Develop->Apex Classes.
                                                    Then click on "Schedule Apex". On appeared configuration page enter job name, then select "ECICOpenAlertExpirationWarningSched" class.
                                                    Set 'Frequency' as weekly, 'Recurs every week on' set every day in week, 'Preferred Start Time' set 7:00 am.

    25  2014-05-13          Gergely Molnar          Enable Enhanced Lookups for 'Beverages' and 'Packages' on /ui/setup/org/SearchSettingsPage (Lookup Settings section)        CIC
    
    26    2014-05-16            Iga Chworostowska   New Custom Setting: Case_Type_To_Record_Type_Dictionary__c, which helps handling bulk Case upserts      CIC-1594
                                                    where the data may have a different language than the current user. 
                                                    Values are saved in ...\trunk\data\Case_Type_To_Record_Type_Dictionary
                                                    
    27    2014-05-20            Alexandre Felisberto    Open_Alert__c email messages not been sent out.

                                                    The following emails cannot be delivered: Object Id=***************; Recipients=(email@test.com); Target Recipient Id=*************;
                                                    
                                                    Make sure that in General Settings id values leads to accessible records such as templates, org-wide email address, etc.
                                                    
                                                    Org-wide email address must have Profile access as /0D220000000Gntq and not as /0D220000000GnpP

    
    28  2014-05-20          Yury Zaranok            New Custom Setting object: Case_Fields_Blacklist__c, was introduced for storing Case object fields (aka 'blackList') (CIC-1608)
                                                    Values are saved in ...\trunk\data\CaseFieldsBlacklist.csv
                                                    
    29    2014-05-27            Iga Chworostowska   2 new scheduled reports:                                                                                CIC-1652

                                                    1. ESC_Daily_Overview_Report_Yesterday:
                                                    Frequency: Daily Every weekday at 14:00 (End time: 01/01/2100)

                                                    2. ESC_Daily_Overview_Report_Today:
                                                    Frequency: Daily Every weekday at 18:00 (End time: 01/01/2100)

                                                    Running User for both of them: Lucy Bailey, email send to Group: NWEN_CCE_QESH
                                                    
    30    2014-05-28           Alexandre Felisberto ECIC_Read-Only Profile.                                                                                        CIC-1650
                                                    Change General and User Permissions to contain only the following:
                                                    Chatter Internal User, 
                                                    Create and Customize List Views, 
                                                    View Help Link,
                                                    Allow View Knowledge 
                                                    Create and Share Links to Chatter Files, Export Reports, 
                                                    Run Reports
                                                    Use Case Feed
                                                    
                                                    Make sure Profile has only read permission to all CIC objects and none to other objects.
                                                   
    31	 2014-06-04			Andrey Pshenichnikov	FR CIC users should be able to send emails from an org-wide email address, so that consumers 					CIC-638
    												can reply to it, and the reply is added as an email to the 'Emails' related list (and not as a new case)
    												To allow this:
    												1. Register the Organization-Wide Email address:
    												   Display Name:	CIC Coca-Cola France (the display name is to be confirmed by the Business)
    												   Email Address:	fr.ciccontact@coca-cola.com
    												2. Verify the address added:
    												   - Check France_CIC queue for a case registered with 'Contact' - Support@Salesforce.Com , and 
    												     'Subject' - "Verify your salesforce.com Organization-Wide Address"
    												   - Click on the verification link in the 'Description' field (if not successfull, Resend the verification request).
                                                    
    32	2014-06-05			Yury Tyryshkin			Delete all non-English list views(except those which are created by the user itself) and also below list views on Case object from prod:							CIC-1611
													Complaints
													Non-Complaints 
													Open Complaints 
													Todos
                                                    
   33   2014-06-1406        Felisberto Alexandre    ../data/translation/<CC>.stf files  translation files as not able to save all in metadata (e.g. data categories).                           CIC - 1644 / 1143                                               
													
													
    34	2014-06-11			Brian Kessler			Schedule ECICCaseExportQualityComplaintsSchedable to run each day at 03:00 am.
    
    35  2014-06-16          Zsolt Pénzes            Replace Campaign Brand picklist values                    
                                                        using the next mappings:
                                                            
                                                            - "1","Classic Coke"
                                                            - "2","Fanta"
                                                            - "3","Nordic Mist"
                                                            - "4","Sprite"
                                                            - "5","Fioravanti"
                                                            - "6","Powerade"
                                                            - "7","Aquarius"
                                                            - "8","Limon&Nada"
                                                            - "9","Minute Maid"
                                                            - "10","Aquabona"
                                                            - "11","Nestea"
                                                            - "12","Burn"
                                                            - "13","Zico"
                                                            - "14","Diet Coke"
                                                            - "15","Coke Zero"
                                                            - "16","Mare Rosso"
                                                            - "17","Schuss"
                                                            - "18","Cherry Coke"
                                                            
	36  2014-06-16          Zsolt Pénzes            Delete number values from Campaign.Brand__c picklist vaules just only after the step "35"
    
    
    37  2014-06-17          Alexandre   Felisberto      delete unused Case.Created_Time__c field                                                                                                         CIC-1726
    
    38  2014-06-25          Yury Zaranok                'Parent Account' field (Account obj) 'FR' translation can't be translated                       CIC-1743
                                                        due to Translation Workbench limitations (TW doesn't support standard fields translation)
                                                        Field should be relabeled on Prod.
*/
 
private class SEPNonMetadataChanges {
}