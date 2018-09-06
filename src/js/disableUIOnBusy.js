function shouldShow() {
    return $("html").hasClass("shiny-busy");
}

function showBusyIndicator() {
    if (shouldShow()) {
        $(".busy-indicator").fadeIn()
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