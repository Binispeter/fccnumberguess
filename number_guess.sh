#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME

USERNAME_SEARCH_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USERNAME_SEARCH_RESULT ]]
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    
  else
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT MIN(tries) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME'")

    echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

TRIES=0

echo "Guess the secret number between 1 and 1000:"
read GUESS

until [[ $GUESS == $RANDOM_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
      read GUESS
      ((TRIES++))
    else
      if [[ $GUESS < $RANDOM_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
          read GUESS
          ((TRIES++))
        else 
          echo "It's lower than that, guess again:"
          read GUESS
          ((TRIES++))
      fi  
  fi

done

((TRIES++))

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(tries, user_id) VALUES ($TRIES, $USER_ID)")

echo You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job\!