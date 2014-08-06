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

declare -A  lgList
lgList[Persian]="fa"
lgList[Urdu]="ur"
lgList[Albanian]="sq"
lgList[Azer]="az"
lgList[French]="fr"
lgList[Arabic]="ar"
lgList[Hindi]="hi"

if [ ! -d data ]; then
   mkdir data
fi

if [ ! -d data/words ]; then
   mkdir data/words
fi


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
   
   word2=`echo $word | sed -e 's/"//g'`
   fileName2="data/"`echo $word2 | tr ' ' '_' `"-en-query.txt"
   fileName=`echo $word2 | tr ' ' '_' `
   if [ ! -f "$fileName2" ]; then
      echo "Downloading Wikitionary for $word ..."
      wget "http://en.wiktionary.org/w/api.php?format=xml&action=query&titles=$word2&rvprop=content&prop=revisions&redirects=1" -q -O $fileName2
   else
      echo "------> $fileName2 exists."       
   fi

   
   for lg in ${!lgList[@]}; do
      cat $fileName2 | grep $lg > data/$lg/$fileName-$lg.txt
   done
done

IFS=$oldIFS

for lg in ${!lgList[@]}; do
   if [[ "$lg" =~ '^0$' ]]; then
      continue
   fi
   lg2=${lgList[${lg}]}
   
   if [ -f data/$lg/$lg.txt ] ; then
      rm data/$lg/$lg.txt
   fi
   cat data/$lg/*.* > data/$lg/$lg.txt 
   if [ -f "$wordFileName-$lg.txt" ]; then
      rm $wordFileName-$lg.txt
   fi
   cat data/$lg/$lg.txt | grep "{" | grep "*" |  tr ':' '\n' | tr ',' '\n' | grep  "{"  | sed "s/.*|${lg2}|//" | grep -v "{" | sed 's/|.*//' | sed 's/}//g' | sed 's/,//g' | sort | uniq> $wordFileName-$lg.txt
   size=`wc -l $wordFileName-$lg.txt | awk '{print $1}'`
   echo $size "--> $lg($lg2)"
done




