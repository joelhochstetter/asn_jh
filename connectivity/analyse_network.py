#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This script computes basic metrics to characterize thte topology of
the network.

.. moduleauthor:: Miro Astore
"""

import networkx as nx 
import numpy as np
import scipy.io


def analyse_network(file_name):
    wires_dict = scipy.io.loadmat(file_name)
    graph = nx.from_numpy_matrix(wires_dict['adj_matrix'])

    
    print wires_dict['this_seed']
    
    diameter = nx.diameter(graph)
    print 'diameter: ' + str(diameter)
    
    
    #Computes shortest paths as a matrix
    #path_lengths = nx.shortest_path_length(graph)
    #path_length_mat = np.zeros((nx.number_of_nodes(graph), nx.number_of_nodes(graph)))
    #for i in range(0, nx.number_of_nodes(graph)):
    #    for j in range(0, nx.number_of_nodes(graph)):
    #        path_length_mat[i][j] = path_lengths[i][j]
    #
    #charpath = np.sum(path_length_mat)/(nx.number_of_nodes(graph))/(nx.number_of_nodes(graph)-1)
    #print 'characteristic path length: ' + str(charpath)    
    
    #shortpath = min(path_lengths)
    #print str(min(path_lengths))
    #print str(np.mean(path_lengths))
    #print str(min(path_lengths))
    #for i in range(0,nx.number_of_nodes(graph)):
    #    for j in range(0,nx.number_of_nodes(graph)):
    #        mean(path_lengths)
    
    
    charpath = nx.average_shortest_path_length(graph)
    print 'characteristic path length: ' + str(charpath)
    
    density = nx.density(graph)
    print 'density: ' + str(density)
    
    circuit_rank = nx.number_of_edges(graph) - nx.number_of_nodes(graph) + nx.number_connected_components(graph)
    print 'circuit rank: ' + str(circuit_rank)
    
    avg_nd = nx.number_of_edges(graph)*2.0/nx.number_of_nodes(graph)
    print 'average node degree: ' + str(avg_nd)
    
    #print all nodes connected to n-th node [n for n in graph[n]]
    degrees = np.sum(wires_dict['adj_matrix'], axis=0) #sums along columns
    std_nd = np.std(degrees)
    print 'standard deviation of node degree: ' + str(std_nd)
    
    return dict(number_of_wires = wires_dict['number_of_wires'],
                number_of_junctions = wires_dict['number_of_junctions'],
                diameter = diameter,
                charpath = charpath,
                circuit_rank = circuit_rank,
                avg_nd = avg_nd,
                std_nd = std_nd)

if __name__ == '__main__':
    analyse_network('connectivity_data/2016-09-08-153543_asn_nw_02048_nj_11469_seed_042_avl_28.00_disp_10.00.mat')
    

