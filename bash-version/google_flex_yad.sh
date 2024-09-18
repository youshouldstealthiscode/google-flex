#!/bin/bash

# Function: Open a search URL in the default browser
open_url_in_browser() {
  local url="$1"
  if command -v xdg-open > /dev/null; then
    xdg-open "$url"
  elif command -v gnome-open > /dev/null; then
    gnome-open "$url"
  elif command -v open > /dev/null; then
    open "$url"
  else
    echo "Please open the following URL manually: $url"
  fi
}

# Function: Construct Google search query string from user inputs
build_search_query() {
  local query=""
  
  # Add terms with AND (all these words)
  [ -n "$all_words" ] && query+="$all_words"

  # Add terms with exact phrase
  [ -n "$exact_phrase" ] && query+=" \"$exact_phrase\""

  # Add terms with OR (any of these words)
  [ -n "$or_words" ] && query+=" $(echo "$or_words" | sed 's/ / OR /g')"

  # Add terms to exclude (NOT)
  [ -n "$not_words" ] && query+=" $(echo "$not_words" | sed 's/ / -/g')"

  # Add numeric range
  [ -n "$num_from" ] && [ -n "$num_to" ] && query+=" $num_from..$num_to"

  # Add site or domain restriction
  [ -n "$site_domain" ] && query+=" site:$site_domain"

  # Add file type restriction
  [ -n "$file_type" ] && query+=" filetype:$file_type"

  # Add other special search operators
  [ -n "$related_site" ] && query+=" related:$related_site"
  [ -n "$cache_site" ] && query+=" cache:$cache_site"
  [ -n "$definition" ] && query+=" define:$definition"
  [ -n "$info_about" ] && query+=" info:$info_about"
  [ -n "$in_anchor" ] && query+=" inanchor:$in_anchor"
  [ -n "$all_in_title" ] && query+=" allintitle:$all_in_title"
  [ -n "$all_in_url" ] && query+=" allinurl:$all_in_url"
  [ -n "$all_in_text" ] && query+=" allintext:$all_in_text"

  # Add date range filters
  [ -n "$before_date" ] && query+=" before:$before_date"
  [ -n "$after_date" ] && query+=" after:$after_date"

  # Add proximity search
  [ -n "$prox_term1" ] && [ -n "$prox_distance" ] && [ -n "$prox_term2" ] && query+=" \"$prox_term1\" AROUND($prox_distance) \"$prox_term2\""

  echo "$query"
}

# Function: Collect input from user for each search option
collect_user_input() {
  all_words=$(yad --entry --title="All these words (AND)" --text="Enter terms to include:")
  exact_phrase=$(yad --entry --title="This exact word or phrase" --text="Enter exact phrase:")
  or_words=$(yad --entry --title="Any of these words (OR)" --text="Enter terms with OR:")
  not_words=$(yad --entry --title="None of these words (NOT)" --text="Enter terms to exclude:")
  num_from=$(yad --entry --title="Numbers ranging from" --text="Enter starting number:")
  num_to=$(yad --entry --title="Numbers ranging to" --text="Enter ending number:")
  site_domain=$(yad --entry --title="Site or Domain" --text="Restrict search to site:")
  file_type=$(yad --entry --title="File Type" --text="Restrict search by file type:")
  related_site=$(yad --entry --title="Related Sites" --text="Show related to URL:")
  cache_site=$(yad --entry --title="Cached Page" --text="Show cached version of URL:")
  definition=$(yad --entry --title="Definition" --text="Define word:")
  info_about=$(yad --entry --title="Info About" --text="Show info about URL:")
  in_anchor=$(yad --entry --title="In Anchor Text" --text="Search anchor text for:")
  all_in_title=$(yad --entry --title="All in Title" --text="Search titles for all words:")
  all_in_url=$(yad --entry --title="All in URL" --text="Search URLs for all words:")
  all_in_text=$(yad --entry --title="All in Text" --text="Search text for all words:")
  before_date=$(yad --entry --title="Before Date" --text="Restrict search before YYYY-MM-DD:")
  after_date=$(yad --entry --title="After Date" --text="Restrict search after YYYY-MM-DD:")
  prox_term1=$(yad --entry --title="Proximity Term 1" --text="First term for proximity search:")
  prox_distance=$(yad --entry --title="Proximity Distance" --text="Proximity distance (n):")
  prox_term2=$(yad --entry --title="Proximity Term 2" --text="Second term for proximity search:")
}

# Main function: Collect input, build query, and open browser
main() {
  collect_user_input
  search_query=$(build_search_query)

  # URL encoding
  encoded_query=$(echo "$search_query" | jq -sRr @uri)

  # Build URL and open browser
  search_url="https://www.google.com/search?q=$encoded_query"
  open_url_in_browser "$search_url"
}

# Ensure jq is installed (for URL encoding)
if ! command -v jq > /dev/null; then
  echo "Error: jq is not installed. Please install jq first."
  exit 1
fi

main
