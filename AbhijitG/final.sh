source /home/abhijit_gunjewar/final_test/parameter.sh

while [ true ]
do
counter=0;
filecount=`wc -l File.txt| awk '{print $1}'`
for i in `cat File.txt`
do

link=$sourcebucket/$i

gsutil -q stat $link

if [ $? -eq 0 ]
then
        counter=$(($counter+1))
else
	echo "$i file is not present at storage "	
fi


done

if [ $counter == $filecount ]
then     
        echo "All  files are present at storage"
	
        for i in `cat File.txt`
        do

	 
	echo " loading data into $loadTable for $i"	
	bq load --source_format=CSV --field_delimiter=',' --skip_leading_rows=1 --project_id="dmgcp-foundation" $loadTable $sourcebucket/$i
        
	echo " loading data into $tempTable for $i "
	bq load --source_format=CSV --field_delimiter=',' --skip_leading_rows=1 --project_id="dmgcp-foundation" $tempTable $sourcebucket/$i
	
	echo " inserting data into another table $AgreegatorTable which has 3 additonal column for $i"
	bq query --use_legacy_sql=false --project_id='dmgcp-foundation' 'insert into '$AgrregatorTable'(id,name,bond,query,doj,last_update_ts,created_dt,file) select id,name,bond,query,doj,current_timeStamp,current_date,"'$i'" from '$tempTable''


        bq query --use_legacy_sql=false --project_id='dmgcp-foundation' 'truncate table  '$tempTable''

	done

	echo " Extracting data into output_final.csv in $destinationbucket "

	bq extract --project_id='dmgcp-foundation' --destination_format=CSV --field_delimiter=',' --print_header=true "$AgrregatorTable" $destinationbucket/output_final.csv

         	
	exit 1
else     
        echo "Files are missing at storage.. so we will wait for 10 sec and will again check"
        sleep 10
fi           
   
done
