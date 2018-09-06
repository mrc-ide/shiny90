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
        setTimeout(showBusyIndicator, 500);
    } else {
        $(".busy-indicator").hide();
    }
}

setInterval(updateBusyIndicator, 100);