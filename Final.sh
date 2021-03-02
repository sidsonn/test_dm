count=0
while [ true ]
do
        gsutil -q stat gs://testsourcebucket2-1/Lateral_20210301_F.csv
	if [ $? -eq 0 ];
	then
		(( count++ ))
	else echo "file not prsent"
		
		fi
	
        gsutil -q  stat gs://testsourcebucket2-1/Manager_20210301_F.csv
	if [ $? -eq 0 ];
	then
	(( count++ ))
else echo "file not prsent"
	
	fi
	gsutil -q stat gs://testsourcebucket2-1/Fresher_20210301_F.csv
	if [ $? -eq 0 ];
	then

       (( count++ ))
else echo "file not present"
	
	fi
       

	
if [ $count -eq 3 ];
	then
		echo "Present"
	
	
#bq load --source_format="CSV" --field_delimiter="," --skip_leading_rows=1 --project_id="dmgcp-foundation" Shradha.Empdetails gs://testsourcebucket2-1/Fresher_20210301_F.csv
#bq load --source_format="CSV" --field_delimiter="," --skip_leading_rows=1 --project_id="dmgcp-foundation" Shradha.Empdetails gs://testsourcebucket2-1/Manager_20210301_F.csv
#bq load --source_format="CSV" --field_delimiter="," --skip_leading_rows=1 --project_id="dmgcp-foundation" Shradha.Empdetails gs://testsourcebucket2-1/Lateral_20210301_F.csv

File1=`echo 'gsutil gs://testsourcebucket2-1/Manager_20210301_F.csv' | cut -d '/' -f4`
File2=`echo 'gsutil gs://testsourcebucket2-1/Fresher_20210301_F.csv' | cut -d '/' -f4`
File3=`echo 'gsutil gs://testsourcebucket2-1/Lateral_20210301_F.csv' | cut -d '/' -f4`


echo $File1

declare -a arr 
arr=($File1 $File2 $File3)

echo $arr
for i in ${arr[@]}
do
	echo 'inside for'
	echo $i

bq query --nouse_legacy_sql --project_id="dmgcp-foundation" "delete from Shradha.Empdetails where true" 	

	bq load --source_format="CSV" --field_delimiter="," --skip_leading_rows=1 --project_id="dmgcp-foundation" Shradha.Empdetails gs://testsourcebucket2-1/$i
        
	if [ $? -eq 0 ] ;then
	
		echo "bq load success....starting insertion"
	bq query --use_legacy_sql=false --project_id='dmgcp-foundation' "insert into Shradha.Empdetails1 select cast(ID as int64) as ID,Name,Band,Query,timestamp(DOJ) as doj,current_date as Created_dt ,current_timestamp as Last_updated_timestamp ,'$i' as filename from Shradha.Empdetails;"
bq extract --project_id='dmgcp-foundation' --destination_format="CSV" --field_delimiter="," --print_header=True Shradha.Empdetails1 gs://testsourcebucket2-1/FinaOutput1.csv
	fi
done
break;



else 
	sleep 30
	fi
done
