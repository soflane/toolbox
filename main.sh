#!/bin/bash
# TODO
# - send output to file 

# Set API keys if there is any
if [[ -n "${HUNTER_IO_API_KEY}" ]]; then
  mosint set hunter $HUNTER_IO_API_KEY
  sleep 0.3
fi
if [[ -n "${EMAILREP_IO_API_KEY}" ]]; then
  mosint set emailrep $EMAILREP_IO_API_KEY
  sleep 0.3
fi
if [[ -n "${INTELLIGENCE_X_API_KEY}" ]]; then
  mosint set intelx $INTELLIGENCE_X_API_KEY
  sleep 0.3
fi
if [[ -n "${PASTEBIN_DUMPS_API_KEY}" ]]; then
  mosint set psbdmp $PASTEBIN_DUMPS_API_KEY
  sleep 0.3
fi
if [[ -n "${BREACHDIRECTORY_ORG_API_KEY}" ]]; then
  mosint set breachdirectory $BREACHDIRECTORY_ORG_API_KEY
  sleep 0.3
fi
if [[ -n "${WPSCAN_API}" ]]; then
  echo "WPScan API key detected"
  sleep 0.3
fi
clear

# Import needed sources
# menu choices getChoice function 
source <(wget -qO- https://raw.githubusercontent.com/the0neWhoKnocks/shell-menu-select/master/get-choice.sh)

URLregex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
emailRegex="^(([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))\.)*([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))@\w((-|\w)*\w)*\.(\w((-|\w)*\w)*\.)*\w{2,4}$"


# Menu definitions 
mainMenuOptions=(
    "Mosint"
    "Nexfil"
    "WP Scan - WordPress scan"
    "Set API keys"
    "Exit"
)
nexfilMainMenu=(
    "Specify username"
    "Specify a file containing username list"
    "Specify multiple comma separated usernames"
    "Specify timeout [Default : 5]"
    "Back to main menu"
)
MainMenu=(1 "Mosint" 
          2 "Nexfil" 
          3 "WP Scan - WordPress scan" 
          4 "Set API keys" 
          5 "Exit" )
nexfilMainMenuTitle="Select task"
nexfilMainMenu=(1 "Specify username" 
                2 "Specify a file containing username list" 
                3 "Specify multiple comma separated usernames" 
                4 "Specify timeout [Default : 5]" 
                5 "Back to main menu" )


wpscanMainMenuTitle="What do you want to do?"
wpscanMainMenu=(1 "Configure WPscan options" 
                2 "Set target website" 
                3 "Start WPScan" 
                4 "Back to main menu" )

wpConfigPluginsMenuTitle="Which plugins do you want to scan on target?"
wpConfigPluginsRadioMenu=("vp" "Vulnerable plugins" OFF
                          "ap" "All plugins" ON
                          "p"  "Popular plugins" OFF
                          ""   "None" OFF
                          )
wpConfigThemeMenuTitle="Which themes do you want to scan on target?"
wpConfigThemeRadioMenu=("vp" "Vulnerable themes" OFF
                        "ap" "All themes" ON
                        "p"  "Popular themes" OFF
                        ""   "None" OFF
                        )
wpConfigChecklistTitle="Select the options wanted"
wpConfigChecklistItems=("tt"     "Timthumbs" OFF
                        "cb"     "Config backups" OFF
                        "dbe"    "Db exports" OFF
                        "u1-100" "User IDs range 1-100" ON
                        "m1-100" "Media IDs range 1-100" ON
                        )

wpOptions=""
wpOptions_defaults=true


mosintMenu () {
  tries=1
  while [ $tries -le 3 ]
  do
    read -p "Enter admin email: " email
    echo
    if [[ "$email" =~ $emailRegex ]]
    then
      echo "Email address $email is valid."
      break
    else
      echo "Email address $email is invalid."
      email="invalid"
    fi
    tries=$(( $tries + 1 ))
  done
  if [ $email == 'invalid' ]
  then
    echo "Adress must be valid. Exiting..."
    exit
  else
    mosint $email
  fi
}
URLValidation (){
  tries=1
  while [ $tries -le 3 ]
  do
    url=$(whiptail --backtitle "Soflane toolbox" --inputbox "Please the website target :" 10 100 3>&1 1>&2 2>&3)
    echo
    if [[ "$url" =~ $URLregex ]]
    then
      echo "URL $url is valid."
      whiptail --backtitle "Soflane toolbox" --msgbox "URL is valid, will be saved." 10 100
      break
    else
      whiptail --backtitle "Soflane toolbox" --msgbox "URL must be valid." 10 100
      url="invalid"
    fi
    tries=$(( $tries + 1 ))
  done
  if [ $url == 'invalid' ]
  then
    echo "URL must be valid. Exiting..."
    whiptail --backtitle "Soflane toolbox" --msgbox "URL must be valid. Exiting..." 10 100
    exit
  else
    target_url=$url
    # wpscan --url $url --ignore-main-redirect --enumerate u 
  fi
}
wpscanMenu (){
  # wpscan --update
  wpscanMenu_choice=$(whiptail --backtitle "Soflane toolbox"  --menu --notags  "$wpscanMainMenuTitle" 18 100 10 "${wpscanMainMenu[@]}" 3>&1 1>&2 2>&3)
  if [ -z "$wpscanMenu_choice" ]; then
    echo "No option was chosen (user hit Cancel)"
  else
    case $wpscanMenu_choice in
      1)
        wpscanConfigMenu
      ;;
      2)
        URLValidation
        wpscanMenu
      ;;
      3)
        wpscanLauncher
      ;;
      4)
        echo "MainMenu to do"
      ;;
    esac
  fi






}

