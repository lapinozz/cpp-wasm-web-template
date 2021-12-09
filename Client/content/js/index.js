import '../wasm/client.wasm.wasm';
import '../debug/client.wasm.wasm.map';
import ClientModule from '../wasm/client.wasm.js';

let lastModified = null;

function getLastModified()
{
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open( "GET", "/last-modified");
    xmlHttp.send(null);
	xmlHttp.onreadystatechange = function()
	{
	    if (xmlHttp.readyState == 4)
    	{
    		if(!lastModified)
    		{
    			lastModified = xmlHttp.responseText;
    		}
    		else if(lastModified != xmlHttp.responseText)
    		{
    			window.location.reload();
    		}
    	}
	}
}
console.log('blahfwa')

//setInterval(getLastModified, 1000); 

window.ClientModule = ClientModule

new ClientModule().then(module => {

    window.Client = module;

    console.log(Client.getStr('test'));
});