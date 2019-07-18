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

if __name__ == "__main__":
    if len(sys.argv) > 1:
        ws = GamsWorkspace(system_directory = sys.argv[1])
    else:
        ws = GamsWorkspace()
    # add a new GamsDatabase and initialize it from the GDX file
    output_ra = ws.add_database_from_gdx("C:/Users/ba62very/MyGit/risk-aversion/GAMS/test_400_1_e_v02.gdx")

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
    #scen_2_cs_dict = dict( (tuple(rec.keys), rec.value) for rec in output_ra["Results_rents_scen_total_cs"] ) 
    #scen_2_ps_dict = dict( (tuple(rec.keys), rec.value) for rec in output_ra["Results_rents_scen_total_ps"] )

### Plot welfare results ###
    def plot_welfare(scen_2_welf_dict):
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
            welf_red_scen_lists = sorted(welf_2_red_scen_dict.items(), key=operator.itemgetter(1))
            if len(welf_red_scen_lists)>0:
                scen,welf_prob_list = zip(*welf_red_scen_lists)
                welf,prob=zip(*welf_prob_list)
                cum_prob = np.cumsum(prob)
                print("Plotting welfare graphs for weight" + str(weight_counter))
                indexes = np.arange(len(scen))
                width = 1
        #       # plot welfare for each scenario
                plt.figure(figsize=(10,6), dpi=80)
                plt.grid(True)
                plt.title("Welfare per Scenario in € (no. of zones: " + str(no_of_zones) + ", weight: " + str((weight_counter-1)*0.2) + ")")
                plt.bar(indexes,welfare,width)
                plt.xticks(indexes + width*0.5, scen, rotation = 90 )
                plt.tight_layout()
                plt.savefig("C:/Users/ba62very/MyGit/risk-aversion/GAMS/solution_handling/plots/welfare_" + str(no_of_zones) + "_" + str((weight_counter-1)*0.2) + ".png")
                plt.close()
            weight_counter +=1
    #plot_welfare(scen_2_welf_dict)

######################## Plot CDF welfare ###########################
    def plot_cdf(scen_2_welf_dict,scen_2_prob_dict):
        print("Plotting CDF Welfare graph")
        plt.figure(figsize=(10,5), dpi=80)
        plt.grid(True)
        plt.title("Cumulative Distribution Function Welfare (no. of zones: " + str(no_of_zones) + ")")
        plt.xlabel('Welfare (€)')
        plt.ylabel('cumulative probability')
    #    Order for weight first
        for weight_counter in range(1,7):
            welf_2_red_scen_dict = {}
            for scen in scen_2_welf_dict.keys():
                weight = int(scen[0])
                if weight == weight_counter:
                    reduced_scen= scen[1:5]
                    welfare = scen_2_welf_dict[scen]
                    prob = scen_2_prob_dict[reduced_scen]
                    welf_2_red_scen_dict[reduced_scen] = (welfare,prob)
            welf_red_scen_lists = sorted(welf_2_red_scen_dict.items(), key=operator.itemgetter(1))
            if len(welf_red_scen_lists)>0:
                scen,welf_prob_list = zip(*welf_red_scen_lists)
                welf,prob=zip(*welf_prob_list)
                cum_prob = np.cumsum(prob)
                plt.step(welf, cum_prob, label = "Weight " + str(round((weight_counter-1)*0.2,2)))
            weight_counter +=1
        legend = plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.01), ncol=3)
        plt.savefig("C:/Users/ba62very/MyGit/risk-aversion/GAMS/solution_handling/plots/CDF_Welfare_" + str(no_of_zones) + ".png")
        plt.close()      
    plot_cdf(scen_2_welf_dict,scen_2_prob_dict)          

######################## Plot CDF CS ###########################
    def plot_cdf_rents(scen_2_rents_dict,rent_type):
        print("Plotting CDF rents graph")
        plt.figure(figsize=(10,5), dpi=80) 
        plt.grid(True)
        plt.title("Cumulative Distribution Function Consumer Surplus (no. of zones: " + str(no_of_zones) + ")")
        plt.xlabel('Consumer Surplus (€)')
        plt.ylabel('cumulative probability')
