
nextflow.enable.dsl=2

params.tool_name = "MSHUB" 

//deconvolved ei spectra mgf file
params.spectra = "data/spectra"
//spectral library 
params.library = "data/GNPS-NIST14-MATCHES.mgf"
//feature quantification table 
params.quant_table = "data/quant_table-main.csv"


TOOL_FOLDER = "$baseDir/bin"

process reformat_quant_table{      //line 12 in tools.xml
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    val tool_name
    path spectra
    path quant_table


    output:
    path "quant_table_reformatted.csv"
    path "spectra_reformatted.mgf"

    """
    python $TOOL_FOLDER/reformat_quantification.py \
    $tool_name $spectra $quant_table \
    quant_table_reformatted.csv spectra_reformatted.mgf
    """
}

process tsv_merger{      //line 43 in tools.xml  !?---has many tools?
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    //inputs and outputs !?
    input:
    path input_folder
    path output_tsv



    output:


    """
    python $TOOL_FOLDER/tsv_merger.py \
    $input_folder $output_tsv\

    """
}

//  process gnps_library_annotations{    //line 94 in tools.xml
//     publishDir "./nf_output", mode: 'copy'

//     conda "$TOOL_FOLDER/conda_env.yml"

//     input:
//     file result //de tsv_merger (parallel)


//     output:
//     file "db_result.tsv"

//     """
//     python $TOOL_FOLDER/pgetGNPS_library_annotations.py \
//     $tool_name\ 
//     db_result.tsv\
//     """
//} 

// process filter_gc_identifications{    //line 114 in tools.xml 
//     publishDir "./nf_output", mode: 'copy'

//     conda "$TOOL_FOLDER/conda_env.yml"

//     input:
//     file db_result //from gnps_library_annotations


//     output:
//     file "db_result_filtered.tsv" 

//     """
//     python $TOOL_FOLDER/pgetGNPS_library_annotations.py \
//     $tool_name\ 
//     db_result.tsv\
//     """
// } 

workflow {
    tool_name_channel = params.tool_name
    spectra_channel = Channel.fromPath(params.spectra)
    quant_table_channel = Channel.fromPath(params.quant_table)
    
    reformat_quant_table(tool_name_channel, spectra_channel, quant_table_channel)



}