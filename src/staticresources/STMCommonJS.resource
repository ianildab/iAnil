/*
 * The library of common JS function for TCCC-STM2 project
 */

var logObj = function(obj) { 
	var str = ""; 
	for(k in obj) { 
		str += k+": "+ obj[k]+"\n"; 
	} 
	console.log(str); 
}; 
        
var alertObj = function(obj) {
	var str = "";
	for (k in obj) {
		str += k+": "+obj[k]+"\n";
	}
	alert(str);
};

function selectAll(){
    if($j(':checkbox').size()-1 == $j(':checkbox:checked').size()) {
       $j(':checkbox').attr('checked', false)
    } else {
       $j(':checkbox').attr('checked', true)
    }
};

function saveSelection() {
    selectedIds = contactIds.join('');
    $j(':checkbox').each(function(){
        if (this.checked == true) {
            if (selectedIds.indexOf(this.id) == -1) {
                contactIds.push(this.id);
                selectedIds = selectedIds + this.id;
            }
        } else {
            if (selectedIds.indexOf(this.id) != -1) {
                for (i=0; i < contactIds.length; i++) {
                    if (contactIds[i] == this.id) {
                        contactIds.splice(i, 1);
                        selectedIds = contactIds.join('');
                    }
                }
            }
        }                      
    });
};

function restoreSelection() {
    contIds = contactIds.join('');
    i = 0;
    $j(':checkbox').each(function(){ if(this.id != ''){  if(contIds.indexOf(this.id) != -1){this.checked=true;};console.log(i++); }});
    
};

function checkIEVersion(){
    var undef,
        v = 3,
        div = document.createElement('div'),
        all = div.getElementsByTagName('i');
    while (
        div.innerHTML = '<!--[if gt IE ' + (++v) + ']><i></i><![endif]-->',
        all[0]
    );
    return v > 4 ? v : undef;
};