#!/usr/bin/python3

# Config files containing hard coded variableus
#configfile: os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), 'snakefiles', 'rotterdam1.json'))
#configfile: os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), 'snakefiles', 'harvest.json'))

### snakemake_workflows initialization ########################################
libdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), 'lib'))
bcftools = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), 'software/bcftools-1.7/bcftools'))
vcftools = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), 'software/vcftools-0.1.13/vcftools'))
plinklocal = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), 'software/plink-1.90b5.3/plink'))

# Output folders
aux = os.path.join(config['output_base'], 'aux')

### workflow settings ##################################
chrom = list(range(1,23))
chromx = chrom + ['X']

### generate paths ###################################
if not os.path.exists(config['output_base']):
    os.makedirs(config['output_base'])

if not os.path.exists(config['tmp_path']):
    os.makedirs(config['tmp_path'])

if not os.path.exists(aux):
    os.makedirs(aux)
