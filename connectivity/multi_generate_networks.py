#!/usr/bin/env python
# -*- coding: utf-8 -*-

# This code produces multiple nanowire networks of specified parameters into folder    

import wires
import numpy as np

import argparse

# Create parser for options
parser = argparse.ArgumentParser(
    description='Handle parameters to generate a network of nanowires and junctions.')


parser.add_argument('--numSims',
    type    = int,
    default = 10,
    help    = 'The number of nanowires in the network.')


parser.add_argument('--nwires',
    type    = int,
    default = 100,
    help    = 'The number of nanowires in the network.')
    
parser.add_argument('--nwiresMax',
    type    = int,
    default = -1,
    help    = 'The number of nanowires in the network.')


parser.add_argument('--mean_length', 
    type    = float, 
    default = 10.0,
    help    = 'The mean length of the nanowires. Passed to the gamma distribution.')

parser.add_argument('--std_length', 
    type    = float, 
    default = 1.0,
    help    = 'The standard deviation of nanowires length. Passed to the gamma distribution.')

parser.add_argument('--seed',
    type    = int, 
    default = 0,
    help    ='The seed for the random number generator.')

parser.add_argument('--seedMax',
    type    = int, 
    default = -1,
    help    ='The maximum seed for the random number generator.')

parser.add_argument('--Lx',
    type    = float, 
    default = 100,
    help    ='The horizontal length of the network''s physical substrate in micrometres.')

parser.add_argument('--LxMax',
    type    = float, 
    default = -1,
    help    ='The horizontal length of the network''s physical substrate in micrometres.')

parser.add_argument('--Ly',
    type    = float,
    default = -1,
    help    ='The vertical length of the network''s physical substrate in micrometres.')

parser.add_argument('--cent_dispersion', 
    type    = float, 
    default = 700.0,
    help    = 'The width of the generalised normal distribution in units of um.')

parser.add_argument('--shape', 
    type    = float, 
    default = 5.0,
    help    = 'Shape parameter beta. Passed to the generalised normal distribution. Value of 2 is normal. ->inf is uniform.')

parser.add_argument('--folder', 
    type    = str, 
    default = 'connectivity_data',
    help    ='The folder where the output files will be stored.')

args = parser.parse_args()

if args.nwiresMax == -1:
    args.nwiresMax = args.nwires
    
if args.seedMax == -1:
    args.seedMax = args.seed

if args.Ly == -1:
    args.Ly = args.Lx

if args.LxMax == -1:
    args.LxMax = args.Lx

mean_length     = args.mean_length
std_length      = args.std_length
shape           = args.shape
cent_dispersion = args.cent_dispersion
Lx              = args.Lx
Ly              = args.Ly
folder          = args.folder

wireList = list(np.unique(np.linspace(args.nwires, args.nwiresMax, args.numSims, dtype = int)))
seedList = range(args.seed, args.seedMax)
LxList   = list(np.unique(np.linspace(args.Lx,     args.LxMax,     args.numSims, dtype = int))) 
print('Seeds: ', list(seedList))
print('Wires: ', list(wireList))
print('Sizes: ', list(LxList))

for nwires in wireList: 
    for seed in seedList:
        for Lx in LxList:
        
            Ly = Lx
            # Generate the network
            wires_dict = wires.generate_wires_distribution(number_of_wires = nwires,
                                                     wire_av_length = mean_length,
                                                     wire_dispersion = std_length,
                                                     gennorm_shape = shape,
                                                     centroid_dispersion= cent_dispersion,
                                                     this_seed = seed,
                                                     Lx = Lx,
                                                     Ly = Ly)


            # Get junctions list and their positions
            wires_dict = wires.detect_junctions(wires_dict)

            # Genreate graph object and adjacency matrix
            wires_dict = wires.generate_graph(wires_dict)

            if not wires.check_connectedness(wires_dict):
                wires_dict = wires.select_largest_component(wires_dict)

            #Calculate network statistics
            wires_dict = wires.analyse_network(wires_dict)

            wires.export_to_matlab(wires_dict, folder = folder)
    
    
'''



nwires          = 2000
mean_length     = 7.1
std_length      = 1.6
shape           = 100.0
cent_dispersion = 350.0
seed            = 1
Lx              = 70
Ly              = 70
folder          = '/import/silo2/joelh/papers/li2020/NewNetworks1/'
seedList = range(10)
wireList = range(600, 3200, 200) 


for nwires in wireList:
    for seed in seedList:
        # Generate the network
        wires_dict = wires.generate_wires_distribution(number_of_wires = nwires,
                                                 wire_av_length = mean_length,
                                                 wire_dispersion = std_length,
                                                 gennorm_shape = shape,
                                                 centroid_dispersion= cent_dispersion,
                                                 this_seed = seed,
                                                 Lx = Lx,
                                                 Ly = Ly)


        # Get junctions list and their positions
        wires_dict = wires.detect_junctions(wires_dict)

        # Genreate graph object and adjacency matrix
        wires_dict = wires.generate_graph(wires_dict)

        if not wires.check_connectedness(wires_dict):
            wires_dict = wires.select_largest_component(wires_dict)

        #Calculate network statistics
        wires_dict = wires.analyse_network(wires_dict)

        wires.export_to_matlab(wires_dict, folder = folder)        
'''
