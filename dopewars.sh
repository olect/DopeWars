#!/bin/bash

export LANG=en_US                                                                      

DAY=1
END_DAY=60

QUOTE='Usually decided by luck...'
QUOTES=("Buy when prices are low and sell when cops have raided some druglords.")
QUOTES+=("Be aware of dirty cops. They will demand a bribe to let you go.")
QUOTES+=("It's smart to quickly get rid of all your debt.")
QUOTES+=("Buy low, sell high!")
QUOTES+=("Remember to check your health meter")
QUOTES+=("Body armor will only save your life that one time.")
QUOTES+=("Upgrade your trenchcoat space in the store.")
QUOTES+=("Buying and selling Heroin and Cocaine can be very profitable.")
QUOTES+=("Guns can save your life.")
QUOTES+=("If you are smart, then you deposit your cash regurlary ;-)")

NAME=

CASH=150000
BANK=0
DEBT=150000
DEBT_INTEREST=1.08

WEAPON_RACK=

HEALTH=100

CITY="New York, USA"
SELECTED_CITY=0

LOCATIONS=("Bronx" "Manhattan", "Queens" "Coney Island" "Central Park" "Brooklyn")
SELECTED_LOCATION=0

MSG=()

DRUGS=("Acid" "Cocaine" "Crack" "Hashish" "Heroin" "MDA" "Mushrooms" "Opium" "Peyote" "Speed" "Weed")
DRUGS_MIN_PRICE=(500 8000 600 475 6000 1100 70 650 320 200 70)
DRUGS_MAX_PRICE=(1800 16000 1700 795 43000 5600 960 6500 920 2400 560)
SELECTED_DRUG=

PRICES=()
LOWEST_PRICE=

TRENCHCOAT_SPACE_USED=0
TRENCHCOAT_SPACE=100

IN_COAT=()
IN_COAT_QTY=()
IN_COAT_PRICE=()

ACCIDENT_LIST=("")

HAS_KNIFE=0
HAS_PISTOL=0
HAS_MACHINEGUN=0
HAS_GATLINGGUN=0

HAS_BODYARMOR=0
BODYARMOR_REDUSE_RATE=0

function str_repeat()
{
	seq  -f "$1" -s '' $2; echo -n
}

function is_numeric()
{
	re='^[0-9]+$'
	if ! [[ $1 =~ $re ]] ; then
	   return 1
	fi
	return 0
}

