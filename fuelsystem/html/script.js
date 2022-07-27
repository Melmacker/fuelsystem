var documentWidth = document.documentElement.clientWidth;
var documentHeight = document.documentElement.clientHeight;

var cursor = document.getElementById("cursor");
var cursorX = documentWidth / 2;
var cursorY = documentHeight / 2;

function UpdateCursorPos() {
    cursor.style.left = cursorX;
    cursor.style.top = cursorY;
}

function Click(x, y) {
    var element = $(document.elementFromPoint(x, y));
    element.focus().click();
}

$(function() {
    window.addEventListener('message', function(event) {
        if (event.data.type == "enableui") {
            cursor.style.display = event.data.enable ? "block" : "none";
            document.body.style.display = event.data.enable ? "block" : "none";
            document.getElementById("bar").style.height='0%';
            document.getElementById("petrolbutton").style.background='transparent';
            document.getElementById("dieselbutton").style.background='transparent';
            document.getElementById("cardbutton").style.background='rgba(0, 0, 0, 0.2)';
            document.getElementById("walletbutton").style.background='transparent';
        } else if (event.data.type == "click") {
            Click(cursorX - 1, cursorY - 1);
        } else if (event.data.type == "progress") {
            document.getElementById("bar").style.height=event.data.data + '%';
        }
    });

    $(document).mousemove(function(event) {
        cursorX = event.pageX;
        cursorY = event.pageY;
        UpdateCursorPos();
    });

    document.onkeyup = function (data) {
        if (data.which == 27) {
            $.post('https://fuelsystem/escape', JSON.stringify({}));
        }
    };

    $("#petrolbutton").click(function(e) {
        e.preventDefault();
        $.post('https://fuelsystem/petrolbutton', JSON.stringify({}));
        if (window.getComputedStyle(document.getElementById("petrolbutton")).backgroundColor == 'rgba(0, 0, 0, 0.2)'){
            document.getElementById("petrolbutton").style.background='transparent';
        } else {
            document.getElementById("petrolbutton").style.background='rgba(0, 0, 0, 0.2)';
        }
        if (window.getComputedStyle(document.getElementById("dieselbutton")).backgroundColor == 'rgba(0, 0, 0, 0.2)'){
            document.getElementById("dieselbutton").style.background='transparent';
        }
    });

    $("#dieselbutton").click(function(e) {
        e.preventDefault();
        $.post('https://fuelsystem/dieselbutton', JSON.stringify({}));
        if (window.getComputedStyle(document.getElementById("dieselbutton")).backgroundColor == 'rgba(0, 0, 0, 0.2)'){
            document.getElementById("dieselbutton").style.background='transparent';
        } else {
            document.getElementById("dieselbutton").style.background='rgba(0, 0, 0, 0.2)';
        }
        if (window.getComputedStyle(document.getElementById("petrolbutton")).backgroundColor == 'rgba(0, 0, 0, 0.2)'){
            document.getElementById("petrolbutton").style.background='transparent';
        }
    });

    $("#cardbutton").click(function(e) {
        e.preventDefault();
        $.post('https://fuelsystem/cardbutton', JSON.stringify({}));
        document.getElementById("cardbutton").style.background='rgba(0, 0, 0, 0.2)';
        document.getElementById("walletbutton").style.background='transparent';
    });

    $("#walletbutton").click(function(e) {
        e.preventDefault();
        $.post('https://fuelsystem/walletbutton', JSON.stringify({}));
        document.getElementById("walletbutton").style.background='rgba(0, 0, 0, 0.2)';
        document.getElementById("cardbutton").style.background='transparent';
    });

    $("#kanisterbutton").click(function(e) {
        e.preventDefault();
        $.post('https://fuelsystem/kanisterbutton', JSON.stringify({}));
    });

    $("#fuelbutton").click(function(e) {
        e.preventDefault();
        $.post('https://fuelsystem/fuelbutton', JSON.stringify({}));
    });
});