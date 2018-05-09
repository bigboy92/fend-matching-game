let card = document.getElementsByClassName("card");
const restart = document.getElementsByClassName(`fa-repeat`);
const container = document.querySelector('.container');
let cards = [...card];
let open = [];
let matchedCard = document.getElementsByClassName("match");
let moves = 0;
let counter = document.querySelector(".moves");

// function for adding eventlistener if a card is clicked
let clicked = function (){
   this.classList.toggle("open");
   this.classList.toggle("locked");
   openAdd.call(this);
};

for (let i = 0; i < cards.length; i++){
   cards[i].addEventListener("click", clicked);
};


function shuffle(array) {
    var currentIndex = array.length, temporaryValue, randomIndex;

    while (currentIndex !== 0) {
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex -= 1;
        temporaryValue = array[currentIndex];
        array[currentIndex] = array[randomIndex];
        array[randomIndex] = temporaryValue;
    }

    return array;
};
//function to create new deck of shuffled cards
function newDeck(){
  let deck = document.querySelector(".deck");
  const newDeck = document.createElement('ul');
  newDeck.className = 'deck';
  let shuffledCards = shuffle(cards);
  for (let i= 0; i < shuffledCards.length; i++){
    newDeck.appendChild(shuffledCards[i]);
   }
   container.removeChild(deck);
   container.appendChild(newDeck);
}   
window.onload = reset();
restart[0].addEventListener('click', reset);
function reset() {
  newDeck();
  open = [];
  counter = 0
}

//function for adding cards to open array and comparing them
function openAdd(){
  open.push(this);
  if(open.length === 2){
    counterMove();
    if (open[0].type === open[1].type){
      open[0].classList.add("match",'locked');
      open[1].classList.add("match", "locked");
      open[0].classList.remove('open');
      open[1].classList.remove('open');
      open = [];
    }
    else{
    open[0].classList.add("shake");
    open[1].classList.add("shake");
    Array.prototype.filter.call(cards, function(card){
      card.classList.add('locked');
    });
    setTimeout(function(){
      open[0].classList.remove("open","shake");
      open[1].classList.remove("open","shake");
      Array.prototype.filter.call(cards, function(card){
        card.classList.remove('locked');
        for(var i = 0; i < matchedCard.length; i++){
          matchedCard[i].classList.add("locked");
        }
      });
      open = [];
    },1100);

    }  
  }
}

function counterMove(){
  moves += 1;
  counter.innerHTML = moves;
}
/*
 * set up the event listener for a card. If a card is clicked:
 *  - display the card's symbol (put this functionality in another function that you call from this one)
 *  - add the card to a *list* of "open" cards (put this functionality in another function that you call from this one)
 *  - if the list already has another card, check to see if the two cards match
 *    + if the cards do match, lock the cards in the open position (put this functionality in another function that you call from this one)
 *    + if the cards do not match, remove the cards from the list and hide the card's symbol (put this functionality in another function that you call from this one)
 *    + increment the move counter and display it on the page (put this functionality in another function that you call from this one)
 *    + if all cards have matched, display a message with the final score (put this functionality in another function that you call from this one)
 */