function in_array()
{
	local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

function highscore_list()
{
	if [ ! -f "/tmp/highscore.src" ]; then
		touch "/tmp/highscore.src"
	fi
	names=()
	scores=()
	while read line
	do
		arr=$(echo $line | tr "=" "\n")
		i=0

		for x in $arr
		do
		    if [ "$i" -eq "0" ]; then
		    	i=1
		    	names+=("$x")
		    else
		    	i=0
		    	scores+=("$x")
		    fi
		done
	done < '/tmp/highscore.src'

	echo '|                                                                                                    |'
	echo '|  == HIGHSCORE ==                                                                                   |'
	echo '|                                                                                                    |'
	for key in "${!names[@]}"; do
		name=${names[$key]}
		name=$(echo $name | tr "." " ")
		score=${scores[$key]}
		echo -ne "|   $name"
		#str_repeat " " `expr 97 - ${#name}`
		str_repeat " " `expr 30 - ${#name}`
		printScore=$(printf "%'d\n" $score)
		echo -ne "-  $ $printScore"
		str_repeat " " `expr 62 - ${#printScore}`
		echo -ne "|\n"
	done
	echo '|                                                                                                    |'
}

function highscore()
{
	clear
	game_header
	highscore_list
	footer
	echo ''
	read -p "Press any key to return to menu..." any
	menu
}

function get_locations()
{
	ODD=0
	for key in "${!LOCATIONS[@]}"; do
		location=${LOCATIONS[$key]}
		num=$key
		length=${#location}
		rest=`expr 18 - $length`

		if [ $ODD = 0 ]; then
			ODD=1
			if [ $key = 0 ]; then
				printCash=$(printf "%'d\n" $CASH)
				echo -en "|   Cash: \$$printCash"
				str_repeat " " `expr 32 - ${#printCash}`
			fi
			if [ $key = 2 ]; then
				printBank=$(printf "%'d\n" $BANK)
				echo -en "|   Bank: \$$printBank"
				str_repeat " " `expr 32 - ${#printBank}`
			fi
			if [ $key = 4 ]; then
				printDebt=$(printf "%'d\n" $DEBT)
				echo -en "|   Debt: \$$printDebt"
				str_repeat " " `expr 32 - ${#printDebt}`
			fi
			if [ $SELECTED_LOCATION = $key ]; then
				echo -en "|     [x] ${LOCATIONS[$key]}"
			else
				echo -en "|     [$key] ${LOCATIONS[$key]}"
			fi
			str_repeat " " $rest
		else
			ODD=0
			if [ $SELECTED_LOCATION = $key ]; then
				echo -en "| [x] ${LOCATIONS[$key]}"
			else
				echo -en "| [$key] ${LOCATIONS[$key]}"
			fi
			
			str_repeat " " `expr 24 - ${#LOCATIONS[$key]}`
			echo -en "|\n"
		fi
	done
}

# TODO: Implement airport to other country

function set_price()
{
	dayKey='d'$DAY
	arr=()
	insanePriceSet=0
	for key in "${!DRUGS[@]}"; do
		min=${DRUGS_MIN_PRICE[key]}
		max=${DRUGS_MAX_PRICE[key]}

		price=$((RANDOM%max+$min))

		if [ "$insanePriceSet" -eq "0" -a "$DAY" -gt "5" ]; then
			randPrice=$((RANDOM%100+0))
			if [ "$randPrice" -lt "3" ]; then
				upOrDown=$((RANDOM%1000+0))
				upOrDown=`expr $upOrDown % 2`
				if [ "$upOrDown" -eq "0" ]; then
					MSG+=("The street's are flooding with ${DRUGS[$key]} and prices are wey low!")
					price=$(bc <<< "$min / 100 * 25")
				elif [ "$upOrDown" -eq "1" ]; then
					MSG+=("The police has confiscated all ${DRUGS[$key]} and the prices are sky hight!")
					price=$(bc <<< "$max * 3")
				fi
			fi
		fi
		if [ "$price" -le "0" ]; then
			price=1
		fi

		if [ -z "$LOWEST_PRICE" ] || [ "$price" -lt "$LOWEST_PRICE" ]; then
			LOWEST_PRICE=$price
		fi

		arr+=("$price")
	done
	arrRes=$(echo ${arr[@]})
	arrVal=$dayKey'=('$arrRes')'
	PRICES+=("$arrVal")
}

function accidents()
{
	rand=$((RANDOM%$END_DAY+$DAY))
	if [ "$rand" -eq "$DAY"]; then
		accident=$((RANDOM%${#ACCIDENT_LIST[@]}+0))
	fi
}

function get_price()
{
	for elt in "${PRICES[@]}";do eval $elt;done
	priceKey='d'$DAY'['$1']'
	price=$(eval echo \${$priceKey})
	printPrice=$(printf "%'d\n" $price)
	echo -en "$printPrice"
	str_repeat " " `expr 9 - ${#printPrice}`
}

function update_prices()
{
	dayKey='#d'$DAY'[@]'
	priceCount=$(eval echo \${$dayKey})
	if [ "$priceCount" = 0 ]; then
		set_price
	fi
}

function get_coat_line()
{
	i=0
	r=`expr $1 + 1`
	#echo -ne "|    | Drug          | Qty          | Price       |"
	if [ "$r" -le "${#IN_COAT[@]}" ]; then
		for key in "${IN_COAT[@]}"; do		
			if [ "$i" = "$1" ]; then
				echo -ne "| $i"
				str_repeat " " `expr 3 - ${#i}`
				echo -ne "| "${DRUGS[$key]}
				str_repeat " " `expr 14 - ${#DRUGS[$key]}`
				echo -ne "| "${IN_COAT_QTY[$i]}
				str_repeat " " `expr 13 - ${#IN_COAT_QTY[$i]}`
				price=${IN_COAT_PRICE[$i]}
				printPrice=$(printf "%'d\n" $price)
				echo -ne "| "$printPrice
				str_repeat " " `expr 12 - ${#printPrice}`
				echo -ne "|  |"
			fi
			i=`expr $i + 1`
		done
	else
		echo -ne "|    |               |              |             |  |"
	fi
}

function get_drugs()
{
	
	for key in "${!DRUGS[@]}"; do
		min=${DRUGS_MIN_PRICE[key]}
		max=${DRUGS_MAX_PRICE[key]}
		drug=${DRUGS[key]}
		change=$key
		echo -ne "|  | $change"
		str_repeat " " `expr 3 - ${#change}`
		echo -ne "| $drug"
		str_repeat " " `expr 14 - ${#drug}`
		echo -ne "| "
		get_price $key
		echo -ne " |           "
		get_coat_line $key
		echo -ne "\n"
	done
}

function price_history()
{
	exit 1
}

function store()
{
	while true; do
		clear	
		game_store_header
		get_player_info_reduced
		get_store_menu
		footer

		echo ''
		echo 'Hit any key to return to game menu.'
	    read -p "Select option [1-12] : " option
	    echo ''
	    case $option in
			[1-9]* )
				if [ "$option" -eq "1" ]; then
					if [ "$CASH" -ge "150000" ]; then
						CASH=`expr $CASH - 150000`
						TRENCHCOAT_SPACE=`expr $TRENCHCOAT_SPACE + 50`
						MSG+=("You just increase your trenchcoat by 50!")
					fi
				elif [ "$option" -eq "2" ]; then
					if [ "$CASH" -ge "350000" ]; then
						CASH=`expr $CASH - 350000`
						TRENCHCOAT_SPACE=`expr $TRENCHCOAT_SPACE + 100`
						MSG+=("You just increase your trenchcoat by 100!")
					fi
				elif [ "$option" -eq "3" ]; then
					if [ "$CASH" -ge "1500000" ]; then
						CASH=`expr $CASH - 1500000`
						TRENCHCOAT_SPACE=`expr $TRENCHCOAT_SPACE + 500`
						MSG+=("You just increase your trenchcoat by 500!")
					fi
				elif [ "$option" -eq "4" ]; then
					if [ "$CASH" -ge "2000000" ]; then
						CASH=`expr $CASH - 2000000`
						TRENCHCOAT_SPACE=`expr $TRENCHCOAT_SPACE + 1000`
						MSG+=("You just increase your trenchcoat by 1000!")
					fi
				elif [ "$option" -eq "5" ]; then
					if [ "$CASH" -ge "10000000" ]; then
						CASH=`expr $CASH - 10000000`
						TRENCHCOAT_SPACE=99999999999
						MSG+=("You just increase your trenchcoat by unlimited!")
					fi
				elif [ "$option" -eq "6" ]; then	
					if [ "$HAS_KNIFE" -eq "0" ]; then
						if [ "$CASH" -ge "500000" ]; then
							CASH=`expr $CASH - 500000`
							MSG+=("You just bought a knife :-p")
							HAS_KNIFE=1
						fi
					else
						read -p "You already have a knife! Press any key..." any
					fi
				elif [ "$option" -eq "7" ]; then
					if [ "$HAS_PISTOL" -eq "0" ]; then
						if [ "$CASH" -ge "1500000" ]; then
							CASH=`expr $CASH - 1500000`
							MSG+=("You just bought a pistol :-p")
							HAS_PISTOL=1
						fi
					else
						read -p "You already have a pistol! Press any key..." any
					fi
				elif [ "$option" -eq "8" ]; then
					if [ "$HAS_MACHINEGUN" -eq "0" ]; then
						if [ "$CASH" -ge "5000000" ]; then
							CASH=`expr $CASH - 5000000`
							MSG+=("You just bought a machinegun :-p")
							HAS_MACHINEGUN=1
						fi
					else
						read -p "You already have a machine gun! Press any key..." any
					fi
				elif [ "$option" -eq "9" ]; then
					if [ "$HAS_GATLINGGUN" -eq "0" ]; then
						if [ "$CASH" -ge "15000000" ]; then
							CASH=`expr $CASH - 15000000`
							MSG+=("You just bought a gatling gun :-p")
							HAS_GATLINGGUN=1
						fi
					else
						read -p "You are already indestructable! Press any key..." any
					fi
				elif [ "$option" -eq "10" ]; then
					if [ "$HAS_BODYARMOR" -eq "0" ]; then
						if [ "$CASH" -ge "100000" ]; then
							CASH=`expr $CASH - 100000`
							MSG+=("You just bought light kevelar.")
							HAS_BODYARMOR=1
							BODYARMOR_REDUSE_RATE=10
						fi
					else
						read -p "You are already bought a body armor! Press any key..." any
					fi
				elif [ "$option" -eq "11" ]; then
					if [ "$HAS_BODYARMOR" -eq "0" ]; then
						if [ "$CASH" -ge "350000" ]; then
							CASH=`expr $CASH - 350000`
							MSG+=("You just bought medium kevelar.")
							HAS_BODYARMOR=1
							BODYARMOR_REDUSE_RATE=50
						fi
					else
						read -p "You are already bought a body armor! Press any key..." any
					fi
				elif [ "$option" -eq "12" ]; then
					if [ "$HAS_BODYARMOR" -eq "0" ]; then
						if [ "$CASH" -ge "600000" ]; then
							CASH=`expr $CASH - 600000`
							MSG+=("You just bought bulletproof kevelar.")
							HAS_BODYARMOR=1
							BODYARMOR_REDUSE_RATE=100
						fi
					else
						read -p "You are already bought a body armor! Press any key..." any
					fi
				fi
				break
			;;
			* ) break ;;
	    esac
	done
	break
}

function new_game()
{
	DAY=1
	CASH=150000
	DEBT=150000
	DEBT_INTEREST=1.08
	BANK=0
	HEALTH=100
	SELECTED_LOCATION=0
	QUOTE="Usually decided by luck..."
	MSG=()

	IN_COAT=()
	IN_COAT_PRICE=()
	IN_COAT_QTY=()
	game
}

function end_game()
{
	if [ ! -f /tmp/highscore.src ]; then
		touch /tmp/highscore.src
	fi

	MSG=("You finished the game! Hurray :-p")
	tmpName=$(echo $NAME | tr " " ".")
	echo $tmpName"="$CASH >> /tmp/highscore.src

	clear
	game_header
	echo '|                                                                                                    |'
	echo '|              __      __  ______   __    __        __       __   ______   __    __                  |'
	echo '|             /  \    /  |/      \ /  |  /  |      /  |  _  /  | /      \ /  \  /  |                 |'
	echo '|             $$  \  /$$//$$$$$$  |$$ |  $$ |      $$ | / \ $$ |/$$$$$$  |$$  \ $$ |                 |'
	echo '|              $$  \/$$/ $$ |  $$ |$$ |  $$ |      $$ |/$  \$$ |$$ |  $$ |$$$  \$$ |                 |'
	echo '|               $$  $$/  $$ |  $$ |$$ |  $$ |      $$ /$$$  $$ |$$ |  $$ |$$$$  $$ |                 |'
	echo '|                $$$$/   $$ |  $$ |$$ |  $$ |      $$ $$/$$ $$ |$$ |  $$ |$$ $$ $$ |                 |'
	echo '|                 $$ |   $$ \__$$ |$$ \__$$ |      $$$$/  $$$$ |$$ \__$$ |$$ |$$$$ |                 |'
	echo '|                 $$ |   $$    $$/ $$    $$/       $$$/    $$$ |$$    $$/ $$ | $$$ |                 |'
	echo '|                 $$/     $$$$$$/   $$$$$$/        $$/      $$/  $$$$$$/  $$/   $$/                  |'
	echo '|                                                                                                    |'
	echo '|----------------------------------------------------------------------------------------------------|'
	highscore_list
	footer
	echo ''
	read -p "Press any key to return to menu..." any
	menu
}

function new_day()
{
	MSG=()
	DAY=`expr $DAY + 1`
	
	if [ "$DAY" -eq "$END_DAY" ]; then
		if [ "$DEBT" -gt "0" ]; then
			MSG=("You got stabbed and killed by your loanshark...")
			did_die
		else
			end_game
		fi
	fi
	if [ "$DEBT" -gt "0" ]; then
		newDebt=$(bc <<< "$DEBT * $DEBT_INTEREST")
		newDebt=$(echo $newDebt|cut -f1 -d".")
		DEBT=$newDebt
	fi
	quoteVal=$((RANDOM%${#QUOTES[@]}+0))
	selQ=${QUOTES[$quoteVal]}
	QUOTE=$selQ
}

function your_dead()
{
	echo '|                                                                                                    |'
	echo '|                                             uuuuuuu                                                |'
	echo '|                                         uu$$$$$$$$$$$uu                                            |'
	echo '|                                      uu$$$$$$$$$$$$$$$$$uu                                         |'
	echo '|                                     u$$$$$$$$$$$$$$$$$$$$$u                                        |'
	echo '|                                    u$$$$$$$$$$$$$$$$$$$$$$$u                                       |'
	echo '|                                   u$$$$$$$$$$$$$$$$$$$$$$$$$u                                      |'
	echo '|                                   u$$$$$$$$$$$$$$$$$$$$$$$$$u                                      |'
	echo '|                                   u$$$$$$"   "$$$"   "$$$$$$u                                      |'
	echo '|                                   "$$$$"      u$u       $$$$"                                      |'
	echo '|                                    $$$u       u$u       u$$$                                       |'
	echo '|                                    $$$u      u$$$u      u$$$                                       |'
	echo '|                                     "$$$$uu$$$   $$$uu$$$$"                                        |'
	echo '|                                      "$$$$$$$"   "$$$$$$$"                                         |'
	echo '|                                        u$$$$$$$u$$$$$$$u                                           |'
	echo '|                                         u$"$"$"$"$"$"$u                                            |'
	echo '|                              uuu        $$u$ $ $ $ $u$$       uuu                                  |'
	echo '|                             u$$$$        $$$$$u$u$u$$$       u$$$$                                 |'
	echo '|                              $$$$$uu      "$$$$$$$$$"     uu$$$$$$                                 |'
	echo '|                            u$$$$$$$$$$$uu    """""    uuuu$$$$$$$$$$                               |'
	echo '|                            $$$$"""$$$$$$$$$$uuu   uu$$$$$$$$$"""$$$"                               |'
	echo '|                             """      ""$$$$$$$$$$$uu ""$"""                                        |'
	echo '|                                       uuuu ""$$$$$$$$$$uuu                                         |'
	echo '|                              u$$$uuu$$$$$$$$$uu ""$$$$$$$$$$$uuu$$$                                |'
	echo '|                              $$$$$$$$$$""""           ""$$$$$$$$$$$"                               |'
	echo '|                               "$$$$$"                      ""$$$$""                                |'
	echo '|                                 $$$"                         $$$$"                                 |'
	echo '|                                                                                                    |'
}

function do_fight()
{
	LOSS=50
	fight_type=$((RANDOM%4+0))

	if [ "$fight_type" -eq "0" ]; then
		MSG+=("You meet 3 the cops in an alley and got shot, but you barely got away...")
		LOSS=55
	elif [ "$fight_type" -eq "1" ]; then
		MSG+=("A rivaling druglord did a drive-by on your house with a uzi...")
		LOSS=40
	elif [ "$fight_type" -eq "2" ]; then
		MSG+=("Your girlfriend caught you cheating with her best friend and stabbed you in the leg...")
		LOSS=28
	elif [ "$fight_type" -eq "3" ]; then
		MSG+=("You tried to sell your shit in a bad neighbourhood and got punshed in the face...")
		LOSS=10
	fi
	
	if [ "$HAS_GATLINGGUN" -eq "1" ]; then
		LOSS=0
		MSG+=("But that didn't matter, because your gatlinggun blew them to peaces :-p")
	elif [ "$HAS_MACHINEGUN" -eq "1" ]; then
		loss_reduction=$(bc <<< "scale=2;$LOSS/100*50")
		loss_reduction=$(echo $loss_reduction|cut -f1 -d".")
		LOSS=`expr $LOSS - $loss_reduction`
		MSG+=("Lucky you for buying that machinegun...saved you bigtime!")
	elif [ "$HAS_PISTOL" -eq "1" ]; then
		loss_reduction=$(bc <<< "scale=2;$LOSS/100*25")
		loss_reduction=$(echo $loss_reduction|cut -f1 -d".")
		LOSS=`expr $LOSS - $loss_reduction`
		MSG+=("You pistol magazine only contained 5 bullets, but you got em' good ;-)")
	elif [ "$HAS_KNIFE" -eq "1" ]; then
		msg_type=$((RANDOM%4+0))
		loss_reduction=$(bc <<< "scale=2;$LOSS/100*10")
		loss_reduction=$(echo $loss_reduction|cut -f1 -d".")
		LOSS=`expr $LOSS - $loss_reduction`
		if [ "$msg_type" -eq "0" ]; then
			MSG+=("Luckaly you had a knife and could fight back!")
		elif [ "$msg_type" -eq "1" ]; then
			MSG+=("Thank god you bought that knife!")
		elif [ "$msg_type" -eq "2" ]; then
			MSG+=("But you took up your knife and stabbed hard back!")
		elif [ "$msg_type" -eq "3" ]; then
			MSG+=("You stabbed the bastard!")
		fi
	fi

	if [ "$HAS_BODYARMOR" -eq "1" ]; then 
		loss_reduction=$(bc <<< "scale=2;$LOSS/100*$BODYARMOR_REDUSE_RATE")
		loss_reduction=$(echo $loss_reduction|cut -f1 -d".")
		LOSS=`expr $LOSS - $loss_reduction`
		HAS_BODYARMOR=0
	fi

	HEALTH=`expr $HEALTH - $LOSS`
	if [ $HEALTH -le 0 ]; then
		HEALTH=0
		MSG="You died a lonely horrible death..."
		did_die
	fi
}

function has_fight()
{
	fightVal=5
	rand=$((RANDOM%10+0))
	if [ $rand = $fightVal ]; then 
		do_fight
	fi
}

function robbed()
{
	if [ "${#IN_COAT[@]}" -gt "0" ]; then
		drugCount=${#IN_COAT[@]}
		what_drug=$((RANDOM%$drugCount+0))
		drugNum=${IN_COAT[$what_drug]}
		drugName=${DRUGS[$drugNum]}
		drugQty=${IN_COAT_QTY[$what_drug]}
		rand=$((RANDOM%2+0))
		if [ "$rand" -eq "0" ]; then
			robbed_amount=$((RANDOM%$drugQty+1))
			MSG+=("You got robbed and $robbed_amount of your $drugName got stolen...")
		elif [ "$rand" -eq "1" ]; then
			robbed_amount=$drugQty
			MSG+=("You got robbed and all your $drugName got stolen...")
		fi
		tempInCoat=()
		tempInCoatQty=()
		tempInCoatPrice=()
		
		for key in "${!IN_COAT[@]}"; do
			if [ "$what_drug" = "$key" ]; then
				avilableQty=${IN_COAT_QTY[$key]}
				if [ "$avilableQty" -ne "$robbed_amount" ]; then 
					tempInCoat+=("${IN_COAT[$key]}")
					newQty=`expr $avilableQty - $robbed_amount`
					tempInCoatQty+=("$newQty")
					tempInCoatPrice+=("${IN_COAT_PRICE[$key]}")
				fi
			else
				tempInCoat+=("${IN_COAT[$key]}")
				tempInCoatQty+=("${IN_COAT_QTY[$key]}")
				tempInCoatPrice+=("${IN_COAT_PRICE[$key]}")
			fi
		done
		IN_COAT=(${tempInCoat[@]})
	    IN_COAT_QTY=(${tempInCoatQty[@]})
	    IN_COAT_PRICE=(${tempInCoatPrice[@]})

		TRENCHCOAT_SPACE_USED=`expr $TRENCHCOAT_SPACE_USED - $robbed_amount`
	else
		robbed_amount=$((RANDOM%$CASH+0))
		if [ "$robbed_amount" -gt "0" ]; then
			MSG+=("Some dirty cops demanded a bribe for \$$robbed_amount, or they would have killed you!")
			CASH=`expr $CASH - $robbed_amount`
		fi
	fi
}

function got_robbed()
{
	robbedVal=5
	rand=$((RANDOM%20+0))
	if [ $rand = $robbedVal ]; then 
		robbed
	fi
}

function travel()
{
	num=${#LOCATIONS[@]}
	num=`expr $num - 1`
	while true; do
	    read -p "Select location [0-$num]:" loc
	    case $loc in
	        [0-9]* )
	        	if [ $SELECTED_LOCATION != $loc ]; then
					if [ $loc -ge 0 -a $loc -le $num ]; then
						SELECTED_LOCATION=$loc
						#DAY=`expr $DAY + 1`
						new_day
						has_fight
						got_robbed
						break
					fi
				else
					echo "You're already in ${LOCATIONS[$loc]}.."
				fi
			;;
			* )
				break
			;;
	    esac
	done
}

function buy_drug()
{
	num=${#DRUGS[@]}
	num=`expr $num - 1`
	while true; do
	    read -p "Select drug [0-$num]:" drug
	    case $drug in
	        * ) 
				if is_numeric $drug; then
					if [ $drug -ge 0 -a $drug -le $num ]; then
						SELECTED_DRUG=$drug
						break
					fi
				else
					read -p 'Not a number! Press any key...' any
					break
				fi
			;;
	    esac
	done
}

function sell_drug()
{
	num=${#IN_COAT[@]}
	num=`expr $num - 1`
	while true; do
	    read -p "Select drug [0-$num]:" drug
	    case $drug in
	        * ) 
				if is_numeric $drug; then
					if [ $drug -ge 0 -a $drug -le $num ]; then
						SELECTED_DRUG=$drug
						break
					fi
				else
					read -p 'Not a number! Press any key...' any
					break
				fi
			;;
	    esac
	done
}

function hospital()
{
	if [ "$HEALTH" = "100" ]; then
		read -p "Already full health! Press any key..." any
	else
		if [ "$CASH" -ge "150000" ]; then
			while true; do
			    read -p "Fix 10% of health for \$150,000? [y/n]:" yn
			    case $yn in
			        y* ) 
						tempRes=`expr $HEALTH + 10`
						if [ "$tempRes" -gt "100" ]; then
							HEALTH=100
						else
							HEALTH=$tempRes
						fi
						CASH=`expr $CASH - 150000`
						break
					;;
					n* )
						break
					;;
			    esac
			done
		else
			read -p "Not enough funds! Press any key..." any
		fi
	fi
}

function buy_qty()
{
	num=${#DRUGS[@]}
	num=`expr $num - 1`
	price=$(eval echo "\${d"$DAY"["$SELECTED_DRUG"]}")
	printPrice=$(printf "%'d\n" $price)
	drugname=${DRUGS[$SELECTED_DRUG]}

	maxQty=$(bc <<< "scale=2;$CASH/$price")
	maxQty=$(echo $maxQty|cut -f1 -d".")
	TRENCHCOAT_SPACE_AVAILABLE=`expr $TRENCHCOAT_SPACE - $TRENCHCOAT_SPACE_USED`

	if [ -z "$maxQty" ]; then
		maxQty=0
	fi

	if [ "$maxQty" = "0" ]; then
		read -p "Not enough funds! Press any key..." any
	else
		if [ "$TRENCHCOAT_SPACE_AVAILABLE" -le "$maxQty" ]; then
			maxQty=$TRENCHCOAT_SPACE_AVAILABLE
		fi
		echo "Current price for '$drugname' \$$printPrice"
		while true; do
		    read -p "Select qty [0-$maxQty]:" qty
		    case $qty in
		        * ) 
					if is_numeric $qty; then 
						if [ $qty -gt 0 -a $qty -le $maxQty ]; then
							TRENCHCOAT_SPACE_USED=`expr $TRENCHCOAT_SPACE_USED + $qty`
							total=$(bc <<< "$qty * $price")

							if [ $(in_array "${IN_COAT[@]}" "$SELECTED_DRUG") == "y" ]; then
							    tempInCoat=()
							    tempInCoatQty=()
							    tempInCoatPrice=()
							    doUpdate=0

							    for((i=0;i<${#IN_COAT[@]};i++)); do
							    	key=$i
							    	drugValue=${IN_COAT[$i]}
							    	qtyValue=${IN_COAT_QTY[$i]}
							    	priceValue=${IN_COAT_PRICE[$i]}
							    	
							    	if [ "$drugValue" = "$SELECTED_DRUG" ]; then
							    		if [ "$price" -eq "$priceValue" ]; then
							    			doUpdate=1
							    			tempInCoat+=("$drugValue")
							    			newQty=`expr $qty + $qtyValue`
								    		tempInCoatQty+=("$newQty")
								    		tempInCoatPrice+=("$priceValue")
								    	else
								    		tempInCoat+=("$drugValue")
								    		tempInCoatQty+=("$qtyValue")
								    		tempInCoatPrice+=("$priceValue")
							    		fi

							    	else
							    		tempInCoat+=("$drugValue")
							    		tempInCoatQty+=("$qtyValue")
							    		tempInCoatPrice+=("$priceValue")
							    	fi
							    done

							    if [ "$doUpdate" = "0" ]; then
							    	tempInCoat+=("$SELECTED_DRUG")
							    	tempInCoatQty+=("$qty")
							    	tempInCoatPrice+=("$price")
							    fi
							    IN_COAT=(${tempInCoat[@]})
							    IN_COAT_QTY=(${tempInCoatQty[@]})
							    IN_COAT_PRICE=(${tempInCoatPrice[@]})
							else
								IN_COAT+=("$SELECTED_DRUG")
								IN_COAT_QTY+=("$qty")
								IN_COAT_PRICE+=("$price")
							fi
							CASH=`expr $CASH - $total`
						fi
						break
					else
						read -p 'Invalid quantity selected! Press any key...' any
					fi
					
				;;
		    esac
		done
	fi
}

function sell_qty()
{
	
	drugNum=${IN_COAT[$SELECTED_DRUG]}
	drugName=${DRUGS[$drugNum]}
	selQty=${IN_COAT_QTY[$SELECTED_DRUG]}
	buyPrice=${IN_COAT_PRICE[$SELECTED_DRUG]}
	sellPrice=$(eval echo "\${d"$DAY"["$drugNum"]}")

	printBuyPrice=$(printf "%'d\n" $buyPrice)
	printSellPrice=$(printf "%'d\n" $sellPrice)

	echo "$drugName Bought for: \$$printBuyPrice - Sell for: \$$printSellPrice"
	while true; do
	    read -p "Select qty [0-$selQty]:" qty
	    case $qty in
	        * ) 
				if is_numeric $qty; then
					if [ $qty -gt 0 -a $qty -le $selQty ]; then
						total=$(bc <<< "$qty * $sellPrice")
						
						tempInCoat=()
						tempInCoatQty=()
						tempInCoatPrice=()
						
						for key in "${!IN_COAT[@]}"; do
							if [ "$SELECTED_DRUG" = "$key" ]; then
								avilableQty=${IN_COAT_QTY[$key]}
								if [ "$avilableQty" -ne "$qty" ]; then 
									tempInCoat+=("${IN_COAT[$key]}")
									newQty=`expr $avilableQty - $qty`
									tempInCoatQty+=("$newQty")
									tempInCoatPrice+=("${IN_COAT_PRICE[$key]}")
								fi
							else
								tempInCoat+=("${IN_COAT[$key]}")
								tempInCoatQty+=("${IN_COAT_QTY[$key]}")
								tempInCoatPrice+=("${IN_COAT_PRICE[$key]}")
							fi
						done
						IN_COAT=(${tempInCoat[@]})
					    IN_COAT_QTY=(${tempInCoatQty[@]})
					    IN_COAT_PRICE=(${tempInCoatPrice[@]})
						CASH=`expr $CASH + $total`
						TRENCHCOAT_SPACE_USED=`expr $TRENCHCOAT_SPACE_USED - $qty`
					fi
					break
				else
					read -p 'Invalid quantity selected! Press any key...' any
				fi
			;;
	    esac
	done
}

function dump()
{
	if [ "${#IN_COAT[@]}" -gt "0" ]; then
		while true; do
		    read -p "Are you sure you wanna dump your shit? [y/n]:" yn
		    case $yn in
		        y* ) 
					for i in "${!IN_COAT[@]}"; do
						avilableQty=${IN_COAT_QTY[$i]}
						drugNum=${IN_COAT[$i]}
						sellPrice=$(eval echo "\${d"$DAY"["$drugNum"]}")
						total=$(bc <<< "$avilableQty * $sellPrice")
						CASH=`expr $CASH + $total`
					done
					IN_COAT=()
				    IN_COAT_QTY=()
				    IN_COAT_PRICE=()
				    TRENCHCOAT_SPACE_USED=0

					break
				;;
				n* )
					break
				;;
		    esac
		done
	else
		read -p "Nothing to dump. Press any key..." any
	fi
}


function get_coat() {
	i=0
	for key in "${IN_COAT[@]}"; do
		echo -e $i" | "${DRUGS[$key]}" | "${IN_COAT_QTY[$i]}" | "${IN_COAT_PRICE[$i]}
		i=`expr $i + 1`
	done
}

function buy()
{
	if [ "$CASH" -ge "$LOWEST_PRICE" ]; then
		if [ "$TRENCHCOAT_SPACE_USED" -eq "$TRENCHCOAT_SPACE" ]; then
			read -p "Your trench coat is full! Press any key..." any
			break
		fi
		buy_drug
		if is_numeric $SELECTED_DRUG; then
			buy_qty
		fi
	else
		read -p "You don't have enough money to buy drugs! Press any key..." any
	fi
	SELECTED_DRUG=
}

function sell()
{
	if [ "${#IN_COAT[@]}" -gt "0" ]; then
		sell_drug
		if is_numeric $SELECTED_DRUG; then
			sell_qty
		fi
	else
		read -p "You don't have anything to sell! Press any key..." any
	fi
	SELECTED_DRUG=
}

function get_health()
{
	lines=76

	healthLeft=$(bc <<< "scale=2;$lines/100*$HEALTH")
	healthLeft=$(printf "%.0f" $healthLeft)
	emptyLines=$(bc <<< "$lines - $healthLeft")

	if [ $HEALTH -gt 0 ]; then
		str_repeat "=" $healthLeft
	fi
	
	if [ $HEALTH = 100 ]; then
		echo -ne "] $HEALTH %   |\n"
	elif [ $HEALTH -lt 10 ]; then
		str_repeat " " $emptyLines
		echo -ne "  ] $HEALTH %   |\n"
	else
		str_repeat " " $emptyLines
		echo -ne "] $HEALTH %    |\n"
	fi
}

function get_status()
{
	echo '|                                                                                                    |'
	echo -ne "|  Day $DAY - $QUOTE"
	str_repeat " " `expr 91 - ${#DAY} - ${#QUOTE}`
	echo -ne "|\n"
	if [ "${#MSG[@]}" -gt "0" ]; then
		echo '|                                                                                                    |'
		for message in "${MSG[@]}"; do
			echo -ne '|  "'$message'"'
			str_repeat " " `expr 96 - ${#message}`
			echo -ne "|\n"
		done
	fi
	echo '|                                                                                                    |'
	echo '|----------------------------------------------------------------------------------------------------|'
}

function get_player_info()
{
	echo '|                                                                                                    |'
	echo -ne "|   Player: $NAME"
	str_repeat " " `expr 89 - ${#NAME}`
	echo -e "|"
	echo -ne "|   Day: $DAY of $END_DAY"
	str_repeat " " `expr 84 - ${#DAY} - ${#END_DAY} - ${#CITY}`
	echo -ne "$CITY    "
	echo -e "|"
	echo '|                                                                                                    |'
	echo -ne '|   Health: ♥ ['
	get_health
	echo '|                                                                                                    |'
	echo '|----------------------------------------------------------------------------------------------------|'
}

function get_player_info_reduced()
{
	echo '|                                                                                                    |'
	echo -ne "|   Player: $NAME"
	str_repeat " " `expr 79 - ${#NAME} - ${#CASH}`
	echo -ne "Cash: \$$CASH   |\n"
	echo '|                                                                                                    |'
	echo '|----------------------------------------------------------------------------------------------------|'
}

function get_gameplay()
{
	echo '|                                          |                                                         |'
	get_locations
	echo '|                                          |                                                         |'
	echo '|----------------------------------------------------------------------------------------------------|'
	echo '|                                                                                                    |'
	echo -ne "|  Available drugs:                             "
	trenchCoatString="Trenchcoat space $TRENCHCOAT_SPACE_USED/$TRENCHCOAT_SPACE"
	str_repeat " " `expr 50 - ${#trenchCoatString}`
	echo -ne "$trenchCoatString   |\n"
	echo '|  ----------------------------------           ---------------------------------------------------  |'
	echo '|  |    | Drug          | Price $   |           |    | Drug          | Qty          | Price $     |  |'
	echo '|  |--------------------------------|           |-------------------------------------------------|  |'
	get_drugs
	echo '|  ----------------------------------           ---------------------------------------------------  |'
	echo '|                                                                                                    |'
}

function game_header()
{
	echo '------------------------------------------------------------------------------------------------------'
	echo '|                  ______   _____   _____  _______ _  _  _ _______  ______ _______                   |'
	echo '|                  |     \ |     | |_____] |______ |  |  | |_____| |_____/ |______                   |'
	echo '|                  |_____/ |_____| |       |______ |__|__| |     | |    \_ ______|                   |'                                                                
	echo '|                                                                                                    |'
	echo '|----------------------------------------------------------------------------------------------------|'
}

function game_store_header()
{
    echo '      __________________________________________________________________________________________'
    echo '     /                                                                                          \'
    echo '    /       _______ _______  ______ _______        _______ _______  _____   ______ _______       \'
	echo '   /        |  |  | |______ |  ____ |_____|   __   |______    |    |     | |_____/ |______        \'
    echo '  /         |  |  | |______ |_____| |     |        ______|    |    |_____| |    \_ |______         \'
    echo ' /                                                                                                  \'
	echo '------------------------------------------------------------------------------------------------------'
	echo '|                  ______   _____   _____  _______ _  _  _ _______  ______ _______                   |'
	echo '|                  |     \ |     | |_____] |______ |  |  | |_____| |_____/ |______                   |'
	echo '|                  |_____/ |_____| |       |______ |__|__| |     | |    \_ ______|                   |'                                                                
	echo '|                                                                                                    |'
	echo '|----------------------------------------------------------------------------------------------------|'
}

function get_store_menu()
{
	echo '|                                                                                                    |'
	echo '|     ===[ Welcome to our department mega-store ]===                                                 |'
	echo '|                                                                                 ____________       |'
	echo '|    Trenchcoat upgrades:                                                        |.----------.|      |'
	echo '|    [1] Increase by 50 for $150,000                                             || ___  ___ ||      |'
	echo '|    [2] Increase by 100 for $350,000                                            8||   ||   |||      |'
	echo '|    [3] Increase by 500 for $1,500,000                                          ||:===::===:||      |'
	echo '|    [4] Increase by 1000 for $2,000,000                                         |||___||___|||      |'
	echo '|    [5] Unlimited for $10,000,000                                               ||          ||      |'
	echo '|                                                                                ||        _ ||      |'
	echo '|    Weapons: (will reduse damage caughet when attacked)                         ||       (_)||      |'
	echo '|    [6] Knife (-10 %) for $500,000                                              ||          ||      |'
	echo '|    [7] Pistol (-25%) for $1,500,000                                            ||          ||      |'
	echo '|    [8] Machinegun (-50%) for $5,000,000                                        8|          ||      |'
	echo '|    [9] Gatling gun (-100%) for $15,000,000                                     ||          ||      |'
	echo '|                                                                                ||__________||      |'
	echo "|    Body armor:  (will reduse damage caughet when attacked one time)            '------------'      |"
	echo '|    [10] Light kevlar (-10 %) for $100,000                                                          |'
	echo '|    [11] Medium kevlar (-50 %) for $350,000                                                         |'
	echo '|    [12] Bulletproof (-100 %) for $600,000                                                          |'
	echo '|                                                                                                    |'
}

function get_game_menu()
{
	echo '|----------------------------------------------------------------------------------------------------|'
	echo '|                                                                                                    |'
	echo '|  [t] Travel         [o] Store          [b] Buy            [w] Withdraw       [l] Loan              |'
	echo '|  [h] Hospital       [u] Dump           [s] Sell           [d] Deposit        [p] Pay back          |'
	echo '|  [n] New game       [q] Quit                                                                       |'
	echo '|                                                                                                    |'
	echo '|----------------------------------------------------------------------------------------------------|'
}

function get_finished_game_menu()
{
	echo '|----------------------------------------------------------------------------------------------------|'
	echo '|                                                                                                    |'
	echo '|  [n] New game       [h] Highscore      [q] Quit                                                    |'
	echo '|                                                                                                    |'
	echo '|----------------------------------------------------------------------------------------------------|'
}

function did_die()
{
	while true; do
		clear	
		game_header
		get_player_info
		get_status
		your_dead
		get_finished_game_menu
		echo ''
	    read -p "Select option: " option
	    echo ''
	    case $option in
			n* )
				new_game
				game
			break;;
			h* )
				highscore
			break;;
			q|quit* )
				clear
				exit;;
	    esac
	done
	did_die
}

function your_broke()
{                                                                                            
	echo "|    _______   __    __  .___  ___. .______           ___           _______.     _______.    __      |"
	echo "|   |       \ |  |  |  | |   \/   | |   _  \         /   \         /       |    /       |   |  |     |"
	echo "|   |  .--.  ||  |  |  | |  \  /  | |  |_)  |       /  ^  \       |   (----\`   |   (----\`   |  |     |"
	echo "|   |  |  |  ||  |  |  | |  |\/|  | |   _  <       /  /_\  \       \   \        \   \       |  |     |"
	echo "|   |  '--'  ||  \`--'  | |  |  |  | |  |_)  |     /  _____  \  .----)   |   .----)   |      |__|     |"
	echo "|   |_______/  \______/  |__|  |__| |______/     /__/     \__\ |_______/    |_______/       (__)     |"
	echo "|                                                                                                    |"
}

function footer()
{
	echo '|----------------------------------------------------------------------------------------------------|'
	echo '|  Written by Ole Chr. Thorsen                                         Bourne Again Shell Game 2014  |'
	echo '------------------------------------------------------------------------------------------------------'
}

function went_broke()
{
	QUOTE="You stupid bastard! You're broke..."
	MSG=()
	while true; do
		clear	
		game_header
		get_player_info
		get_status
		your_broke
		get_finished_game_menu
		echo ''
	    read -p "Select option: " option
	    echo ''
	    case $option in
			n* )
				new_game
				game
			break;;
			h* )
				highscore
			break;;
			q|quit* )
				clear
				exit;;
	    esac
	done
	went_broke
}

