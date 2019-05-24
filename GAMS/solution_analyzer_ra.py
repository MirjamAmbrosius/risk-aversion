from gams import *
import sys
import subprocess
import os
import matplotlib as mpl
import matplotlib.pyplot as plt


if __name__ == "__main__":
    if len(sys.argv) > 1:
        ws = GamsWorkspace(system_directory = sys.argv[1])
    else:
        ws = GamsWorkspace()

    # add a new GamsDatabase and initialize it from the GDX file
    output_ra = ws.add_database_from_gdx("C:/Users/ba62very/MyGit/risk-aversion/GAMS/main_ra.gdx")
    # store welfare results in a multidimensional dictionary
    welf_scen = dict( (tuple(rec.keys), rec.value) for rec in output_ra["Results_welfare_scenario_all"] )
    # print welfare dictionary
    print("Welfare per scenario:")
    for rec in welf_scen:
        print("  ", rec, ":", welf_scen[rec])
    def takeSecond(elem):
    	return elem[1]
    scen_welf_lists = sorted(welf_scen.items(), key=takeSecond)
    print(scen_welf_lists)
    scen, welfare = zip(*scen_welf_lists)
    print(welfare)
    print(scen)
    # plot welfare for each scenario
    plt.figure(figsize=(10,6), dpi=80)
    #plt.xticks([1, 8760/12, 8760/12*2, 8760/12*3, 8760/12*4,8760/12*5,8760/12*6,8760/12*7,8760/12*8,8760/12*9,8760/12*10,8760/12*11], calendar.month_abbr[1:13], rotation = 20 )
    plt.grid(True)
    plt.title('Welfare per Scenario [Euro]')
    plt.plot(welfare)
    plt.savefig('welfare_per_scenario.png')
    plt.close()
    print(len(scen))
    print(scen[1])

    # add probability of each scenario