#     Order for weight first
        for weight_counter in range(1,7):
            red_scen_2_rents_dict = {}
            for scen in scen_2_rents_dict.keys():
                weight = int(scen[0])
                if weight == weight_counter:
                    #print(scen)
                    reduced_scen= scen[1:5]
                    #print(reduced_scen)
                    cons_surplus = scen_2_rents_dict[scen]
                    prob = scen_2_prob_dict[reduced_scen]
                    red_scen_2_rents_dict[reduced_scen] = (cons_surplus,prob)
            red_scen_rents_lists = sorted(red_scen_2_rents_dict.items(), key=operator.itemgetter(1))
            if len(red_scen_rents_lists)>0:
                scen,rents_prob_list = zip(*red_scen_rents_lists)
                rent,prob=zip(*rents_prob_list)
                cum_prob = np.cumsum(prob)
                plt.step(rent, cum_prob, label = "Weight " + str(round((weight_counter-1)*0.2,2)))
            weight_counter +=1
        legend = plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.01), ncol=3)
        plt.savefig("C:/Users/ba62very/MyGit/risk-aversion/GAMS/solution_handling/plots/CDF_" + str(rent_type) + "_" + str(no_of_zones) + ".png")
        plt.close()
    #plot_cdf_rents(scen_2_cs_dict,"cs")
    #plot_cdf_rents(scen_2_ps_dict,"ps")



#class gdx.File(filename='C:/Users/ba62very/MyGit/risk-aversion/GAMS/main_ra_1Zone.gdx', lazy=True, implicit=True)

###################################### write latex tables ###############################
    #TODO: convert GAMS code for creating result tables
    ### Generation and Transmission Capacity Investment ###
        # store investment results in a multidimensional dictionary
    weight_2_gen_2_inv_dict = dict( (tuple(rec.keys), rec.value) for rec in output_ra["Results_genInv"] )
    print(weight_2_gen_2_inv_dict)
    print(weight_2_gen_2_inv_dict.keys())
    #for weight in range(1,7):
    #    for generator in range(1,8):
    #        print("Weight: " + str(weight) + "Generator: " + str(generator) + str(weight_2_gen_2_inv_dict['1']['5']))





    

### plot single  CDF graphs ###
    
    # create welfare 2 probability dictionary
 #   for weight_counter in range(1,7):
 #       welf_2_prob_dict=dict()
 #       for scen in scen_2_welf_dict.keys(): 
 #           weight = int(scen[0])
 #           if weight == weight_counter:
 #               reduced_scen= scen[1:5]
 #               welfare = scen_2_welf_dict[scen]
 #               probability = scen_2_prob_dict[reduced_scen]
 #               welf_2_prob_dict[welfare] = probability
 #       welf_prob_lists = sorted(welf_2_prob_dict.items())
 #       if len(welf_prob_lists)>0:
 #           welfare, prob = zip(*welf_prob_lists)
 #           #print(welfare)
 #           cum_prob = np.cumsum(prob)
 #           # plot CDF
 #           plt.figure(figsize=(10,6), dpi=80)
 #           plt.grid(True)
 #           plt.title("Cumulative Distribution Function (no. of zones: " + str(no_of_zones) + ", weight: " + str((weight_counter-1)*0.2) + ")")
 #           plt.step(welfare, cum_prob)
 #           plt.xlabel('Welfare (€)')
 #           plt.ylabel('cumulative probability')
 #           #plt.show()
 #           plt.savefig("C:/Users/ba62very/MyGit/risk-aversion/GAMS/solution_handling/plots/CDF_" + str(no_of_zones) + "_" + str((weight_counter-1)*0.2) + ".png")
 #           plt.close()
 #           # plot CDF
 #           cum_prob = np.cumsum(prob)
 #           plt.step(welfare, cum_prob, label = "Weight " + str(round((weight_counter-1)*0.2,2)))
 #       weight_counter +=1
 #   #plt.show()
 #   legend = plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.01), ncol=3)
 #   plt.savefig("C:/Users/ba62very/MyGit/risk-aversion/GAMS/solution_handling/plots/CDFNEU_" + str(no_of_zones) + ".png")
 #   plt.close()
    
    

