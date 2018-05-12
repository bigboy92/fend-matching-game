let card = document.getElementsByClassName("card");
const restart = document.getElementsByClassName(`fa-repeat`);
const container = document.querySelector('.container');
let cards = [...card];
let open = [];
let moves = 0;
let matchedCard = document.getElementsByClassName("match");
let interval;
let counter = document.querySelector(".moves");
let timer = document.querySelector(".timer");
let minutes = document.querySelector('.minutes');
let seconds = document.querySelector('.seconds');


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
    shuffledCards[i].classList.remove("open", "match", "locked");
   }
   container.removeChild(deck);
   container.appendChild(newDeck);
}   
window.onload = reset();
restart[0].addEventListener('click', reset);
function reset() {
  newDeck();
  open = [];
  moves = 0;
  counter.textContent = "0";
  document.querySelector('.stars').innerHTML = '<li><i class="fa fa-star"></i></li><li><i class="fa fa-star"></i></li><li><i class="fa fa-star"></i></li>';
  //Timer
  minutes.textContent = '00';
  seconds.textContent = '00';
  time = 0;
  clearInterval(interval);
}

//function for adding cards to open array and comparing them
function openAdd(){
  open.push(this);
  if(open.length === 2){
    movesCounter();
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
        for (var i = 0; i < matchedCard.length; i++){
          matchedCard[i].classList.add("locked");
        }
      });
      open = [];
    },1100);

    }  
  }
}

function movesCounter(){
  let counter = document.querySelector(".moves");
  let step = 12;
  moves += 1;
  counter.textContent = moves;
  if (moves % step === 0 && moves < step*3){
    document.querySelector(".stars").children[0].remove();
  }
  if (moves === 1){
    startTimer();
    interval = window.setInterval(startTimer, 1000);
  }
}


var time = 0;
function startTimer() {
  time += 1;
  if (time < 3600) {
    minutes.textContent = Math.floor(time / 60) > 9 ? Math.floor(time / 60) : '0' + Math.floor(time / 60);
    seconds.textContent = time % 60 > 9 ? time % 60 : '0' + time % 60;
  } else {
    reset();
  }
}

function winner(){
  if (matchedCard.length > 15){
    clearInterval(interval);
    finalTime = minutes.textContent + ':' + seconds.textContent;

    // show congratulations modal
    modal.classList.add("show");

    // declare star rating variable
    let starRating = document.querySelector(".stars").innerHTML;
    //showing move, rating, time on modal
    document.getElementById("finalMove").innerHTML = moves;
    document.getElementById("starRating").innerHTML = starRating;
    document.getElementById("totalTime").innerHTML = finalTime;
  };
}

function playAgain(){
    modal.classList.remove("show");
    reset();
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
