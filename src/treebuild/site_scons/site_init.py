#!/usr/bin/python3
import os
import re
import pandas as pd
#------------------------------------------------------------------------------
def get_basename(file_path):
    basename = os.path.basename(file_path)
    #Remove two extensions, e.g. foo.tar.gz becomes foo
    if re.match(r'^.*?\.[a-z]+\.[a-z]+$', basename):
        basename = re.findall(r'^(.*?)\.[a-z]+\.[a-z]+$', basename)[0]
    else:
        basename = os.path.splitext(basename)[0]
    return basename
#------------------------------------------------------------------------------
def REMOVE_BUILD(source):
    """
    Remove intermediate build targets within a specified temporary directory.
    """
    if os.path.exists(source) and os.listdir(source):
        print('removing intermediate build targets in %s' % os.path.abspath(source))
        for tmp in [os.path.join(source, os.path.basename(str(t))) for t in BUILD_TARGETS]:
            if os.path.isfile(tmp):
                print('removing %s' % tmp)
                os.remove(tmp)
            else:
                pass

        if not os.listdir(source):
            print('removing empty directory: "%s"' % source)
            os.rmdir(source)
        else:
            print('directory "%s" is not empty' % source)
    else:
        print('Cannot delete directory "%s", does not exist' % tmpdir)
        pass
    return None
#------------------------------------------------------------------------------
def BLAST_BESTHITS(target, source, blast_names):
    """
    Get the best hit for each target AA sequence from HMMER3 domain
    table output. The best hit is based on:
    1. min independent e-value
    2. max bitscore
    3. max alignment length
    4. max query coverage at high-scoring segment pair
    """

    blasttbl = pd.read_csv(source, comment='#', header=None,
    names = blast_names, sep = '\s+')

    aggregations = {'qseqid':'first', 'evalue':min, 'ppos':max, 'bitscore':max, 'length':max, 'qcovhsp':max}
    blast_agg = blasttbl.groupby(['target_name'], as_index = False).agg(aggregations)
    #return blast_agg
    blast_agg.to_csv(target, sep = '\t', encoding='utf-8', header = True, index = False)

    return None
