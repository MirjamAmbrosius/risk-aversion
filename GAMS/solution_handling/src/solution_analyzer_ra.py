from gams import *
import sys
import subprocess
import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import logging
#from collections import orderedDict
logger = logging.getLogger(__name__)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        ws = GamsWorkspace(system_directory = sys.argv[1])
    else:
        ws = GamsWorkspace()
    # add a new GamsDatabase and initialize it from the GDX file
    output_ra = ws.add_database_from_gdx("C:/Users/ba62very/MyGit/risk-aversion/GAMS/main_ra.gdx")

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

### Plot welfare results ###
    logger.info("plot welfare results")
    # Order for weight first
    for weight_counter in range(1,6):
        welf_2_red_scen_dict = dict()
        for scen in scen_2_welf_dict.keys():
            weight = int(scen[0])
            if weight == weight_counter:
                reduced_scen= scen[1:5]
                welfare = scen_2_welf_dict[scen]
                welf_2_red_scen_dict[welfare] = reduced_scen
        welf_red_scen_lists = sorted(welf_2_red_scen_dict.items())
        if len(welf_red_scen_lists)>0:
            welfare, scen = zip(*welf_red_scen_lists)
            indexes = np.arange(len(scen))
            width = 1
            # plot welfare for each scenario
            plt.figure(figsize=(10,6), dpi=80)
            plt.grid(True)
            plt.title("Welfare per Scenario in € (no. of zones: " + str(no_of_zones) + ", weight: " + str((weight_counter-1)*0.2) + ")")
            plt.bar(indexes,welfare,width)
            plt.xticks(indexes + width*0.5, scen, rotation = 90 )
            plt.tight_layout()
            #plt.show()
            plt.savefig("C:/Users/ba62very/MyGit/risk-aversion/GAMS/solution_handling/plots/welfare_" + str(no_of_zones) + "_" + str((weight_counter-1)*0.2) + ".png")
            plt.close()
        weight_counter +=1

### plot CDF ###
    # get probabilities for each scenario from gdx
    scen_2_prob_dict = dict( (tuple(rec.keys), rec.value) for rec in output_ra["prob_scen"] )
    # create welfare 2 probability dictionary
    for weight_counter in range(1,6):
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
    ### write latex tables ###
    #TODO: convert GAMS code for creating result tables