function if_broke()
{
	if [ "$CASH" = "0" ]; then
		if [ "$BANK" = "0" ]; then
			if [ "${#IN_COAT[@]}" = "0" ]; then
				went_broke
			fi
		fi
	fi
}

function deposit()
{
	while true; do
		echo -ne "How much to deposit? [0 - $CASH]: "
	    read -r deposit
	    case $deposit in
	        [0-9]* ) 
				if [ $deposit > 0 ]; then
					if [ $deposit -le $CASH ]; then
						BANK=`expr $BANK + $deposit`
						CASH=`expr $CASH - $deposit`
					fi
				fi
			break;;
	    esac
	done
}

function withdraw()
{
	while true; do
		echo -ne "How much to withdraw? [0 - $BANK]: "
	    read -r withdraw
	    case $withdraw in
	        [0-9]* ) 
				if [ $withdraw > 0 ]; then
					if [ $withdraw -le $BANK ]; then
						BANK=`expr $BANK - $withdraw`
						CASH=`expr $CASH + $withdraw`
					fi
				fi
			break;;
	    esac
	done
}

function loan()
{
	min=50000
	max=$(bc <<< "$CASH * 3")
	if [ "$max" -le "$min" ]; then
		max=$min
	fi

	if [ "$DEBT" -eq "0" ]; then
		while true; do
		    read -p "Enter amount to loan. [$min-$max]: " amount
		    case $amount in
		        [0-9]* ) 
					if [ "$amount" -gt "0" ]; then
						if [ "$amount" -lt "$min" ]; then
							echo "You must loan minimum \$$min!"
						elif [ "$amount" -gt "$max" ]; then
							echo "Maximum loan value is \$$max!"
						else
							interestVal=`expr $max - $min`
							interestVal=$(bc <<< "$interestVal / 4")

							limit1From=$min
							limit1To=`expr $interestVal - 1`

							limit2From=$interestVal
							limit2To=$(bc <<< "$interestVal * 2 - 1")

							limit3From=`expr $limit2To + 1`
							limit3To=$(bc <<< "$interestVal * 3 - 1")

							limit4From=`expr $limit3To + 1`
							limit4To=$max

							if [ "$amount" -ge "$limit1From" -a "$amount" -le "$limit1To" ]; then
								interestRate=14
							elif [ "$amount" -ge "$limit2From" -a "$amount" -le "$limit2To" ]; then
								interestRate=12
							elif [ "$amount" -ge "$limit3From" -a "$amount" -le "$limit3To" ]; then
								interestRate=10
							elif [ "$amount" -ge "$limit4From" -a "$amount" -le "$limit4To" ]; then
								interestRate=8
							fi
							#newDebt=$(echo $newDebt|cut -f1 -d".")
							echo "I can give you a loan for \$$amount with an interest rate of $interestRate%"
							echo -e "If you don't pay me back by day 60, you're dead!\n"
							while true; do
							    read -p "Do you accept my offer? [y/n]:" yn
							    case $yn in
							        y* ) 
										CASH=`expr $CASH + $amount`
										DEBT=$amount
										DEBT_INTEREST=$(bc <<< "scale=2;$interestRate / 100 + 1")
										break
									;;
									n* )
										break
									;;
							    esac
							done
							break
						fi
					fi
				;;
		    esac
		done
	else
		read -p "First you pay me back! Press any key..." any
	fi
}

