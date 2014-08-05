wordFileName="words-en.txt" # default words list file name
if [ $# -ne 0 ]; then
   if [ -f $1 ]; then
      wordFileName="$1"
   else
      echo "$1 does not exist."
      exit
   fi
fi
echo $wordFileName

# language list --> Persian Urdu Albanian Azeri
declare -A  lgList
lgList[Persian]="fa"
lgList[Urdu]="ur"
lgList[Albanian]="sq"
lgList[Azer]="az"

if [ -d data ]; then
   rm -r data
fi
mkdir data

if [ -d data/words ]; then
   rm -r data/words
fi
mkdir data/words

oldIFS=$IFS
IFS=","

for lg in ${!lgList[@]}; do
   if [ -d data/$lg ]; then
      rm -r data/$lg
   fi
   mkdir data/$lg
done

allWords=`cat $wordFileName | tr '\n' ','`

for word in $allWords; do
   echo "Downloading Wikitionary for $word ..."
   word2=`echo $word | sed -e 's/"//g'`
   fileName=`echo $word2 | tr ' ' '_' `
   wget "http://en.wiktionary.org/w/api.php?format=xml&action=query&titles=$word2&rvprop=content&prop=revisions&redirects=1" -q -O data/$fileName-en-query.txt

   #for lg in $lgList; do
   
   for lg in ${!lgList[@]}; do
      cat data/$fileName-en-query.txt | grep $lg > data/$lg/$fileName-$lg.txt
   done
done

IFS=$oldIFS

for lg in ${!lgList[@]}; do
   if [ "$lg" -eq 0 ]; then
      continue
   fi
   lg2=${lgList[${lg}]}
   echo $lg $lg2
   if [ -f data/$lg/$lg.txt ] ; then
      rm data/$lg/$lg.txt
   fi
   cat data/$lg/*.* > data/$lg/$lg.txt 
   ls -l data/$lg/$lg.txt 
   cat data/$lg/$lg.txt | grep "{" | grep "*" |  tr ':' '\n' | tr ',' '\n' | grep  "{"  | sed "s/.*|${lg2}|//" | grep -v "{" | sed 's/|.*//' | sed 's/}//g' | sed 's/,//g' | sort | uniq> $lg.txt
done




