/**
 * @author Pavel Slepenkov (Pavel_Slepenkov@epam.com)
 * @date 9 Feb 2013
 * @description		The library of common JS function for SEP projects.
 * 				 	The library was created base on such js library for tccc-stm project
 * */

//-------------------------------------Browser Utils -------------------------------------------------------------------
/**
 * @return IE version as int. for other browsers == "undefined"
 */
function checkIEVersion() {
    var undef, v = 3, div = document.createElement('div'), all = div.getElementsByTagName('i');
    while (div.innerHTML = '<!--[if gt IE ' + (++v) + ']><i></i><![endif]-->', all[0]);
    return v > 4 ? v : undef;
};

/**
 * @param {Object} obj - any JS object which will be logged
 */
var logObj = function(obj) {
    var str = "";
    for (k in obj) {
        if (obj.hasOwnProperty(k)) {
            str += k + ": " + obj[k] + "\n";
        }
    }
    if (checkIEVersion() === 8 || checkIEVersion() === 7) {// IE version below than 9 isn't support console object
        console.log(str);
    } else {
        alert(str);
    }
};

var alertObj = function(obj) {
    var str = "";
    for (k in obj) {
        if (obj.hasOwnProperty(k)) {
            str += k + ": " + obj[k] + "\n";
        }
    }
    alert(str);
};

//----------------------------------------------------------------------------------------------------------------------

function objLength(obj) {
    var counter = 0;
    for (var k in obj ) {
        if (obj.hasOwnProperty(k)) {
            counter++;
        }
    }
    return counter;
}

/**
 * @description select all checkboxes on a page, run by onClick event from a header checkbox.
 * @requires jQuery
 */
function selectAll() {
    if ($j(':checkbox').size() - 1 == $j(':checkbox:checked').size()) {
        $j(':checkbox').attr('checked', false);
    } else {
        $j(':checkbox').attr('checked', true);
    }
};

/**
 * @description save selection from page with pagination to global variable
 * @requires jQuery
 */
function saveSelection() {
    selectedIds = contactIds.join('');
    $j(':checkbox').each(function() {
        if (this.checked == true) {
            if (selectedIds.indexOf(this.id) == -1) {
                contactIds.push(this.id);
                selectedIds = selectedIds + this.id;
            }
        } else {
            if (selectedIds.indexOf(this.id) != -1) {
                for ( i = 0; i < contactIds.length; i++) {
                    if (contactIds[i] == this.id) {
                        contactIds.splice(i, 1);
                        selectedIds = contactIds.join('');
                    }
                }
            }
        }
    });
};

/**
 * @description restore selection for page with pagination
 * @requires jQuery
 */
function restoreSelection() {
    contIds = contactIds.join('');
    i = 0;
    $j(':checkbox').each(function() {
        if (this.id != '') {
            if (contIds.indexOf(this.id) != -1) {
                this.checked = true;
            };
            console.log(i++);
        }
    });

};