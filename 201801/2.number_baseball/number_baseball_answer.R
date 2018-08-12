rm(list=ls())

baseball <- function(){
  
  # bad input handling
  just.try <- 
    function(expr) tryCatch(expr, error=function(e) e, warning=function(w) w)

  # guess iteration
  iter <- function(try.count, answer){

    print('your guess?')
    
    guess <- 
      just.try(scan(what=integer(), n=length(answer)))
    
    # bad input handling : restart guess
    bad.guess <-
      any(class(guess) %in% c('error','warning'))
    
    if(bad.guess){
      print('bad input, plz try again')
      return(iter(try.count, answer))
    }
    
    # display guess
    cat('your guess : ', guess, '\n')
    
    # calculate strike, ball, out
    strike <- 
      sum(guess == answer)
    
    ball <- {
      wrong <- guess[guess != answer] 
      sum(wrong %in% answer)
    }
    
    out <- 
      length(answer) - strike - ball
    
    print('====================')
    
    # assessment
    if(all(answer == guess)){
      # end up the game
      cat('all strike! congratulations! your try count : ', try.count)
    }else{
      # display strike, ball, out & iterate guess
      cat('strike:', strike, ' ball:', ball, ' out:', out, '\n')
      return(iter(try.count + 1, answer))
    } 
  }
  
  # ask answer length
  answer.length <- 
    readline('plz set answer length : 2 ~ 9 : ')
  
  answer <- 
    just.try(sample(0:9, as.integer(answer.length)))
  
  # bad input handling : restart game
  bad.answer <-
    any(class(answer) %in% c('error','warning')) ||
    answer.length < 2 || 
    answer.length > 9 || 
    grepl('\\.', answer.length) # numeric but not integer case : 2.5
  
  if(bad.answer){
    print('bad input, plz try again')
    return(baseball())
  }
  
  # start guess
  return(iter(1, answer))
}

baseball()

# facebook post : other answers
# https://www.facebook.com/groups/krstudy/permalink/918870458287227/
