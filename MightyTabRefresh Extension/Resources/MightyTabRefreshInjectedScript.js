(function() {
    function mightyLog(message) {
        console.log("Mighty Tab Refresh: " + message);
    }

    function handleMessage(event) {
        mightyLog(event.name);
        mightyLog(event.message);
    }

    // https://gist.github.com/jed/982883
    function uuidv4() {
      return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
        (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
      );
    }
    
    function updateVisibilityState() {
        if(document.hidden) {
            safari.extension.dispatchMessage("com.kukushechkin.MightyTabRefresh.scriptPageBecameInactive", { "uuid": pageUuid });
        }
        else {
            safari.extension.dispatchMessage("com.kukushechkin.MightyTabRefresh.scriptPageBecameActive", { "uuid": pageUuid });
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////
    
    const pageUuid = uuidv4();
    document.addEventListener("DOMContentLoaded", function(event) {
        safari.self.addEventListener("message", handleMessage);
        safari.extension.dispatchMessage("com.kukushechkin.MightyTabRefresh.scriptPageLoaded", { "uuid": pageUuid });
        
        document.addEventListener('visibilitychange', function() {
            updateVisibilityState();
        });
        updateVisibilityState();
        
        window.addEventListener("beforeunload", function(e) {
            safari.extension.dispatchMessage("com.kukushechkin.MightyTabRefresh.scriptPageWillUnload", { "uuid": pageUuid });
        }, false);
    });
})();
