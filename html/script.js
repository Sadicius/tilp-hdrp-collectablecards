let cardcollactable = 'card_cigcard_amer_c12';

let flippedcardollactable1 = false;
let flippedcardollactable2 = false;
let flippedcardollactable3 = false;
let flippedcardollactable4 = false;

document.onkeyup = function (data) {
    if (data.which == 27) {
        $.post(`https://tilp-hdrp-collectablecards/CloseNui`)
        setTimeout(() => { $('.cards').css("display", "none"); }, 2000);
        $('.cards').animate({"top": "100%"}, 450)

        if (flippedcardollactable1 === true) {
            var card = document.querySelector('.card');
            card.classList.toggle('is-flipped');
            flippedcardollactable1 = false
        }
        if (flippedcardollactable2 === true) {
            var card = document.querySelector('.card2');
            card.classList.toggle('is-flipped');
            flippedcardollactable2 = false
        }

        if (flippedcardollactable3 === true) {
            var card = document.querySelector('.card3');
            card.classList.toggle('is-flipped');
            flippedcardollactable3 = false
        }

        if (flippedcardollactable4 === true) {
            var card = document.querySelector('.card4');
            card.classList.toggle('is-flipped');
            flippedcardollactable4 = false
        }
    }
};

addEventListener("message", function(event){
    let item = event.data;

    if(item.open == true) {
        if (item.class == "open") {
            $('.cards').css("display", "block");
            $('.cards').animate({"top": "30%"}, 450)
        } 
        if (item.class == "choose") {
            cardcollactable = item.data   
        } 
    }
});


$(document).on('click', '.card', function(e){
    e.preventDefault();
    var card = document.querySelector('.card');
    if (flippedcardollactable1 === false) {
        card.classList.toggle('is-flipped');
        $.post(`https://tilp-hdrp-collectablecards/randomCardCollectable`);

        setTimeout(() => { 
            document.getElementById("myImg").src = "img/" + cardcollactable + ".png";
            $.post(`https://tilp-hdrp-collectablecards/RewardCollectable`, JSON.stringify({
                Collectable: cardcollactable,
            }))
        }, 200);

        flippedcardollactable1 = true
    }
});

$(document).on('click', '.card2', function(e){
    e.preventDefault();
    var card = document.querySelector('.card2');
    if (flippedcardollactable2 === false) {
        card.classList.toggle('is-flipped');
        $.post(`https://tilp-hdrp-collectablecards/randomCardCollectable`);

        setTimeout(() => {
            document.getElementById("myImg2").src = "img/" + cardcollactable + ".png";
            $.post(`https://tilp-hdrp-collectablecards/RewardCollectable`, JSON.stringify({
                Collectable: cardcollactable,
            }))
        }, 200);

    
        flippedcardollactable2 = true
    }
});

$(document).on('click', '.card3', function(e){
    e.preventDefault();
    var card = document.querySelector('.card3');
    if (flippedcardollactable3 === false) {
        card.classList.toggle('is-flipped');
        $.post(`https://tilp-hdrp-collectablecards/randomCardCollectable`);

        setTimeout(() => {
            document.getElementById("myImg3").src = "img/" + cardcollactable + ".png";
            $.post(`https://tilp-hdrp-collectablecards/RewardCollectable`, JSON.stringify({
                Collectable: cardcollactable,
            }))
        }, 200);

        
        flippedcardollactable3 = true
    }
});

$(document).on('click', '.card4', function(e){
    e.preventDefault();
    var card = document.querySelector('.card4');
    if (flippedcardollactable4 === false) {
        card.classList.toggle('is-flipped');
        $.post(`https://tilp-hdrp-collectablecards/randomCardCollectable`);

        setTimeout(() => {
            document.getElementById("myImg4").src = "img/" + cardcollactable + ".png";
            $.post(`https://tilp-hdrp-collectablecards/RewardCollectable`, JSON.stringify({
                Collectable: cardcollactable,
            }))
        }, 200);

        
        flippedcardollactable4 = true
    }
});