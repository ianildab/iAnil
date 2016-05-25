/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : May 28, 2013
* Description : A custom controller class for Approved External Messaging related email templates
*
* REVISION HISTORY
*
* Author,email :
* Date Revised :
* Description :
*
*
* FOR HUB 1.2
*/
public abstract class HUB_KAVFPageEmailController1
 {


    public HUB_Approved_External_Messaging__kav  relatedTo{ get;set;}
    private String kaChannels = null;
    public HUB_Approved_External_Messaging__kav  ka = null;
    boolean categoryFetched = false;
    
    Map<String, List<String>> categories = new Map<String, List<String>>();    
        
    private HUB_Approved_External_Messaging__kav article {
        get {return getArticle();}
    }
    
    private HUB_Approved_External_Messaging__kav getArticle() {
        if (this.ka == null) {
            if (this.relatedTo == null) {
                try {
                    this.ka = [SELECT id,title,summary, (Select DataCategoryGroupName, toLabel(DataCategoryName) From DataCategorySelections) FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus = 'Online' AND Language = 'en_US' LIMIT 1];
                } catch (Exception ex) {}
                
                if (this.ka == null) {
                    try {
                        this.ka = [SELECT id,title,summary, (Select DataCategoryGroupName, toLabel(DataCategoryName) From DataCategorySelections) FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus = 'Draft' AND Language = 'en_US' LIMIT 1];
                    } catch (Exception ex) {}
                }
                
                if (this.ka == null) {
                    try {
                        this.ka = [SELECT id,title,summary, (Select DataCategoryGroupName, toLabel(DataCategoryName) From DataCategorySelections) FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus = 'Archived' AND Language = 'en_US' LIMIT 1];
                    } catch (Exception ex) {}
                }                        
            } else {
                String id = relatedTo.id;
                try {
                    this.ka = [SELECT id,title,summary, (Select DataCategoryGroupName, toLabel(DataCategoryName) From DataCategorySelections) FROM HUB_Approved_External_Messaging__kav WHERE id=:id AND PublishStatus = 'Online' AND Language = 'en_US'];
                } catch (Exception ex) {}                
                
                if (this.ka == null) {
                    try {
                        this.ka = [SELECT id,title,summary, (Select DataCategoryGroupName, toLabel(DataCategoryName) From DataCategorySelections) FROM HUB_Approved_External_Messaging__kav WHERE id=:id AND PublishStatus = 'Draft' AND Language = 'en_US'];
                    } catch (Exception ex) {}                                
                }
                
                if (this.ka == null) {
                    try {
                        this.ka = [SELECT id,title,summary, (Select DataCategoryGroupName, toLabel(DataCategoryName) From DataCategorySelections) FROM HUB_Approved_External_Messaging__kav WHERE id=:id AND PublishStatus = 'Archived' AND Language = 'en_US'];
                    } catch (Exception ex) {}                                
                }                
            }
        }
        
        return this.ka;
    }
    
    public String getTitle() {
        String title = '';
        if (this.article!= null) {
            title = article.Title;
        }
        
        return title;
    }
    
    public String getSummary() {
        String summary = '';
        if (this.article!= null) {
           summary = article.summary;
        }
        
        return summary;
    }    
    
    public String Channels {
        get {return this.getCategory('Channel');}
        private set{}
    } 
    
    public String ContentOrigins {
        get {return this.getCategory('HUB_Content_Origin');}
        private set{}       
    }
    
    public String Issues {
        get {return this.getCategory('HUB_Issue');}
        private set{}       
    }    
    
    private String getCategory(String cat) {
        String tmp = '';        
        this.getCategories();           
        if (categoryFetched) {
            if ( categories.containsKey(cat)) {
                tmp = String.join(categories.get(cat),', ');
            }
        }
        
        return tmp;
    } 
    private void getCategories() {
        if (this.article == null) {
            return;
        }
        if (!categoryFetched) {
            String kaid = this.article.id;
            
            HUB_Approved_External_Messaging__kav knowledge = null;
            try {
                knowledge = [SELECT id,title, (Select DataCategoryGroupName, toLabel(DataCategoryName) From DataCategorySelections) FROM HUB_Approved_External_Messaging__kav WHERE id=:kaid AND PublishStatus = 'Draft' AND Language = 'en_US'];
            } catch (Exception ex) {}
            
            if (knowledge == null) {
                try {
                    knowledge = [SELECT id,title, (Select DataCategoryGroupName, toLabel(DataCategoryName) From DataCategorySelections) FROM HUB_Approved_External_Messaging__kav WHERE id=:kaid AND PublishStatus = 'Online' AND Language = 'en_US'];
                } catch (Exception ex) {}            
            }
            
            if (knowledge == null) {
                try {
                    knowledge = [SELECT id,title, (Select DataCategoryGroupName, toLabel(DataCategoryName) From DataCategorySelections) FROM HUB_Approved_External_Messaging__kav WHERE id=:kaid AND PublishStatus = 'Archived' AND Language = 'en_US'];
                } catch (Exception ex) {}            
            }            
            
            if (knowledge != null) {            
                for (HUB_Approved_External_Messaging__DataCategorySelection cat : ka.DataCategorySelections) {
                    String grp = cat.DataCategoryGroupName;
                    List<String> catList;
                    if (this.categories.containsKey(grp)) {
                        catList = this.categories.get(grp);
                    } else {
                        catList = new List<String>();
                    }                    
                    catList.add(cat.DataCategoryName);
                    this.categories.put(cat.DataCategoryGroupName,catList);
                    categoryFetched = true;                 
                }
            }
        }                        
    }
    

}