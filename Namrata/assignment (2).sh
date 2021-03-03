while [ true ]
do
    count=0
    for i in `cat dataFiles.csv`
    do    
	link=gs://testsourcebucket2-1/allFiles/$i

	gsutil -q stat $link
    if [ $? -eq 0 ]; then
      count=$((count+1))
	else
		echo "All Files not present"
    fi	
done

declare -a arr

arr=$(cat dataFiles.csv)

echo ${arr[@]}


    for i in ${arr[@]}
    do	    
	if [ $count == 3 ];then
		echo "All 3 files present"
#	bq query --nouse_legacy_sql --project_id="dmgcp-foundation" "delete from assignment.allData1 where true"

	bq load --autodetect --source_format="CSV" --field_delimiter="," --skip_leading_rows=1  --project_id="dmgcp-foundation" assignment.allData1 gs://testsourcebucket2-1/allFiles/$i


         echo "loaded"

	bq load --autodetect  --source_format=CSV --field_delimiter=',' --skip_leading_rows=1 --project_id='dmgcp-foundation' "assignment.TempallData1" gs://testsourcebucket2-1/allFiles/$i
	echo "loaded into temp table"

	 bq query --use_legacy_sql=False --project_id='dmgcp-foundation' "insert into assignment.allDataCast SELECT ID,Name,Band,Query,cast(DOJ as timestamp) as DOJ,current_timeStamp as curr_timeStamp,'$i' as  fileName FROM dmgcp-foundation.assignment.TempallData1"
         echo "inserted"
	 bq query --use_legacy_sql=False --project_id='dmgcp-foundation' 'truncate table dmgcp-foundation.assignment.TempallData1'
         echo "truncated from temp"
	 bq extract --project_id='dmgcp-foundation' --destination_format CSV --field_delimiter=',' --print_header=true "assignment.allDataCast" gs://testsourcebucket2-1/allFiles/allConcat.csv
	
else
        echo "not present"
        sleep 30
        fi
     done
     exit 1
done