function pay_back()
{
	max=0
	if [ "$DEBT" -ne "0" ]; then
		if [ "$DEBT" -gt "$CASH" ]; then
			max=$CASH
		elif [ "$CASH" -ge "$DEBT" ]; then
			max=$DEBT
		fi
		printMax=$(printf "%'d\n" $max)
		echo -e "Hi, so nice of you to remember me...\n"
		while true; do
		    read -p "How much do you wanna pay back? [0-$printMax]:" payback
		    case $payback in
		        [0-9]* ) 
					if [ "$payback" -ne "0" ]; then
						CASH=`expr $CASH - $payback`
						DEBT=`expr $DEBT - $payback`
					fi
					break
				;;
		    esac
		done
	else
		read -p "You don't have any debt! Press any key..." any
	fi
}

function game()
{
	if_broke
	if [ $HEALTH -le 0 ]; then
		HEALTH=0
		MSG="You died a lonely horrible death..."
		did_die
	fi
	while true; do
		clear
		update_prices		
		game_header
		get_player_info
		get_status
		get_gameplay
		get_game_menu
		
		echo ''
	    read -p "Select option: " option
	    echo ''
	    case $option in
	        t* ) travel break;;
			h* ) hospital break;;
			o* ) store break;;
			u* ) dump break;;
	        b* ) buy break;;
			s* ) sell break;;
			w* ) withdraw break;;
			d* ) deposit break;;
			l* ) loan break;;
			p* ) pay_back break;;
			n* ) new_game break;;
			q* ) 
				clear 
				exit 1
			;;
	    esac
	done
	game
}

