shinyjs.disableTab = function(name) {
    var tab = $('.nav li a[data-value="' + name[0] + '"]');
    tab.bind('click.tab', function(e) {
        e.preventDefault();
        return false;
    });
    tab.addClass('disabled');
};

shinyjs.enableTab = function(name) {
    var tab = $('.nav li a[data-value="' + name[0] + '"]');
    tab.unbind('click.tab');
    tab.removeClass('disabled');
};