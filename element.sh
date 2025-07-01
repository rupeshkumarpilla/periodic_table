#!/bin/bash

# Periodic Table Element Lookup Script
# Usage: ./element.sh [atomic_number|symbol|name]

# Database connection setup
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if argument is provided
if [[ $# -eq 0 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Get the input argument
INPUT=$1

# Function to query element information
get_element_info() {
  local query_condition=$1
  
  # Query to get all element information
  RESULT=$($PSQL "
    SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
    FROM elements e
    INNER JOIN properties p ON e.atomic_number = p.atomic_number
    INNER JOIN types t ON p.type_id = t.type_id
    WHERE $query_condition;
  ")
  
  echo "$RESULT"
}

# Determine input type and create appropriate query condition
if [[ $INPUT =~ ^[0-9]+$ ]]; then
  # Input is a number (atomic number)
  ELEMENT_INFO=$(get_element_info "e.atomic_number = $INPUT")
elif [[ ${#INPUT} -le 2 ]] && [[ $INPUT =~ ^[A-Za-z]+$ ]]; then
  # Input is likely a symbol (1-2 characters, letters only)
  ELEMENT_INFO=$(get_element_info "e.symbol = '$INPUT'")
else
  # Input is likely an element name
  ELEMENT_INFO=$(get_element_info "e.name = '$INPUT'")
fi

# Check if element was found
if [[ -z $ELEMENT_INFO ]]; then
  echo "I could not find that element in the database."
else
  # Parse the result
  IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT <<< "$ELEMENT_INFO"
  
  # Output the formatted information
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
fi
