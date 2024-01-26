
nextflow.enable.dsl=2

//deconvolved ei spectra mgf file
params.spectra = "data/clutered_spectra-main.mgf"
//spectral library 
params.library = "data/GNPS-NIST14-MATCHES.mgf"
//feature quantification table : TODO
params.quant_table = "data/quant_table-main.csv"
//feature reformatted quantification table : TODO
params.quant_reform_table = "data/"


TOOL_FOLDER = "$baseDir/bin"

process processData{
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path spectra
    path library
    path quant_table
    path quant_reform_table


    output:
    file'output.tsv'

    //TODO
    """
    python $TOOL_FOLDER/python_script.py \
    $spectra $library $quant_table $quant_reform_table \ 
    output.tsv \

    """
}

workflow {
    spectra_channel = Channel.fromPath(params.spectra)
    library_channel = Channel.fromPath(params.library)
    quant_table_channel = Channel.fromPath(params.quant_table)
    quant_reform_table_channel = Channel.fromPath(params.quant_reform_table)
    
    processData(spectra_channel, library_channel, quant_table_channel, quant_reform_table_channel)
}