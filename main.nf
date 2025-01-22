params.input = [
    ["./data/GSM8036223_proc.dm.h5", 
     "./data/GSM8036224_proc.ctrl.h5"]
]

process ExtractHDF5 {
    publishDir 'extracted_data', mode: 'copy'

    input:
    tuple path(input_file_1), path(input_file_2)

    output:
    path("**")  // Save all generated files

    script:
    """
    Rscript "./scripts/extract_hdf5.R" ${input_file_1} ${input_file_2} extracted_data
    """
}

process quality_control {
    publishDir 'qc', mode: 'copy'

    input:
    tuple path(input_file_1), path(input_file_2), path(input_file_3), path(input_file_4), path(input_file_5), path(input_file_6)

    output:
    path("**") 

    script:
    """
    Rscript "./scripts/quality_control.R" ${input_file_1} ${input_file_2} ${input_file_3} ${input_file_4} ${input_file_5} ${input_file_6} qc
    """
}

process  NormalizeData {
    publishDir 'normalize_data', mode: 'copy'

    input:
    tuple path(input_file_1), path(input_file_2), path(input_file_3), path(input_file_4), path(input_file_5), path(input_file_6)

    output:
    path("**") 

    script:
    """
    Rscript "./scripts/normalization.R" ${input_file_1} ${input_file_2} ${input_file_3} ${input_file_4} ${input_file_5} ${input_file_6} normalize_data
    """
}

process clustering {
    publishDir 'clustering', mode: 'copy'

    input:
    tuple path(input_file_1), path(input_file_2)

    output:
    path("**") 

    script:
    """
    Rscript "./scripts/clustering.R" ${input_file_1} ${input_file_2} clustering
    """
}

process DifferentialExpression {
    publishDir 'differential_expression', mode: 'copy'

    input:
    tuple path(input_file_1), path(input_file_2)

    output:
    path("dge_results.csv")

    script:
    """
    Rscript "./scripts/dge.R" ${input_file_1} ${input_file_2} differential_expression
    """
}

process PathwayAnalysis {
    publishDir 'pathway_analysis', mode: 'copy'

    input:
    path("dge_results.csv")

    output:
    path("**")

    script:
    """
    Rscript "./scripts/pathway_analysis.R" \\
           dge_results.csv pathway_analysis
    """
}


workflow {
    input_ch = Channel.from(params.input)
    
    ExtractHDF5(input_ch)
    quality_control(ExtractHDF5.out)
    NormalizeData(quality_control.out)
    clustering(NormalizeData.out)
    DifferentialExpression(NormalizeData.out)
    PathwayAnalysis(DifferentialExpression.out)

}
