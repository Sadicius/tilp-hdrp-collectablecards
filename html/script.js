let cardcollactable = 'card_cigcard_amer_c12';

const cardStates = [false, false, false, false];
const cardSelectors = ['.card', '.card2', '.card3', '.card4'];
const imageIds = ['myImg', 'myImg2', 'myImg3', 'myImg4'];

document.onkeyup = function (data) {
    if (data.which == 27) {
        $.post(`https://tilp-hdrp-collectablecards/CloseNui`)
        setTimeout(() => { $('.cards').css("display", "none"); }, 2000);
        $('.cards').animate({"top": "100%"}, 450)

        cardStates.forEach((isFlipped, index) => {
            if (isFlipped) {
                const card = document.querySelector(cardSelectors[index]);
                card.classList.toggle('is-flipped');
                cardStates[index] = false;
            }
        });
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


function handleCardClick(cardIndex) {
    return function(e) {
        e.preventDefault();
        const card = document.querySelector(cardSelectors[cardIndex]);
        if (!cardStates[cardIndex]) {
            card.classList.toggle('is-flipped');
            $.post(`https://tilp-hdrp-collectablecards/randomCardCollectable`);

            setTimeout(() => {
                document.getElementById(imageIds[cardIndex]).src = "img/" + cardcollactable + ".png";
                $.post(`https://tilp-hdrp-collectablecards/RewardCollectable`, JSON.stringify({
                    Collectable: cardcollactable,
                }));
            }, 200);

            cardStates[cardIndex] = true;
        }
    };
}

cardSelectors.forEach((selector, index) => {
    $(document).on('click', selector, handleCardClick(index));
});