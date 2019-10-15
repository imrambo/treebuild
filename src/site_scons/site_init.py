#!/usr/bin/python3

#Run diamond
Command([DMNDOUT], [CONGENES,TARGETGENES,DMNDDB], 'cat ${SOURCES}[:2] | diamond %s --threads %d --db ${SOURCES}[2] --out $TARGET --header --more-sensitive --outfmt %s' % (DMNDMETHOD, DMNDTHREAD, ' '.join(blast_outfmt))

parser.add_argument('-l','--list', nargs='+', help='<Required> Set flag', required=True)
def BLAST_BESTHITS(source, target, blast_names):
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
    return blast_agg

blast_bh = blast_besthits(args.source, args.target, args.names)

blast_bh.to_csv(blast_bh, sep = '\t', encoding='utf-8', header = True, index = False)
