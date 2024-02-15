#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams,games")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
	# Insert winner team into table teams , assign the result into variable INSERT_WINNER_RESULT, if the team name is duplicate then do nothing
    INSERT_WINNER_RESULT="$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER') ON CONFLICT DO NOTHING")"
	
	# Insert opponent team into table teams , assign the result into variable INSERT_OPPONENT_RESULT, if the team name is duplicate then do nothing
    INSERT_OPPONENT_RESULT="$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT') ON CONFLICT DO NOTHING")"
    
    if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
    then
      echo -e "Inserted team $WINNER into teams"
    fi

    if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
    then
      echo -e "Inserted team $OPPONENT into teams"
    fi
	
    # set value of winner_id , get the data from table teams where team name = $WINNER
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    
    # set value of opponent_id, get the data from table teams where team name = $OPPONENT
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'") 
    
    # insert data to table games
    INSERT_GAMES_RESULT="$($PSQL "INSERT INTO games (year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES ($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")"
    
    if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
    then
      echo -e "Inserted games data : $YEAR,$ROUND,$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS INTO games table"
    fi
  fi
done