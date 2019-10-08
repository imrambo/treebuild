
SEARCHDIR=$1
MASTERTABLE=$2

TAB=$'\t'

for i in $(find ${SEARCHDIR} -type f -name "*_functional_annotation.gff"); do
    SAMPLEID=$(echo $i | cut -f 7 -d'/')
    sed "s/^/${SAMPLEID}${TAB}/g" $i >> $MASTERTABLE
