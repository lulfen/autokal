#!/bin/bash

### This (probably extremely inefficient) program will sync the calender in my GoogleDrive and then output ehich events exists will take place during that week (mon-sun). A simple ease-of-life program that is completely tailored to my specific environment, which probably makes it useless for anyone else without changing some of the code.

### potential updates: - option to check specific dates (implemented (-d))
###                    - auto-posting to fb
###                    - saving output as xml (this was my first idea, but
###                       considering the current use txt is probably better
###                       anyway)

if [ $# -gt 2 ] || [ $# -eq 1 ] ; then
    echo "Usage: bash autoKalender.sh [-d (YYMMDD)]"
    exit
elif [ $# -eq 2 ] ; then
    if [ $1 != "-d" ] ; then
	echo "Usage: bash autoKalender.sh [-d (YYMMDD)]"
	echo "six (6) numbers required with -d"
	echo "default uses today"
	exit
    elif [ ${#2} -ne 6 ] ; then
	echo "Usage: bash autoKalender.sh [-d (YYMMDD)]"
	echo "six (6) numbers required with -d"
	echo "default uses today"
	exit
    else
	inputdate=$2
    fi
else
    inputdate=$(date +'%y%m%d')
fi

echo "Checking for updated calendar..."
rclone check CVO:Ulfen/kalendarium ~/CVO/kalendarium/ &>log.rclone
diff=$(tail -n 1 log.rclone | grep -o '[0-9]* differences' | grep -o '^[0-9]*')

if [ ! -n $diff ]
then
    if [ $diff != 0 ] || [ $diff == "" ]
    then
	echo "Updating calendar..."
	rclone sync CVO:Ulfen/kalendarium ~/CVO/kalendarium/ &>log.rclone
    fi
fi
echo "Calendar up to date!"

docx2txt ~/CVO/kalendarium/Kalendarium_17-18.docx kalendarium.txt
grep -E '[0-9]{1,2}/[0-9]{1,2}' kalendarium.txt > kal.temp.wip
cut -f 2 kal.temp.wip >kal.temp.dates 
akt=$(wc -l kal.temp.dates | grep -o '[0-9]*')

if [ -s kal.temp.zero ]
then
    echo -n >kal.temp.zero
fi
touch "kal.temp.zero"

if [ -s kal.temp.real ]
then
    echo -n >kal.temp.real
fi
touch "kal.temp.real"

for a in `seq 1 $akt`
do
    d=$(grep -oEm $a '^[0-9]{1,2}' kal.temp.dates | tail -n 1)
    e=$(grep -oEm $a '[0-9]{1,2}$' kal.temp.dates | tail -n 1)
    if [ $d -lt 10 ]
    then
	c=0$d
    else
	c=$d
    fi
    if [ $e -lt 10 ]
    then
	f=0$e
    else
	f=$e
    fi
    echo $c/$f >>"kal.temp.zero"
done

date=$(date -d $inputdate +'%d')
month=$(date -d $inputdate +'%m')
W=$(date -d $inputdate +'%W')
grep=$date'/'$month

cut -f 1 kal.temp.wip >kal.temp.i
cut -f 3 kal.temp.wip >kal.temp.iii
paste kal.temp.i kal.temp.zero kal.temp.iii >kalendarium.txt
cat dates.rev | grep -n "$grep" >kal.temp.tmp

linenumber=$(grep -o '^[0-9]*' <kal.temp.tmp)

if [ $linenumber -lt 7 ] #unnessecary check
then
    line=7
elif [ $linenumber -gt 358 ] ##numbers needs to be changed
then
    line=358
else
    line=$linenumber
fi

start=$(($line-7))
tail=$(($line+6))
cat dates.rev | head -n $tail | tail -n 13 >kal.temp.tmp

while read f ; do
    grep -n "$f" <kalendarium.txt >>kal.temp.real
done<kal.temp.tmp
grep -m 1 'Mån' <kal.temp.real >kal.temp.tmp

first=$(grep -oE '^[0-9]*' <kal.temp.tmp )

tail -n $(($akt-$first+1)) <kalendarium.txt | head -n 7 >kal.temp.tmp
last=$(grep -nm 2 'Mån' <kal.temp.tmp | tail -n 1 | grep -oE '^[0-9]*')

if [ $last -lt 1 ]
then
    llast=1
else
    llast=$last
fi

echo -e "Dåne!\nHär kommer en uppdatering av vad som händer vecka "$W":\n" >output.txt
tail -n $(($akt-$first+1)) <kalendarium.txt | head -n $(($llast-1)) >>output.txt
echo -e "\n/CVO" >>output.txt

rm kal.temp.*
cat output.txt
