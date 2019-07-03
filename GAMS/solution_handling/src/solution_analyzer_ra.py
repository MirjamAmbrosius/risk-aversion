from gams import *
import sys
import subprocess
import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import logging
import operator
#from collections import orderedDict
logger = logging.getLogger(__name__)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        ws = GamsWorkspace(system_directory = sys.argv[1])
    else:
        ws = GamsWorkspace()
    # add a new GamsDatabase and initialize it from the GDX file
    output_ra = ws.add_database_from_gdx("C:/Users/ba62very/MyGit/risk-aversion/GAMS/main_ra_2Zones.gdx")

    # get number of zones
    node_to_zone_dict = dict( (rec.keys[0], rec.value) for rec in output_ra["NodeInZone"] )
    if node_to_zone_dict["1"] == node_to_zone_dict["2"]:
        no_of_zones = 1
    else:
        no_of_zones = 2
    # TODO: assertion to check whether no of nodes / zones larger than 2
    print("no of zones: " + str(no_of_zones))

    # store welfare results in a multidimensional dictionary
    scen_2_welf_dict = dict( (tuple(rec.keys), rec.value) for rec in output_ra["Results_welfare_scenario_all"] )
    scen_2_prob_dict = dict( (tuple(rec.keys), rec.value) for rec in output_ra["prob_scen"] )

    def takeSecond(elem):
        return elem[4]

### Plot welfare results ###
    logger.info("plot welfare results")
    # Order for weight first
    for weight_counter in range(1,7):
        welf_2_red_scen_dict = {}
        for scen in scen_2_welf_dict.keys():
            weight = int(scen[0])
            if weight == weight_counter:
                reduced_scen= scen[1:5]
                welfare = scen_2_welf_dict[scen]
                prob = scen_2_prob_dict[reduced_scen]
                welf_2_red_scen_dict[reduced_scen] = (welfare,prob)
        #print(welf_2_red_scen_dict[reduced_scen][1])
        #print(len(welf_2_red_scen_dict))
        #welf_red_scen_lists = sorted(welf_2_red_scen_dict.values())
        welf_red_scen_lists = sorted(welf_2_red_scen_dict.items(), key=operator.itemgetter(1))
        #print(welf_red_scen_lists)
        if len(welf_red_scen_lists)>0:
            scen,welf_prob_list = zip(*welf_red_scen_lists)
            print(welf_prob_list)
            welf,prob=zip(*welf_prob_list)
            print(welf)
            print(prob)
        #    indexes = np.arange(len(scen))
        #    width = 1
        #    # plot welfare for each scenario
        #    plt.figure(figsize=(10,6), dpi=80)
        #    plt.grid(True)
        #    plt.title("Welfare per Scenario in € (no. of zones: " + str(no_of_zones) + ", weight: " + str((weight_counter-1)*0.2) + ")")
        #    plt.bar(indexes,welfare,width)
        #    plt.xticks(indexes + width*0.5, scen, rotation = 90 )
        #    plt.tight_layout()
        #    #plt.show()
        #    plt.savefig("C:/Users/ba62very/MyGit/risk-aversion/GAMS/solution_handling/plots/welfare_" + str(no_of_zones) + "_" + str((weight_counter-1)*0.2) + ".png")
        #    plt.close()
        #weight_counter +=1

    #print(len(scen_2_welf_dict))
    

### plot CDF ###
    # get probabilities for each scenario from gdx
    
    # create welfare 2 probability dictionary
    for weight_counter in range(1,7):
        welf_2_prob_dict=dict()
        for scen in scen_2_welf_dict.keys(): 
            weight = int(scen[0])
            if weight == weight_counter:
                reduced_scen= scen[1:5]
                welfare = scen_2_welf_dict[scen]
                probability = scen_2_prob_dict[reduced_scen]
                welf_2_prob_dict[welfare] = probability
        welf_prob_lists = sorted(welf_2_prob_dict.items())
        if len(welf_prob_lists)>0:
            welfare, prob = zip(*welf_prob_lists)
            #print(welfare)
            cum_prob = np.cumsum(prob)
            # plot CDF
            plt.figure(figsize=(10,6), dpi=80)
            plt.grid(True)
            plt.title("Cumulative Distribution Function (no. of zones: " + str(no_of_zones) + ", weight: " + str((weight_counter-1)*0.2) + ")")
            plt.step(welfare, cum_prob)
            plt.xlabel('Welfare (€)')
            plt.ylabel('cumulative probability')
            #plt.show()
            plt.savefig("C:/Users/ba62very/MyGit/risk-aversion/GAMS/solution_handling/plots/CDF_" + str(no_of_zones) + "_" + str((weight_counter-1)*0.2) + ".png")
            plt.close()
        weight_counter +=1
    ### Plot CDF Overview
    # get probabilities for each scenario from gdx
    # create welfare 2 probability dictionary
    plt.figure(figsize=(10,5), dpi=80)
    plt.grid(True)
    plt.title("Cumulative Distribution Function (no. of zones: " + str(no_of_zones) + ")")
    plt.xlabel('Welfare (€)')
    plt.ylabel('cumulative probability')
    for weight_counter in range(1,7):
        welf_2_prob_dict=dict()
        for scen in scen_2_welf_dict.keys(): 
            weight = int(scen[0])
            if weight == weight_counter:
                reduced_scen= scen[1:5]
                welfare = scen_2_welf_dict[scen]
                probability = scen_2_prob_dict[reduced_scen]
                welf_2_prob_dict[welfare] = probability
        welf_prob_lists = sorted(welf_2_prob_dict.items())
        if len(welf_prob_lists)>0:
            welfare, prob = zip(*welf_prob_lists)
            #print(welfare)
            cum_prob = np.cumsum(prob)
            # plot CDF
            
            plt.step(welfare, cum_prob, label = "Weight " + str(round((weight_counter-1)*0.2,2)))
        weight_counter +=1
    #plt.show()
    legend = plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.01), ncol=3)
    plt.savefig("C:/Users/ba62very/MyGit/risk-aversion/GAMS/solution_handling/plots/CDF_" + str(no_of_zones) + ".png")
    plt.close()
    ### write latex tables ###
    #TODO: convert GAMS code for creating result tables
    ### Generation and Transmission Capacity Investment ###
        # store investment results in a multidimensional dictionary
    #weight_2_gen_2_inv_dict = dict( (tuple(rec.keys), rec.value) for rec in output_ra["Results_genInv"] )
    #print(weight_2_gen_2_inv_dict)
    #for weight in range(1,7):
    #    for generator in range(1,8):
    #        print("Weight: " + str(weight) + "Generator: " + str(generator) + str(weight_2_gen_2_inv_dict['1']['5']))



