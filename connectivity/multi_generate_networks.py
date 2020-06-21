#!/usr/bin/env python
# -*- coding: utf-8 -*-

# This code produces multiple nanowire networks of specified parameters into folder    

import wires
import numpy as np

nwires          = 2000
mean_length     = 10.0
std_length      = 2.0
shape           = 100.0
cent_dispersion = 350.0
seed            = 1
Lx              = 150
Ly              = 150
folder          = '/import/silo2/joelh/Criticality/Avalanche/BigNetwork/Lx150Ly150/'
seedList = range(100, 300)

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
