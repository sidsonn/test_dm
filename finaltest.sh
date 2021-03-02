
 TodaysDate=$( date +%Y%m%d )


path="gs://testsourcebucket2-1/"
fileType="_F.csv"
file1="${path}""Lateral_""$TodaysDate${fileType}"
file2="${path}""fresher_""$TodaysDate${fileType}"

declare -a fileArray
fileArray=($file1 $file2)
#echo ${fileArray[@]}

cnt=0
# for loop to iterate through file name Array
for i in ${fileArray[@]}
do

		

	echo $i	
	x=1
# while loop to check until file is present at storage
            while [ $x -le 1 ]
            do
		     gsutil ls $i
				
				if [[ $? -eq  0  ]]; then
		 
						echo "$i is present at stoarage"
						cnt=$((cnt+1))
						break;

				else
						echo "file is not present hence putting on sleep for 30sec"
						sleep 30
						
				fi


			done

       
done

echo $cnt
echo ${#fileArray[@]}
 if [[ $cnt -eq  ${#fileArray[@]}  ]]; then
 
	 echo "Inside if llopp" 
   for var in ${fileArray[@]} 
   do
          echo "inside for"
          bq load --autodetect --source_format=CSV --project_id="dmgcp-foundation" supriya.finalTest $var Name:String,Address:String,ID:STRING

	  echo "bq loaded"
			  if [[ $? -eq 0 ]]; then
				  echo "inserting"

				  var1=$(echo $var  | awk -F "/" '{print $4}')

			      bq query --use_legacy_sql=false --project_id="dmgcp-foundation"  "insert into supriya.finalTest_stg select Name,Address,ID,cast(CURRENT_DATETIME() as date) as Created_dt,'$var1' as file_name from supriya.finalTest"
  # After insertion truncating table
  
				 bq query --use_legacy_sql=false --project_id="dmgcp-foundation" "truncate table supriya.finalTest"
                 
			      #bq query --use_legacy_sql=false --project_id="dmgcp-foundation"  "insert into  supriya.finalTest_stg1   SELECT Name,Address,ID,Created_dt,file_name FROM supriya.finalTest_stg where file_name like '$var1'"

                  #bq query --destination_table supriya.finalTest_stg --use_legacy_sql=false --project_id="dmgcp-foundation" 'SELECT Name,Address,ID, CURRENT_DATE#TIME() as Created_dt,"$var" as file_name FROM `dmgcp-foundation.supriya.finalTest` where file_name like '$var'


                  #bq query --destination_table supriya.finalTest_stg --use_legacy_sql=false --project_id="dmgcp-foundation" 'SELECT Name,Address,ID, CURRENT_DATE#TIME() as Created_dt,"$var" as file_name FROM `dmgcp-foundation.supriya.finalTest`'


		if [[ $? -eq 0 ]]; then
echo "1"
                    bq extract --destination_format CSV  --field_delimiter , --print_header=true --project_id="dmgcp-foundation" supriya.finalTest_stg  gs://testsourcebucket2-1/final.csv
	       else
		       echo "insertion failed"
                   
               fi		       

			  else
				 echo "bq load failed"
			  fi

    done
fi
