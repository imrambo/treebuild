"""
Motivation: parse IMG functional annotation output for a tidy table
to use in R.
Author: Ian Rambo
"""

import argparse
import os
import re

parser = argparse.ArgumentParser()

parser.add_argument('--input', type=str, dest='input', action='store',
help='input nucleotide FASTA file. Required.')
parser.add_argument('--output', type=str, dest='output', action='store',
help='root output directory. Required.')
opts = parser.parse_args()

with open(opts.input, 'r') as infile, open(opts.output, 'w') as outfile:
    no_product = 0
    for line in infile:
        line = line.rstrip()
        line_fields = line.split('\t')
        attributes = line_fields[-1]
        attributes_list = attributes.split(';')
        gene_id = attributes_list[0].split('=')[1]
        product = [a for a in attributes_list if a.startswith('product=')]
        product_source = [b for b in attributes_list if b.startswith('product_source=')]
        if product and product_source:
            product_source = product_source[0].split('=')[1]
            product = product[0].split('=')[1]
            if re.match(r'KO\:K\d+', product_source):
                product_source = product_source.split(':')[1]
            else:
                pass

            outfile.write('%s\t%s\t%s\n' % ('\t'.join(line_fields[:-1]), product, product_source))
        else:
            no_product += 1
    print('%d entries did not have a product accession' % no_product)
