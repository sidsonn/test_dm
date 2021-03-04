
i=0
while [ true ]
do	
gsutil -q  stat gs://testsourcebucket2-1/Ankita/Lateral_20210303_F.csv
if [ $? -eq 0 ];
then
	    echo "File Found_Lateral_20210303_F.csv"
	    (( i++ ))
    else
	        echo "File not found"
		
		fi

gsutil -q  stat gs://testsourcebucket2-1/Ankita/Fresher_20210303_F.csv
if [ $? -eq 0 ];
then
       	echo "File Found_Fresher_20210303_F.csv"
	(( i++ ))
else
echo "File not found"

 fi

gsutil -q  stat gs://testsourcebucket2-1/Ankita/Manager_20210303_F.csv
if [ $? -eq 0 ];
then
            echo "File Found_Manager_20210303_F.csv"
	    (( i++ ))
    else
                echo "File not found"
                
       		fi

	if [ $i -eq 3 ];
	then 
		echo "3 files present"
	

		file1=`echo 'gsutil gs://testsourcebucket2-1/Ankita/Lateral_20210303_F.csv' | cut -d '/' -f5` 
		file2=`echo 'gsutil gs://testsourcebucket2-1/Ankita/Fresher_20210303_F.csv' | cut -d '/' -f5`
		file3=`echo 'gsutil gs://testsourcebucket2-1/Ankita/Manager_20210303_F.csv' | cut -d '/' -f5`

		#echo $file1 
		#echo $file2
		#echo $file3
	
	declare -a ankita
        ankita=($file1 $file2 $file3)
        echo $ankita

for a in ${ankita[@]}
do
	bq query --nouse_legacy_sql --project_id="dmgcp-foundation" "delete from Ankita.Employee where true" #to delete data
	
		bq load --source_format="CSV" --field_delimiter="," --skip_leading_rows=1 --project_id="dmgcp-foundation" Ankita.Employee gs://testsourcebucket2-1/Ankita/$a
	#	bq load --source_format="CSV" --field_delimiter="," --skip_leading_rows=1 --project_id="dmgcp-foundation" Ankita.Employee gs://testsourcebucket2-1/Ankita/Fresher_20210303_F.csv
	#	bq load --source_format="CSV" --field_delimiter="," --skip_leading_rows=1 --project_id="dmgcp-foundation" Ankita.Employee gs://testsourcebucket2-1/Ankita/Manager_20210303_F.csv
	       	
      echo "data insertion"
	bq query --use_legacy_sql=false --project_id='dmgcp-foundation' "insert into Ankita.Employee1 select cast(ID as int64) as ID,Name,Bond,Query,timestamp(DOJ) as doj,current_date as Created_dt ,current_timestamp as Last_updated_timestamp ,'$a' as filename from Ankita.Employee;"
	
#	bq extract --project_id='dmgcp-foundation' --destination_format="CSV" --field_delimiter="," --print_header=True Ankita.Employee1 gs://testsourcebucket2-1/Ankita/FinaOutput.csv
done
bq extract --project_id='dmgcp-foundation' --destination_format="CSV" --field_delimiter="," --print_header=True Ankita.Employee1 gs://testsourcebucket2-1/Ankita/FinaOutput.csv
break;
 #       bq extract --project_id='dmgcp-foundation' --destination_format="CSV" --field_delimiter="," --print_header=True Ankita.Employee1 gs://testsourcebucket2-1/Ankita/FinaOutput.csv
else echo "all 3 file not present"
		sleep 30
	
		fi	
	done
	
