#!/usr/bin/env python3

#split samples into a batch of approximately the desired number. 
#Take a list of VCFs and an integer, get samples from one vcf and split
import argparse
import subprocess
#import math
import os

def get_options():
    parser = argparse.ArgumentParser()
    parser.add_argument("--vcf", type=str, help='input VCF')
    parser.add_argument("--batch_size", type=int, help='desired batch size')
    parser.add_argument("--outdir", type=str, help='output directory containing sample lists')
    args = parser.parse_args()
    return args


def runcommand(cmd):
    try:
        byteoutput = subprocess.check_output(cmd, shell=True)
        return byteoutput.decode('UTF-8').rstrip()
    except subprocess.CalledProcessError as e:
        print(e.output)
        errstring = "Error in command: " + cmd
        return errstring

def find_and_split_samples(vcf, batch_size, outdir):
    sample_list = get_sample_list(vcf)
    sample_list_split = split_samples(sample_list, batch_size)
    write_sample_lists(sample_list_split, outdir)


def get_sample_list(vcf): 
    cmd = "bcftools query -l " + vcf
    samples = runcommand(cmd)
    sample_list = samples.split()
    return sample_list


def optimise_batch_size(batch_size, list_length):
    optimised = 'no'
    upper_limit = 2 * batch_size #don't let batch size end up more than double original
    lower_limit = batch_size / 2 #don't let batch size end up less than half original
    target_remainder = 0.75 * batch_size #want last chunk to be at least 75% of the chosen batch size
    batch_increment = batch_size
    batch_decrement = batch_size
    stop_increment = 'no'
    stop_decrement = 'no'
    while optimised == 'no':
        if batch_increment > upper_limit:
            stop_increment = 'yes'
        if stop_increment == 'no':
            batch_increment+=1
            last_chunk = list_length % batch_increment
            if last_chunk >= target_remainder:
                optimised == 'yes'
                return batch_increment

        if batch_decrement < lower_limit:
            stop_decrement = 'yes'
        if stop_decrement == 'no':
            batch_decrement-=1
            last_chunk = list_length % batch_decrement
            if last_chunk >= target_remainder:
                optimised == 'yes'
                return batch_decrement
        
        if stop_increment == 'yes' and stop_decrement == 'yes':
            #can't find anything suitable - return the higher one
            print("remainder is too low")
            optimised == 'yes'
            return batch_increment


def split_samples(sample_list, batch_size):
    '''
    Split sample list into batches of approximately the requested size. 
    The idea is not to have the last batch being too small
    '''
    list_length = len(sample_list)
    #list_length = 15367
    #n_chunks = list_length / batch_size
    last_chunk = list_length % batch_size #the last chunk will be the remainer and will be smaller than the others
    if last_chunk >= (0.75 * batch_size):#if the last chunk is big enough we are happy
        final_batch_size = batch_size
    else:
        final_batch_size = optimise_batch_size(batch_size, list_length)

    samples_split_list = [sample_list[i:i + final_batch_size] for i in range(0, len(sample_list), final_batch_size)] 
    
    return samples_split_list


def write_sample_lists(sample_list_split, outdir):
    i = 1
    for lst in sample_list_split:
        sample_file = outdir + "/samples_" + str(i) + ".txt"
        with open(sample_file, 'w') as sf:
            sf.write(('\n').join(lst))
            sf.write('\n')
        i+=1


def main():
    args = get_options()
    find_and_split_samples(args.vcf, args.batch_size, args.outdir)


if __name__ == '__main__':
    main() 

