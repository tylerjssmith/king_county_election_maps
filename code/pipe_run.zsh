################################################################################
# Pipeline for King County Election Maps
################################################################################

##### Results: Raw > Processed #################################################
Rscript code/pipe_results.R results_king_2021_08_primary.csv 2021 Primary
echo ''

Rscript code/pipe_results.R results_king_2021_11_general.csv 2021 General
echo ''

Rscript code/pipe_results.R results_king_2023_08_primary.csv 2023 Primary
echo ''

Rscript code/pipe_results.R results_king_2023_11_general.csv 2023 General
echo ''

##### Geometry: Raw > Processed ################################################
Rscript code/pipe_geometry.R \
  precincts_king_2016/2016_Voting_Districts_for_King_County___votdst_area_2016.shp \
  precincts_king_2016/precincts_king_2016.shp
echo ''

Rscript code/pipe_geometry.R \
  precincts_king_2022/Voting_Districts_of_King_County___votdst_area.shp \
  precincts_king_2022/precincts_king_2022.shp
echo ''

##### Load in PostgreSQL #######################################################
Rscript code/pipe_load_to_sql.R
echo ''

##### Input ####################################################################
Rscript code/pipe_input.R
