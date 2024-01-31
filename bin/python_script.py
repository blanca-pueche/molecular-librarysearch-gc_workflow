import sys
import argparse
import pandas as pd

import add_mshub_balance_score
import calculate_kovats
import clusterinfosummary_for_featurenetworks
import convert_networks_to_graphml
import filter_gc_identifications
import filter_networking_edges
import getGNPS_library_annotations
import merge_tsv_files_efficient
import metadata_permanova_prioritizer
import ming_fileio_library
import ming_gnps_library
import ming_numerical_utilities
import ming_proteosafe_library
import ming_psm_library
import ming_spectrum_library
import ming_sptxt_library
import molecular_network_filtering_library
import msdial_formatter_gc
import prep_molecular_librarysearch_parameters
import prep_molecular_networking_parameters
import proteosafe
import reformat_quantification
import rpy2_script
import run_qiime2
import spectrum_alignment
import tsv_merger
import write_description

def main():
    parser = argparse.ArgumentParser(description='Library search.')
    # inputs
    parser.add_argument('spectra')
    parser.add_argument('library')
    parser.add_argument('quant_table')
    # output
    parser.add_argument('quant_reform_table')
    parser.add_argument('output_file')

    args = parser.parse_args()

    
    # saving file
    df.to_csv(args.output_file, sep="\t", index=False)

if __name__ == "__main__":
    main()