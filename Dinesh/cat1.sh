for i in `cat filename` 
do
bq load --field_delimiter="," --source_format=CSV --skip_leading_rows=1 --project_id="dmgcp-foundation" Adarsh.ice1 $i

if [ $? -eq 0 ];
then
bq query --use_legacy_sql=false --project_id="dmgcp-foundation" "truncate table Adarsh.ice2"

bq query --use_legacy_sql=false --project_id="dmgcp-foundation" "Insert into dmgcp-foundation.Adarsh.ice2(col1,col2,col3,col4,col5)SELECT col1,col2,col3,col4,col5 FROM dmgcp-foundation.Adarsh.ice1  LIMIT 1000"
bq query --use_legacy_sql=false --project_id="dmgcp-foundation" "truncate table Adarsh.ice3"


bq query --use_legacy_sql=false --project_id="dmgcp-foundation" "Insert into dmgcp-foundation.Adarsh.ice3(col1,col2,col3,col4,col5,created_dt,updated_dt,filename
)SELECT col1,col2,col3,col4,col5,current_date as created_dt,current_timestamp as updated_dt,'$i' as filename FROM dmgcp-foundation.Adarsh.ice2  LIMIT 1000"


 



else exit 1
fi	
done

