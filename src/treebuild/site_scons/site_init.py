#!/usr/bin/python3


def BLAST_BESTHITS(source, target, blast_names, env):
    """
    Get the best hit for each target AA sequence from HMMER3 domain
    table output. The best hit is based on:
    1. min independent e-value
    2. max bitscore
    3. max alignment length
    4. max query coverage at high-scoring segment pair
    """
    import pandas as pd
    
    blasttbl = pd.read_csv(source, comment='#', header=None,
    names = blast_names, sep = '\s+')

    aggregations = {'qseqid':'first', 'evalue':min, 'ppos':max, 'bitscore':max, 'length':max, 'qcovhsp':max}
    blast_agg = blasttbl.groupby(['target_name'], as_index = False).agg(aggregations)
    #return blast_agg
    blast_agg.to_csv(target, sep = '\t', encoding='utf-8', header = True, index = False)
    return None
