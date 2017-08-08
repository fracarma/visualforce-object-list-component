var disableButton = function(btn){
	console.log("btn", btn);
    if(!btn){
    	return true;
    }
    btn.className = 'btnDisabled'; 
    btn.disabled = false;
    return true;
}

var enableButton = function(btn){
	console.log("btn", btn);
    if(!btn){
    	return true;
    }
    btn.className = 'btn'; 
    btn.disabled = true;
    return true;
}

var disableButtons = function(className){
    var btn = document.getElementsByClassName(className);
    if(btn){
        for (var i = 0; i < btn.length; i++) {
            console.log(btn[i]);
            btn[i].className = className + ' btnDisabled'; 
            btn[i].disabled = true;
        }
    }
    return true;
}

var enableButtons = function(className){
    var btn = document.getElementsByClassName(className);
    if(btn){
        for (var i = 0; i < btn.length; i++) {
            console.log(btn[i]);
            btn[i].className = className + ' btn'; 
            btn[i].disabled = false;
        }
    }
    return true;
}