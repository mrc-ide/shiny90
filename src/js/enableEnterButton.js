// Shiny doesn't really place nicely with forms and submit buttons,
// so this is a way of getting the enter button to work to trigger an actionButton.
// Place the `data-proxy-click="BUTTON_ID"` attribute on a form element, and then
// when the user presses enter with that element focused the button will get clicked.
$(function() {
    $("input[data-proxy-click]").each(function(idx, el) {
        var element = $(el);
        var proxy = $("#" + element.data("proxyClick"));
        element.keydown(function (e) {
            if (e.keyCode === 13) {
                proxy.click();
            }
        });
    });
});