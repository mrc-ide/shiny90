function shouldShow() {
    return $("html").hasClass("shiny-busy");
}

function showModal(){
    return $('#shiny-notification-panel').length == 0;
}

function showBusyIndicator() {
    if (shouldShow()) {
        $(".busy-indicator").fadeIn()

        if(!showModal()) {
            $('.modal-dialog').hide()
        }
    }
}

function updateBusyIndicator() {
    if (shouldShow()) {
        setTimeout(showBusyIndicator, 250);
    } else {
        $(".busy-indicator").hide();
    }
}

setInterval(updateBusyIndicator, 50);