function play()
{
	if [ -z "$NAME" ]; then
		read -p "Enter your name: " n
		if [ ! -z "$n" ]; then
			NAME="$n"
			new_game
		else
			play
		fi
	fi
}

function about()
{
	clear
	game_header
	echo '|                                                                                                    |'
	echo '| DopeWars 3.x                                                                                       |'
	echo '|                                                                                                    |'
	echo '| DopeWars is a *nix rewrite of a game originally based on "Drug Wars" by John E. Del in 1986. It is |'
	echo '| with great gratitude, respect and amongst other things, nostalgia that I sat down and used 3 days  |'
	echo '| on creating this, so that Unix/Linux sysadm`s and fanboys could re-live their youth in this thug`  |'
	echo '| driven game.                                                                                       |'
	echo '|                                                                                                    |'
	echo '| And hey, it`s open source and should work on almost all *nix distros since it`s hacked for bash 3+ |'
	echo '| which was a real pain since it doesn`t support any associative array`s and such, in any functional |'
	echo '| way that is. So I hope that you enjoy the game the way it is and don`t cheat altering the initial  |'
	echo '| parameters ;-)                                                                                     |'
	echo '|                                                                                                    |'
	echo '| From time to time, I create stuff that could be interesting, not only shell-games, so check out my |'
	echo '| Github page http://github.com/olect                                                                |'
	echo '|                                                                                                    |'
	echo '| If somethings doesn`t work as expected or you have improvements, fix it and send me a pull request |'
	echo '| and I`ll be more then gladely to commit it.                                                        |'
	echo '|                                                                                                    |'
	echo '| This game is under the terms of the GNU General Public License                                     |'
	echo '|                                                                                                    |'
	echo '| TODO:                                                                                              |'
	echo '|  - Add more fun things to the store                                                                |'
	echo '|  - Create more realistic AI for fighting police and thug`s                                         |'
	echo '|  - Multiplayer online?                                                                             |'
	echo '|  +++                                                                                               |'
	echo '|                                                                                                    |'
	echo '| Many thank`s to...                                                                                 |'
	echo '|  `jgs` for the ASCII art copied from his website  [http://www.geocities.com/spunk1111/]            |'
	echo '|  `Patrick Gillespie` for his awesom ASCII font generator  [http://patorjk.com/software/taag/]      |'
	echo '|  `DaFreakyG` for his ASCII art  [http://www.retrojunkie.com/asciiart/plants/pot.htm]               |'
	echo '|   ...and of course the people out there making BASH still kicking and awesome ;-)                  |'
	echo '|                                                                                                    |'


	footer
	echo ''
    read -p "Press any key..." any
    menu
}

