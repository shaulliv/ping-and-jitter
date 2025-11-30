#!/bin/bash
#create array for ping targets
pingtarget=()
#input targets into array
mapfile -t pingtarget < <( echo -e "8.8.8.8 \n1.1.1.1 \nexample.com \ngoogle.com" )
#execute ping to each target
for target in "${pingtarget[@]}"
do
total=0
items=0
mean=0
diff=0
diffpre=0
jitter=0
diffsum=0
pingto=$(echo $target)
        #create array for ping time of targets
		pingtime=()
        #parse result of ping into array
        mapfile -t pingtime < <(  ping -c 4 "$pingto" | grep -oE 'time=[0-9].[0-9]|time=[0-9].[0-9][0-9]|time=[0-9][0-9].[0-9]|time=[0-9][0-9].[0-9][0-9]|time=[0-9][0-9][0-9].[0-9]|time=[0-9][0-9][0-9].[0-9][0-9]|time=[0-9][0-9][0-9][0-9].[0-9]|time=[0-9][0-9][0-9][0-9].[0-9][0-9]' | sed 's/time=//g' )
        #calculate mean of the ping sample
        for value in "${pingtime[@]}"
        do
            total=$(echo $total + $value | bc)
                    #calulate difference between samples
                    if [[ "$diffpre" != 0 ]]; then
                    diff=$(echo "ecale=2; $diffpre - $value" | bc | sed 's/-//g' | awk '{printf "%.2f\n", $0}')
                    fi
            items="${#pingtime[@]}"
            diffpre=$(echo $value)
            #array for difference mean calculation
            jitter=()
            jitter+=("${diff}")
            for sindiff in "${jitter[@]}"
            do
                diffsum=$(echo "scale=2; $diffsum + $sindiff" | bc | awk '{printf "%.2f\n", $0}')
            done
        done
    mean=$(echo "scale=2; $total / $items" | bc)
    jitter=$(awk -v items=$items -v diffsum=$diffsum 'BEGIN {a=items;b=1;c=diffsum;print"",(c/(a-b))}' | sed 's/ //g')
done
