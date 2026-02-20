#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

  NEW_FILE=$(sed -s 's/,/ | /g' games.csv)
  
  cat games.csv | while read LINE
  do
    OUTPUT=$(echo $LINE | sed 's/,/ | /g')
    THIRD_PLACE_HYPHEN=$(echo $OUTPUT | sed 's/Third /Third-/')
    NATION_HYPHEN=$(echo $THIRD_PLACE_HYPHEN | sed 's/Costa /Costa-/; s/United /United-/')
    echo $NATION_HYPHEN | while read YEAR BAR ROUND BAR WINNER BAR OPPONENT BAR WINNER_GOALS BAR OPPONENT_GOALS 
    do 
      if [[ ! $YEAR =~ "year" ]]
      then
        UNHYPHEN_WINNER=$(echo $WINNER | sed 's/-/ /')
        UNHYPHEN_OPPONENT=$(echo $OPPONENT | sed 's/-/ /')
        #check if winner in teams 
        WINNER_QUERY=$($PSQL "SELECT * FROM teams WHERE name = '$UNHYPHEN_WINNER'")
        if [[ -z $WINNER_QUERY ]]
        then
          #insert winner in teams 
          INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$UNHYPHEN_WINNER')")
        fi 
        
        #check if opponent in teams 
        OPPONENT_QUERY=$($PSQL "SELECT * FROM teams WHERE name = '$UNHYPHEN_OPPONENT'")
        if [[ -z $OPPONENT_QUERY ]]
        then 
          #insert opponent in teams 
          INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$UNHYPHEN_OPPONENT')")
        fi 

        
        UNHYPHEN_THIRD_PLACE=$(echo $ROUND | sed 's/Third-Place/Third Place/')
        
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$UNHYPHEN_WINNER'")
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$UNHYPHEN_OPPONENT'")

        #insert rows in games 
        INSERT_GAME=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$UNHYPHEN_THIRD_PLACE',$WINNER_ID, $OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")
      fi
      
    done 
  
  done