function menu()
{
	while true; do
		clear
		game_header
		echo '|                                                                                                    |'
		echo '|                                                                                                    |'
		echo "|                                                .                                                   |"
		echo "|                                                M                                                   |"
		echo "|                                               dM                                                   |"
		echo "|                                               MMr                                                  |"
		echo "|                                              4MMML                  .                              |"
		echo "|                                              MMMMM.                xf                              |"
		echo "|                              .              \"MMMMM               .MM-                              |"
		echo "|                               Mh..          +MMMMMM            .MMMM                               |"
		echo "|                               .MMM.         .MMMMML.          MMMMMh                               |"
		echo "|                                \)MMMh.        MMMMMM         MMMMMMM                               |"
		echo "|                                 3MMMMx.     'MMMMMMf      xnMMMMMM\"                                |"
		echo "|                                 '*MMMMM      MMMMMM.     nMMMMMMP\"                                 |"
		echo "|                                   *MMMMMx    \"MMMMM\    .MMMMMMM=                                  |"
		echo "|                                    *MMMMMh   \"MMMMM\"   JMMMMMMP                                    |"
		echo "|                                      MMMMMM   3MMMM.  dMMMMMM            .                         |"
		echo "|                                       MMMMMM  \"MMMM  .MMMMM(        .nnMP\"                         |"
		echo "|                           =..          *MMMMx  MMM\"  dMMMM\"    .nnMMMMM*                           |"
		echo "|                             \"MMn...     'MMMMr 'MM   MMM\"   .nMMMMMMM*\"                            |"
		echo "|                              \"4MMMMnn..   *MMM  MM  MMP\"  .dMMMMMMM\"\"                              |"
		echo "|                                ^MMMMMMMMx.  *ML \"M .M*  .MMMMMM**\"                                 |"
		echo "|                                   *PMMMMMMhn. *x > M  .MMMM**\"\"                                    |"
		echo "|                                      \"\"**MMMMhx/.h/ .=*\"                                           |"
		echo "|                                               .3P\"%....                                            |"
		echo "|                                             nP\"     \"*MMnx                DaFreakyG                |"
		echo '|                                                                                                    |'
		echo '|  [1] Play                                                                                          |'
		echo '|  [2] Highscore                                                                                     |'
		echo '|  [3] About                                                                                         |'
		echo '|                                                                                                    |'
		echo '|  [q] Quit                                                                                          |'
		echo '|                                                                                                    |'
		footer
		echo ''
	    read -p "Select option: " option
	    echo ''
	    case $option in
	        1* ) play break;;
	        2* ) highscore break;;
			3* ) about break;;
			q* ) 
				clear 
			exit;;
	    esac
	done
}

menu