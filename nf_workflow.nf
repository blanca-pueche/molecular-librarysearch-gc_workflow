
nextflow.enable.dsl=2

params.tool_name = "MSDIAL"

//deconvolved ei spectra mgf file
params.spectra = "data/spectra"
//spectral library 
params.library = "data/GNPS-NIST14-MATCHES.mgf"
//feature quantification table 
params.quant_table = "data/quant_table-main.csv"


TOOL_FOLDER = "$baseDir/bin"

process reformat_quant_table{
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    val tool_name
    path spectra
    // val library
    path quant_table


    output:
    file 'quant_table_reformatted.csv'
    file 'spectra_reformatted.mgf'

    """
    python $TOOL_FOLDER/reformat_quantification.py \
    $tool_name $spectra $quant_table \
    quant_table_reformatted.csv spectra_reformatted.mgf
    """
}

/* process processTest2{
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    val tool_name
    val spectra
    val library
    path quant_table


    output:
    file'output.tsv'

    """
    python $TOOL_FOLDER/python_script.py \
    $tool_name\
    $spectra $library $quant_table quant_reformatted_table.csv \ 
    output.tsv \
    """
} */

workflow {
    tool_name_channel = Channel.fromPath(params.tool_name)
    spectra_channel = Channel.fromPath(params.spectra)
    library_channel = Channel.fromPath(params.library) // not needed for the reformatting
    quant_table_channel = Channel.fromPath(params.quant_table)
    
    reformat_quant_table(tool_name_channel, spectra_channel, quant_table_channel, 'quant_table_reformatted.csv', 'spectra_reformatted.mgf')

}