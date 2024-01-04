(function() {
    function updateVisibilityState() {
        if(document.hidden) {
            safari.extension.dispatchMessage("com.kukushechkin.MightyTabRefresh.scriptPageBecameInactive", {
                url: window.location.href
            });
        }
        else {
            safari.extension.dispatchMessage("com.kukushechkin.MightyTabRefresh.scriptPageBecameActive", {
                url: window.location.href
            });
        }
    }

    document.addEventListener("DOMContentLoaded", function(event) {
        document.addEventListener("visibilitychange", function() {
            updateVisibilityState();
        });
        updateVisibilityState();

        window.addEventListener("beforeunload", function(e) {
            safari.extension.dispatchMessage("com.kukushechkin.MightyTabRefresh.scriptPageWillUnload", {
                url: window.location.href
            });
        });
    });
}());
