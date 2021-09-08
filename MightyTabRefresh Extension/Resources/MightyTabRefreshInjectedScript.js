(function() {
    function updateVisibilityState() {
        if(document.hidden) {
            safari.extension.dispatchMessage("com.kukushechkin.MightyTabRefresh.scriptPageBecameInactive", { });
        }
        else {
            safari.extension.dispatchMessage("com.kukushechkin.MightyTabRefresh.scriptPageBecameActive", { });
        }
    }

    document.addEventListener("DOMContentLoaded", function(event) {
        document.addEventListener("visibilitychange", function() {
            updateVisibilityState();
        });
        updateVisibilityState();

        window.addEventListener("beforeunload", function(e) {
            safari.extension.dispatchMessage("com.kukushechkin.MightyTabRefresh.scriptPageWillUnload", { });
        }, false);
    });
}());
