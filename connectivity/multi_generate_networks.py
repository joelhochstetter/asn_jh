#!/usr/bin/env python
# -*- coding: utf-8 -*-

# This code produces multiple nanowire networks of specified parameters into folder    

import wires
import numpy as np

nwires          = 100.0
mean_length     = 100.0
std_length      = 10.0
shape           = 100.0
cent_dispersion = 350.0
seed            = 42
Lx              = 3e3
Ly              = 3e3
folder          = '/import/silo2/joelh/Evolution/Networks'


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


"""
#then loop over this shit
for nwires in nwiresList:
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
    """    
    
nwires          = 500
mean_length     = 100.0
std_length      = 10.0
shape           = 100.0
cent_dispersion = 350.0
seed            = 42
Lx              = 3e3
Ly              = 3e3
folder          = '/import/silo2/joelh/Evolution/Networks'

cent_dispersionList = np.arange(125,410,50)
"""
for cent_dispersion in cent_dispersionList:
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
"""
nwires          = 500
mean_length     = 100.0
std_length      = 10.0
shape           = 100.0
cent_dispersion = 350.0
seed            = 42
Lx              = 3e3
Ly              = 3e3
folder          = '/import/silo2/joelh/Evolution/Networks/ChangeMeanLength'

lengthList = np.arange(50,300,25)

for mean_length in lengthList:
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


"""

nwires          = 500
mean_length     = 100.0
std_length      = 10.0
shape           = 100.0
cent_dispersion = 350.0
seed            = 42
Lx              = 3e3
Ly              = 3e3
folder          = '/import/silo2/joelh/Evolution/Networks/ChangeStdLength'

stdList    = [1.0, 2.5, 5.0, 7.5, 10.0, 25.0, 50.0, 75.0, 100.0, 250.0];

for std_length in stdList:
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


nwires          = 500
mean_length     = 100.0
std_length      = 10.0
shape           = 100.0
cent_dispersion = 350.0
seed            = 42
Lx              = 3e3
Ly              = 3e3
folder          = '/import/silo2/joelh/Evolution/Networks/ChangeShape'

shapeList = [1.0, 2.5, 5.0, 7.5, 10.0, 25.0, 50.0, 75.0, 100.0, 250.0];

for shape in shapeList:
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

"""

