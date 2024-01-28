import sys
import pandas as pd
import datetime
import concurrent.futures
from pandarallel import pandarallel

pandarallel.initialize(progress_bar=False)

NUM_WORKERS = 8
CSV_IDX = 1
INFO_IDX = 2
OUTPUT_IDX = 3


def get_current_date_ddmmyy():
    current_date = datetime.datetime.now()
    formatted_date = current_date.strftime("%d%m%y")
    return formatted_date


def create_info_lines(file,col_info_file):
    VCF_VERSION ='##fileformat=VCFv4.2'
    date = f'##date={get_current_date_ddmmyy()}'
    source_file = f'##sourcefile={file}'
    ref = '##reference=hg38'
    info_s = pd.Series([VCF_VERSION,date,source_file,ref])
#    info_df = pd.read_csv(col_info_file).replace(' ','.')
#    info_s = pd.concat([info_s,info_df.apply(lambda x: f'##{x.type}=<ID={x.ID},Number={x.Number},Type={x.Dtype},Description={x.Description}>', axis=1)])
    return info_s

def prepare_sample(df,id):
    cols = [f'{id}:GT',f'{id}:DP',f'{id}:GQ',f'{id}:AB']
    sample_df =df[cols].copy()
    sample_df[f'{id}:GT'] = '0/1'
    sample_df[f'{id}:DP'] = 99
    sample_df[f'{id}:GQ'] = 99
    sample_df[f'{id}:AB'] =  1
    sample_df =sample_df.fillna('.').replace(-1,'.')
    return sample_df.parallel_apply(lambda x : ':'.join(x.astype(str).tolist()), axis=1).rename(id)

def df_to_vcf(file,info_col):
    info_df = pd.read_csv(info_col)
    df = pd.read_csv(file, low_memory=False)
    res_df = pd.DataFrame()
    res_df['#CHROM'] = df.CHROM #.str.replace('chr','')
    res_df['POS'] = df.POS
    res_df['ID'] = '.'
    res_df['REF'] = df.REF
    res_df['ALT'] = df.ALT
    res_df['QUAL'] = 0
    res_df['FILTER'] = df.FILTER.replace(' ','.')
    INFO_cols = info_df[info_df.type == 'INFO'].ID
    df.loc[:,INFO_cols] = df[INFO_cols].replace(' ','.').fillna('.')
    res_df['INFO'] = df.parallel_apply(lambda x: ';'.join([f'{i}={x[i]}' for i in INFO_cols]),axis=1)
    FORMAT_cols = info_df[info_df.type == 'FORMAT'].ID
    format = ':'.join(FORMAT_cols.tolist())
    res_df['FORMAT'] = format
    res_df['generic_sample'] = '0/1:99:99:1'
    return res_df


def main(file, col_info_file, output_name):
    print("Prepare info")
    info_s =create_info_lines(file, col_info_file)
    print("Prepare data")
    vcf_df = df_to_vcf(file, col_info_file).T.reset_index().T
    vcf_df = pd.concat([info_s,vcf_df])
    print("saving")
    vcf_df.to_csv(output_name,sep='\t',index=False,header=None)
    print(f'Saved as {output_name}')

if __name__ == '__main__':
    if len(sys.argv) < 4:
        print("Error: Insufficient command line arguments.")
        print("Usage: python csv_to_vcf.py csv_file col_info_file output_name")
        sys.exit(1)
    
    csv_file = sys.argv[CSV_IDX]
    col_info_file = sys.argv[INFO_IDX]
    output_name = sys.argv[OUTPUT_IDX]
    main(csv_file, col_info_file, output_name)
