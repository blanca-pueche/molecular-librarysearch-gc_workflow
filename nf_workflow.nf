
nextflow.enable.dsl=2

params.tool_name = "MSHUB" 

//deconvolved ei spectra mgf file
params.spectra = "data/spectra"
//spectral library 
params.library = "data/GNPS-NIST14-MATCHES.mgf"
//feature quantification table 
params.quant_table = "data/quant_table-main.csv"

TOOL_FOLDER = "$baseDir/bin"

// FORMATTING QUANTIFICATION
process reformat_quant_table{      //line 12 in tools.xml
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    val tool_name
    path spectra
    path quant_table


    output:
    path "quant_table_reformatted.csv", emit: quant_table_reformatted
    path "spectra_reformatted.mgf", emit: spectra_reformatted

    """
    python $TOOL_FOLDER/reformat_quantification.py \
    $tool_name $spectra $quant_table \
    quant_table_reformatted.csv spectra_reformatted.mgf
    """
}

process main_execmoduleParallel {      //line 61 in tools.xml 
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path spectra
    path library

    output:
    path results
    //path "networking_pairs_results_folder.aligns"

    """
    mkdir -p results

    python $TOOL_FOLDER/library_search_wrapper.py \
    $spectra $library \
    results \
    $TOOL_FOLDER/convert $TOOL_FOLDER/main_execmodule
    
    """
    /*"""
    python $TOOL_FOLDER/library_search_wrapper.py \
    $spectra $library \
    networking_pairs_results_folder.aligns
    """*/
}

process tsv_merger{      //line 76 in tools.xml 
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path intermediate_result //from main_execmoduleParallel //from main_execmoduleParallel

    output:
    path "result.tsv"

    """
    python $TOOL_FOLDER/tsv_merger.py \
    $intermediate_result\
    result.tsv

    """
}

process gnps_library_annotations{    //line 94 in tools.xml
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path result //file de tsv_merger


    output:
    path "db_result.tsv"

    """
    python $TOOL_FOLDER/getGNPS_library_annotations.py \
    $result \
    db_result.tsv

    """
} 

process filter_gc_identifications{    //line 114 in tools.xml 
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path db_result //from gnps_library_annotations

    output:
    path "db_result_filtered.tsv" 

    """
    python $TOOL_FOLDER/filter_gc_identifications.py \
    $db_result \
    db_result_filtered.tsv
    """
} 

// MOLECULAR NETWORKING (python 3.5)
process prep_molecular_networking_parameters{    //line 144 in tools.xml 
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path mgf_file
    //path workflowParams
    int min_matched_peaks = 1
    float ion_tolerance = 0.75
    float pm_tolerance = 1.0
    float pairs_min_cosine = 0.25

    output:
    path networking_parameters 

    """
    mkdir -p networking_parameters
    python $TOOL_FOLDER/prep_molecular_networking_parameters.py \
    $mgf_file $min_matched_peaks $ion_tolerance $pm_tolerance $pairs_min_cosine  \
    networking_parameters 
    """
} 

/*process main_execmoduleMolecularNetworkingParallel{    //line 158 in tools.xml 
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path networking_parameters
    path mgf_file
    path workflowParams

    output:
    path "networking_pairs_results_folder.aligns"

    """
    python $TOOL_FOLDER/library_search_wrapper.py \
    $networking_parameters $mgf_file $workflowParams\ 
    networking_pairs_results_folder.aligns\
    """
} */

process merge_tsv_files_efficient{    //line 172 in tools.xml 
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path tsv_folder

    output:
    path "tsv_file.tsv"

    """
    python $TOOL_FOLDER/merge_tsv_files_efficient.py \
    $tsv_folder \
    tsv_file.tsv
    """
} 

process filter_networking_edges{    //line 183 in tools.xml
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path workflowParams
    path networking_pairs_results_file //where does it come from!?

    output:
    path "networking_pairs_results_file_filtered.tsv"

    """
    python $TOOL_FOLDER/filter_networking_edges.py \
    $workflowParams $networking_pairs_results_file \
    networking_pairs_results_file_filtered.tsv
    """
} 

process convert_networks_to_graphml{    //line 204 in tools.xml (python 2.7)
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path networkedges_selfloop
    path clusterinfosummarygroup_attributes_withIDs
    path result_specnets_DB

    output:
    path "gnps_molecular_network_graphml.graphml"

    """
    python $TOOL_FOLDER/convert_networks_to_graphml.py \
    $networking_selfloop $clusterinfosummarygroup_attributes_withIDs $result_specnets_DB \
    gnps_molecular_network_graphml.graphml
    """
} 

process calculate_kovats{    //line 227 in tools.xml
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path db_results
    path Carbon_Marker_File 

    output:
    path "DB_result_kovats.tsv"

    """
    python $TOOL_FOLDER/calculate_kovats.py \
    $db_results $Carbon_Marker_File \
    DB_result_kovats.tsv
    """
} 

process add_mshub_balanced_score{    //line 249 in tools.xml 
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path library_identifications //file
    path mshub_balance_scores //folder

    output:
    path "library_identifications_with_balance.tsv"

    """
    python $TOOL_FOLDER/add_mshub_balance_score.py \
    $library_identifications $mshub_balance_scores \
    library_identifications_with_balance.tsv
    """
} 

// CLUSTER INFO
process clusterinfosummary_creation{    //line 271 in tools.xml 
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    int taskId = 0//file
    path quant_table_ref

    path quantification_table //file
    int metadata_table = 0//folder
    path spectra //file

    output:
    path 'clusterinfo_summary.tsv'
    

    """
    python $TOOL_FOLDER/clusterinfosummary_for_featurenetworks.py \
    $taskId $quant_table_ref $quantification_table $metadata_table $spectra \
    clusterinfo_summary.tsv
    """
} 

// RUNNING WRITTEN DESCRIPTION
process write_description{    //line 297 in tools.xml 
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path workflowParams //file

    output:
    path 'written_description.html'

    """
    python $TOOL_FOLDER/write_description.py \
    $workflowParams \
    written_description.html
    """
} 

// RUNNING QIIME2
process run_qiime2{    //line 318 in tools.xml 
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path quantification_table_reformatted //file
    path metadata_table //file

    output:
    path qiime_output

    """
    python $TOOL_FOLDER/run_qiime2.py \
    $quantification_table_reformatted $metadata_table \
    qiime_output
    """
} 

workflow {
    tool_name_channel = params.tool_name
    spectra_channel = Channel.fromPath(params.spectra)
    quant_table_channel = Channel.fromPath(params.quant_table)
    library_channel = Channel.fromPath(params.library)
    
    //formatting quantification
    reformat_quant_table(tool_name_channel, spectra_channel, quant_table_channel) // produces the intermediate_folder for tsv_merger
    spectraReformattedChannel = Channel.fromPath("./nf_output/spectra_reformatted.mgf")
    intermediate_result = main_execmoduleParallel(spectraReformattedChannel, library_channel)
    result = tsv_merger(intermediate_result)
    db_result = gnps_library_annotations(result)
    db_result_filtered = filter_gc_identifications(db_result)

    //molecular networking
    prep_molecular_networking_parameters(spectraReformattedChannel) //min_matched_peaks,ion_tolerance,pm_tolerance,pairs_min_cosine)

    //cluster info
    quant_table_reformatted_channel = Channel.fromPath("./nf_output/quant_table_reformatted.csv")
    clusterinfosummary_creation(quant_table_reformatted_channel, quant_table_channel, spectraReformattedChannel)



}