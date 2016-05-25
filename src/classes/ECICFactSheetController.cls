public with sharing class ECICFactSheetController {

    public static Case parentCase{get; set;}
    public static void setParentCase (Case c) { parentCase=c; } 

    @testVisible private static Map<String, String> qualityCommentsMap = New Map<String, String> {};
    public static Map<String, String> getQualityComments(){ return qualityCommentsMap; }

    @testVisible private static Map<String, String> caseCommentsMap    = New Map<String, String> {};    
    public static Map<String, String> getCaseComments(){ return caseCommentsMap; }
    
/**********************************************************************************************/     

    public static List<String> getQualityAuthors()
    {
        List<Quality_Comment__c> qualityCommentList = [ SELECT createdBy.name, commentBody__c, createdDate FROM Quality_Comment__c WHERE parent_case__c =: parentCase.Id ORDER BY createdDate ASC ];
        return createCommentAuthorKeyList(qualityCommentList, qualityCommentsMap, 'commentBody__c');
    }
    
    /**********************************************************************************************/         
    
    public static List<String> getCaseCommentsAuthors()
    {
        List<CaseComment> caseCommentList = [ SELECT createdBy.name, commentBody, createdDate FROM CaseComment WHERE parentId =: parentCase.Id ORDER BY createdDate ASC ];                                               
        return createCommentAuthorKeyList(caseCommentList, caseCommentsMap, 'commentBody');
    }
    
    /**********************************************************************************************/         
    
    @testVisible private static List<String> createCommentAuthorKeyList(List<SObject> sObjectCommentList, Map<String, String> commentMap, String bodyFieldName)
    {
        List<String> commentAuthorList = new List<String>();
        for(SObject currComment :sObjectCommentList)
        {
            String commentDateTime = (((Datetime) currComment.get('createdDate')).format('yyyy-MM-dd HH:mm:ss z'));
            String commentCreator  = String.valueOf(currComment.getSObject('createdBy').get('name'));
            
            String authorKey       = commentDateTime + ' ' + commentCreator;                                          
            commentAuthorList.add(authorKey);
            commentMap.put(authorKey, (String) currComment.get(bodyFieldName));
        }
        return commentAuthorList;
    }
        }