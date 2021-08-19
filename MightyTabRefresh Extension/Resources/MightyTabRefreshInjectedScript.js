function mightyLog(message) {
    console.log("Mighty Tab Refresh: " + message);
}

function handleMessage(event) {
    mightyLog(event.name);
    mightyLog(event.message);
}

document.addEventListener("DOMContentLoaded", function(event) {
    safari.self.addEventListener("message", handleMessage);    
    safari.extension.dispatchMessage("com.kukushechkin.MightyTabRefresh.scriptBecameAvailable", {});
});
