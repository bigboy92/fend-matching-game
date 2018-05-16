let card = document.getElementsByClassName("card");
const restart = document.getElementsByClassName(`fa-repeat`);
const container = document.querySelector('.container');
let cards = [...card];
let open = [];
let moves = 0;
let matchedCard = document.getElementsByClassName("match");
let matched = 8;
let interval, star;
let counter = document.querySelector(".moves");
let timer = document.querySelector(".timer");
let minutes = document.querySelector('.minutes');
let seconds = document.querySelector('.seconds');
let winContainer = document.querySelector('.win');
let stars = document.querySelectorAll(".fa-star");

// function for adding eventlistener if a card is clicked
let clicked = function (){
   this.classList.toggle("open");
   this.classList.toggle("locked");
   openAdd.call(this);
};

for (let i = 0; i < cards.length; i++){
   cards[i].addEventListener("click", clicked);
};

//this function randomly shuffles the content of an array
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
      matched -= 1;
      if (!matched){
        winner();
      }
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

//function for creating moves and setting stars ratings
function movesCounter(){
  let counter = document.querySelector(".moves");
  let step = 12;
  moves += 1;
  counter.textContent = moves;
  if (moves % step === 0 && moves < step*3){
    document.querySelector(".stars").children[0].remove();
  }
  if (moves < 12){
    star = 3
  }else if ( moves == 12 || moves < 24){
    star = 2

  }else{
    star = 1
  } 

  if (moves === 1){
    startTimer();
    interval = window.setInterval(startTimer, 1000);
  }
}

//function to start the game timer
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

// function to display congratultions modal when winning conditions are met
function winner(){
  if (matchedCard.length === 16){
    clearInterval(interval);
    let movesSpan = winContainer.querySelector('.moves');
    let starsSpan = winContainer.querySelector('.stars');
    let scorePanelTime = document.querySelector('.timer');
    let timeSpan = winContainer.querySelector('.time');

    movesSpan.textContent = moves;
    starsSpan.textContent = star;
    timeSpan.textContent = minutes.textContent +':'+ seconds.textContent

    container.classList.add('hidden');
    winContainer.classList.remove('hidden');
  }
  replay();
}

//function to close congratulations modal and replay
function replay(){
  let playAgain = document.querySelector(".playAgain");
  playAgain.addEventListener('click', function(){
    container.classList.remove('hidden');
    winContainer.classList.add('hidden');
    reset();  
  });
}

//function to reset all the game parameters to default
document.body.onload = reset(); 
restart[0].addEventListener('click', reset);
function reset() {
  clearInterval(interval);
  open = [];
  moves = 0;
  counter.textContent = "0";
  document.querySelector('.stars').innerHTML = '<li><i class="fa fa-star"></i></li><li><i class="fa fa-star"></i></li><li><i class="fa fa-star"></i></li>';
  minutes.textContent = '00';
  seconds.textContent = '00';
  time = 0;
  starCount = 0;
  matched = 8;
  newDeck();
}
