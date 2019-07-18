from gams import *
import sys
import subprocess
import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
#from collections import orderedDict


if __name__ == "__main__":
    if len(sys.argv) > 1:
        ws = GamsWorkspace(system_directory = sys.argv[1])
    else:
        ws = GamsWorkspace()

    # add a new GamsDatabase and initialize it from the GDX file
    output_ra = ws.add_database_from_gdx("C:/Users/ba62very/MyGit/risk-aversion/GAMS/test_400_1_d.gdx")
    # store welfare results in a multidimensional dictionary
    scen_2_welf_dict = dict( (tuple(rec.keys), rec.value) for rec in output_ra["Results_welfare_scenario_all"] )
    # print welfare dictionary
    #print("Welfare per scenario:")
    #for rec in scen_2_welf_dict:
    #    print("  ", rec, ":", scen_2_welf_dict[rec])
    # order dictionary by welfare from lowest to highest
    def takeSecond(elem):
    	return elem[1]
    scen_welf_lists = sorted(scen_2_welf_dict.items(), key=takeSecond)
    #print(scen_welf_lists)
    # create two separate lists for plotting
    scen, welfare = zip(*scen_welf_lists)
    #print(welfare)
    #print(scen)
    indexes = np.arange(len(scen))
    width = 1
    # plot welfare for each scenario
    plt.figure(figsize=(10,10), dpi=80)
    plt.grid(True)
    plt.title('Welfare per Scenario [Euro]')
    plt.bar(indexes,welfare,width)
    plt.xticks(indexes + width*0.5, scen, rotation = 90 )
    plt.tight_layout()
    #plt.show()
    plt.savefig('welfare_per_scenario.png')
    plt.close()
    #print(len(scen))
    #print(scen[1])
    # get probabilities for each scenario from gdx
    scen_2_prob_dict = dict( (tuple(rec.keys), rec.value) for rec in output_ra["prob_scen"] )
    #print("Probability per scenario:")
    #for rec in scen_2_prob_dict:
    #    print("  ", rec, ":", scen_2_prob_dict[rec])
    # create welfare 2 probability dictionary
    welf_2_prob_dict = dict()
    for scen in scen_2_welf_dict.keys():
    	reduced_scen= scen[1:5]
    #	print(scen)
   # 	print(reduced_scen)
    	welfare = scen_2_welf_dict[scen]
    	probability = scen_2_prob_dict[reduced_scen]
    	welf_2_prob_dict[welfare] = probability
    welf_prob_lists = sorted(welf_2_prob_dict.items())
    #print(welf_prob_lists)
    welfare, prob = zip(*welf_prob_lists)
    cum_prob = np.cumsum(prob)
    #print("cum prob:")
    #print(cum_prob)
    # plot CDF
    plt.figure(figsize=(10,6), dpi=80)
    plt.grid(True)
    plt.title("Cumulative Distribution Function")
    plt.step(welfare, cum_prob)
    plt.xlabel('Welfare (€)')
    plt.ylabel('cumulative probability')
    #plt.show()
    plt.savefig('CDF.png')
    plt.close()
    # testing
    #for welf in welf_2_prob_dict.keys():
    #	print(welf, ":", welf_2_prob_dict[welf])

    # order welfare 2 probability scenario