wpscanLauncher(){
  
  args=""
  if [ -z "$target_url" ]; then
    if [[ -n "${WPSCAN_TARGET_URL}" ]]; then
      target_url=$WPSCAN_TARGET_URL
    else
      whiptail --backtitle "Soflane toolbox" --msgbox "No URL set! Will ask you on next screen..." 10 100
      URLValidation
    fi
  fi
  if [ $wpOptions_defaults == "false" ]; then
    args="--enumerate $wpOptions"
    echo "add wpOptions"
  fi
  if [[ -n "${WPSCAN_API}" ]]; then
    args="$args --api-token $WPSCAN_API"
    echo "add API"
  fi
  echo "wpscan --url $target_url --ignore-main-redirect $args"
  read -n 1 -r -s -p $'Press enter to continue...\n'; clear
}
wpscanConfigMenu() {
  wpPluginsMenu_choice=$(whiptail --backtitle "Soflane toolbox" --separate-output --radiolist "$wpConfigPluginsMenuTitle" 18 100 10 "${wpConfigPluginsRadioMenu[@]}" 3>&1 1>&2 2>&3)
  if [ -z "$wpPluginsMenu_choice" ]; then
    echo "No option was chosen (user hit Cancel)"
    wpscanMenu
  else
    options="${wpPluginsMenu_choice}"
    wpThemesMenu_choice=$(whiptail --backtitle "Soflane toolbox" --separate-output --radiolist "$wpConfigThemeMenuTitle" 18 100 10 "${wpConfigThemeRadioMenu[@]}" 3>&1 1>&2 2>&3)
    if [ -z "$wpThemesMenu_choice" ]; then
      echo "No option was chosen (user hit Cancel)"
      wpscanMenu
    else
      options="${options},${wpThemesMenu_choice}"
      wpConfigMenu_choice=$(whiptail --backtitle "Soflane toolbox" --separate-output --checklist "$wpConfigChecklistTitle" 18 100 10 "${wpConfigChecklistItems[@]}" 3>&1 1>&2 2>&3)
      if [ -z "$wpConfigMenu_choice" ]; then
        echo "No option was selected (user hit Cancel or unselected all options)"
        wpscanMenu
      else
        for choice in $wpConfigMenu_choice; do
          options="${options},${choice}"
        done
        wpOptions=$options
        wpOptions_defaults=false
        wpscanMenu
      fi
    fi
  fi
}


while $true
do
  getChoice -q "What do want to do ?" -o mainMenuOptions -i 2 -v "mainMenuChoice"
  case $mainMenuChoice in
      "Mosint" )
          mosintMenu
          ;;
      "Nexfil" )
          nexfilMenu_choice=$(whiptail --backtitle "Soflane toolbox"  --menu --notags  "$nexfilMainMenuTitle" 18 100 10 "${nexfilMainMenu[@]}" 3>&1 1>&2 2>&3)
          if [ -z "$nexfilMenu_choice" ]; then
            echo "No option was chosen (user hit Cancel)"
          else
            case $nexfilMenu_choice in
              1)
                username=$(whiptail --backtitle "Soflane toolbox" --inputbox "Enter username to search : " 10 100 3>&1 1>&2 2>&3)
                if [ -z "$nexfilMenu_choice" ]; then
                  echo "No option was chosen (user hit Cancel)"
                else
                  cd /tools/nexfil/
                  python3 nexfil.py -u $username
                fi
                read -n 1 -r -s -p $'Press enter to continue...\n' ; clear
              ;;
              2)
                echo "WORK IN PROGRESS"
              ;;
              3)
                usernames=$(whiptail --backtitle "Soflane toolbox" --inputbox "Enter usernames to search separated by a \",\": " 10 100 3>&1 1>&2 2>&3)
                if [ -z "$nexfilMenu_choice" ]; then
                  echo "No option was chosen (user hit Cancel)"
                else
                 nexfil.py -l $usernames
                fi
                read -n 1 -r -s -p $'Press enter to continue...\n'; clear
              ;;
              4)
                echo "WORK IN PROGRESS"
                read -n 1 -r -s -p $'Press enter to continue...\n'; clear
              ;;
              5)
                echo "Return Main menu"
              ;;
            esac
          fi
          ;;
      "WP Scan - WordPress scan" )
          wpscanMenu
          ;;
      "Set API keys" )
          echo "API" 
          ;;
      "Exit" )
          echo "End of program"
          exit 
          ;;
  esac

done

