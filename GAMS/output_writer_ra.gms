Parameters
unit "mio" / 1000000 /
*Demand_S(T,S_dlev);

*Demand_S(T,S_dlev) = dRef(T) * dem_level(S_dlev) ;

*** Write texfile with results overview
file solution/ResultsRiskAversion.tex/;
put solution;

*** Write Header for tex-file ***

put "\documentclass[landscape]{article}" /;
put "\usepackage[a4paper,top=1cm,bottom=2cm,left=2cm,right=2cm]{geometry}" /;
put "\usepackage{booktabs}" /;
put "\usepackage{siunitx}" /;
put "\sisetup{round-mode=places,round-precision=2}" /;
put "\usepackage[official]{eurosym}" /;
put "\usepackage{caption}" /;
put "\captionsetup{justification=raggedright,singlelinecheck=false}" /;
put "\usepackage{pgfplotstable}" /;
put "\usepackage{pgfplots}" /;
put "\begin{document}" /;
put "Overview Results Risk Aversion "
put system.date, "\\" /;

*** Write Input Table ***

put "Input Parameters", "\\" /;
put "P(low co2 cost)= ", prob_co2("low_co2"), "\\" /;
put "P(medium co2 cost)= ", prob_co2("medium_co2"), "\\" /;
put "P(high co2 cost)= ", prob_co2("high_co2"), "\\"/;
put "P(north)= ", prob_dloc("north"), "\\"/;
put "P(base)= ", prob_dloc("base"), "\\"/;
put "P(south)= ", prob_dloc("south"), "\\"/;
put "P(low demand level)= ", prob_dlev("low_dlev"), "\\"/;
put "P(medium demand level)= ", prob_dlev("medium_dlev"), "\\"/;
put "P(high demand level)= ", prob_dlev("high_dlev"), "\\"/;
put "P(low line cost)= ", prob_lcost("low_lcost"), "\\"/;
put "P(high line cost)= ", prob_lcost("high_lcost"), "\\"/;
put "number of zones= ", '%no_of_zones%', "\\"/;

put "Generator Data", "\\" /;
put "\begin{table}[htb]\caption{Input Data Generators}"/;
put "\begin{tabular}{lrrrr}" /;
put "\toprule" /;
put "Generator & Investment Cost (\euro/MW) & Variable Cost low (\euro/MWh) & Variable Cost medium (\euro/MWh) & Variable Cost high (\euro/MWh) \\" /;
put "\midrule" /;
put "Coal N &",genFixInv("1"),   "&", genVarInv("1","low_CO2"),  "&", genVarInv("1","medium_CO2"),  "&", genVarInv("1","high_CO2"), "\\" /;
put "CCGT N &",genFixInv("2"),   "&", genVarInv("2","low_CO2"),  "&", genVarInv("2","medium_CO2"),  "&", genVarInv("2","high_CO2"), "\\" /;
put "GT N &",genFixInv("3"),     "&", genVarInv("3","low_CO2"),  "&", genVarInv("3","medium_CO2"),  "&", genVarInv("3","high_CO2"), "\\" /;
put "Coal S &",genFixInv("4"),   "&", genVarInv("4","low_CO2"),  "&", genVarInv("4","medium_CO2"),  "&", genVarInv("4","high_CO2"), "\\" /;
put "CCGT S &",genFixInv("5"),   "&", genVarInv("5","low_CO2"),  "&", genVarInv("5","medium_CO2"),  "&", genVarInv("5","high_CO2"), "\\" /;
put "GT S &",genFixInv("6"),     "&", genVarInv("6","low_CO2"),  "&", genVarInv("6","medium_CO2"),  "&", genVarInv("6","high_CO2"), "\\" /;
put "Wind N &",genFixInv("7"),   "&", genVarInv("7","low_CO2"),  "&", genVarInv("7","medium_CO2"),  "&", genVarInv("7","high_CO2"), "\\" /;
put "Wind S &",genFixInv("8"),   "&", genVarInv("8","low_CO2"),  "&", genVarInv("8","medium_CO2"),  "&", genVarInv("8","high_CO2"), "\\" /;
put "BU N &",genFixInv("6"),     "&", buVarInv("low_CO2"),       "&", buVarInv("medium_CO2"),       "&", buVarInv("high_CO2"),      "\\" /;
put "BU S &",genFixInv("6"),     "&", buVarInv("low_CO2"),       "&", buVarInv("medium_CO2"),       "&", buVarInv("high_CO2"),      "\\" /;
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;

put "Demand Data", "\\" /;
put "\begin{table}[htb]\caption{Input Data Generators}"/;
put "\begin{tabular}{lrrrrr}" /;
put "\toprule" /;
put "Hour & Occurence & ref. Price & peak demand low & peak demand medium & peak demand high \\" /;
loop (T,
    put T.val, "&", periodScale(T), "&", pRef(T) "&", dRef(T,"low_dlev"), "&", dRef(T,"medium_dlev"), "&", dRef(T,"high_dlev"),
    "\\" /;
    );
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;

put "\clearpage" /;

put "Transmission Investment Cost (high):", (L_cost("high_lcost")*100), "\euro/MWh", "\\" /; 
put "Transmission Investment Cost (low):", (L_cost("low_lcost")*100), "\euro/MWh", "\\" /;
put "Demand Ratio (scenario north):", qPeak("1","north"), " at node 1 and ", qPeak("2","north"), " at node 2", "\\" /;
put "Demand Ratio (scenario benchmark):", qPeak("1","base"), " at node 1 and ", qPeak("2","base"), " at node 2", "\\" /;
put "Demand Ratio (scenario south):", qPeak("1","south"), " at node 1 and ", qPeak("2","south"), " at node 2", "\\" /;


put "\begin{table}[htb]\caption{Summary of generation capacity}"/;
put "\begin{tabular}{l|rrrrrr|rr|rr|rr|rr}" /;
put "\toprule" /;
put " weight &    Coal &     CCGT &      GT &   Coal  &   CCGT &      GT &    Wind &    Wind  &  BU  &  BU  & totalInv  &    Line   &  Spotprice   &  Welf   \\" /;
put "        &      MW &       MW &      MW &      MW &     MW &      MW &      MW &      MW  &  MW  &  MW  &    MW     &    MW     &  \euro/MWh &  T\euro   \\" /;
put "        &       N &       N  &      N  &      S  &      S &       S &       N &       S  &  N   &  S   &    NS     &    N-S    &  NS      &   NS    \\" /;
put "\midrule" /;
loop(Weight,
  put ((Weight.val-1)*0.2),
         "&", Results_genInv(Weight,"1"),
         "&", Results_genInv(Weight,"2"),
         "&", Results_genInv(Weight,"3"),
         "&", Results_genInv(Weight,"4"),
         "&", Results_genInv(Weight,"5"),
         "&", Results_genInv(Weight,"6"),
         "&", Results_genInv(Weight,"7"),
         "&", Results_genInv(Weight,"8"),
         "&", Results_buInv(Weight, "1"),
         "&", Results_buInv(Weight, "2"),
         "&", Results_totalInv(Weight),
         "&", Results_lineInv(Weight),
         "&", Results_expPriceSpot(Weight),
         "&", ((Results_welfare_all(Weight))/1000),
  "\\" /;
  );
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;
put "\clearpage" /;

$ontext

*** Write Producer Surplus Table ***

put "\begin{table}[htb]\caption{Producer Surplus (\euro)}"/;
put "\begin{tabular}{l|rrrrrrrr}" /;
put "\toprule" /;
put " P(k=1) & $s1_N$ & $s1_S$ & $s2_N$ & $s2_S$   & $s4_N$ & $s4_S$  & $s5_N$ & $s5_S$ \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{", (sum(G$(genAtNode(G) = 1), Results_profits_PS(Loop_Probability, G,"1")) ), "}",
         "&\num{", (sum(G$(genAtNode(G) = 2), Results_profits_PS(Loop_Probability, G,"1")) ), "}",
         "&\num{", (sum(G$(genAtNode(G) = 4), Results_profits_PS(Loop_Probability, G,"1")) ), "}",
         "&\num{", (sum(G$(genAtNode(G) = 5), Results_profits_PS(Loop_Probability, G,"1")) ), "}",
         "&\num{", (sum(G$(genAtNode(G) = 1), Results_profits_PS(Loop_Probability, G,"2")) ), "}",
         "&\num{", (sum(G$(genAtNode(G) = 2), Results_profits_PS(Loop_Probability, G,"2")) ), "}",
         "&\num{", (sum(G$(genAtNode(G) = 4), Results_profits_PS(Loop_Probability, G,"2")) ), "}",
         "&\num{", (sum(G$(genAtNode(G) = 5), Results_profits_PS(Loop_Probability, G,"2")) ), "}",
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;




*** Write Results Welfare Summary Table ***

put "\begin{table}[htb]\caption{Changes in Welfare and Redispatch costs}"/;
put "\begin{tabular}{l|rrrrrrr}" /;
put "\toprule" /;
put " P(k=1) & $\Delta$w & $\Delta CS_{n1,UP}$ & $\Delta CS_{n1,ZP}$ & $\Delta CS_{n2,UP}$ & $\Delta CS_{n2,ZP}$ & $cost^{RD}_{s1}$& $cost^{RD}_{s2}$ \\" /;
put " & 1000\euro & 1000\euro & 1000\euro & 1000\euro & 1000\euro & 1000\euro & 1000\euro \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&", ((Results_total_welfare(Loop_Probability)-Results_total_welfare('1'))/1e3),
         "&", ((Results_rents_CS(Loop_Probability,'1','1') - Results_rents_CS('1','1','1') )$Loop_Probability_results(Loop_Probability,'1') / 1e3 ),
         "&", ((Results_rents_CS(Loop_Probability,'1','2') - Results_rents_CS('1','1','1') )$Loop_Probability_results(Loop_Probability,'2') / 1e3 ),
         "&", ((Results_rents_CS(Loop_Probability,'2','1') - Results_rents_CS('1','2','1') )$Loop_Probability_results(Loop_Probability,'1') / 1e3 ),
         "&", ((Results_rents_CS(Loop_Probability,'2','2') - Results_rents_CS('1','2','1') )$Loop_Probability_results(Loop_Probability,'2') / 1e3 ),
         "&", ((sum(S$Probability(S), Probability(S) * Results_rents_CS(Loop_Probability,'1',S) ) - Results_rents_CS('1','1','1') ) / 1e3 ),
         "&", ((sum(S$Probability(S), Probability(S) * Results_rents_CS(Loop_Probability,'2',S) ) - Results_rents_CS('1','2','1') ) / 1e3 ),
*         "&", (Results_networkRev(Loop_Probability,'2')),
*         "&", (Results_avgPriceSpot(Loop_Probability,'1')$Loop_Probability_results(Loop_Probability,'1')),
*         "&", (Results_avgPriceSpot(Loop_Probability,'2')$Loop_Probability_results(Loop_Probability,'2')),
*         "&", (sum(g, Results_genInv(Loop_Probability, G))),
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;


*** Write Results Summary Table ***

put "\begin{table}[htb]\caption{Changes in Welfare and Redispatch costs}"/;
put "\begin{tabular}{l|rrrrrrr}" /;
put "\toprule" /;
put " P(k=1) & $\Delta$w & $\Delta w_{S1}$ & $\Delta w_{S2}$ & $w^{spot}_{s1}$ & $w^{spot}_{s2}$ & $cost^{RD}_{s1}$& $cost^{RD}_{s2}$ \\" /;
put " & 1000\euro & 1000\euro & 1000\euro & 1000\euro & 1000\euro & 1000\euro & 1000\euro \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&", ((Results_total_welfare(Loop_Probability)-Results_total_welfare('1'))/1e3),
         "&", ((Results_welfare_spot(Loop_Probability,'1')$Loop_Probability_results(Loop_Probability,'1')-Results_welfare_spot('1','1')$Loop_Probability_results(Loop_Probability,'1')-Results_rediCost(Loop_Probability,'1')+Results_rediCost('1','1')$Loop_Probability_results(Loop_Probability,'1'))/1e3),
         "&", ((Results_welfare_spot(Loop_Probability,'2')$Loop_Probability_results(Loop_Probability,'2')-Results_welfare_spot('1','1')$Loop_Probability_results(Loop_Probability,'2')-Results_rediCost(Loop_Probability,'2')+Results_rediCost('1','1')$Loop_Probability_results(Loop_Probability,'2'))/1e3),
         "&", ((Results_welfare_spot(Loop_Probability,'1')$Loop_Probability_results(Loop_Probability,'1')-Results_welfare_spot('1','1')$Loop_Probability_results(Loop_Probability,'1'))/1e3),
         "&", ((Results_welfare_spot(Loop_Probability,'2')$Loop_Probability_results(Loop_Probability,'2')-Results_welfare_spot('1','1')$Loop_Probability_results(Loop_Probability,'2'))/1e3),
         "&", ((Results_rediCost(Loop_Probability,'1')-Results_rediCost('1','1')$Loop_Probability_results(Loop_Probability,'1'))/1e3),
         "&", ((Results_rediCost(Loop_Probability,'2')-Results_rediCost('1','1')$Loop_Probability_results(Loop_Probability,'2'))/1e3),
*         "&", (Results_networkRev(Loop_Probability,'2')),
*         "&", (Results_avgPriceSpot(Loop_Probability,'1')$Loop_Probability_results(Loop_Probability,'1')),
*         "&", (Results_avgPriceSpot(Loop_Probability,'2')$Loop_Probability_results(Loop_Probability,'2')),
*         "&", (sum(g, Results_genInv(Loop_Probability, G))),
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;



put "\begin{table}[htb]\caption{Summary of welfare and prices}"/;
put "\begin{tabular}{l|rrrrr}" /;
put "\toprule" /;
put " P(k=1) & $\Delta$ Welfare & $ p^{wavg}$ & $p^{corr}_{S1}$ & $p^{corr}_{S2}$ & $c^{inv}_{lines}$ \\" /;
put " & \euro & \euro / MWh & \euro / MWh & \euro / MWh & \euro  \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{", (Results_total_welfare(Loop_Probability)-Results_total_welfare("1")), "}"  ,
         "&", Results_totalAvgPriceSpot(Loop_Probability),
         "&", (Results_totalAvgPriceSpot(Loop_Probability)$Loop_Probability_results(Loop_Probability,'1') + Results_networkFee(Loop_Probability, "1")$Loop_Probability_results(Loop_Probability,'1')),
         "&", (Results_totalAvgPriceSpot(Loop_Probability)$Loop_Probability_results(Loop_Probability,'2') + Results_networkFee(Loop_Probability, "2")$Loop_Probability_results(Loop_Probability,'2')),
         "&", Results_lineInvCost(Loop_Probability),
*         "&", (sum(g, Results_genInv(Loop_Probability, G))),
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;



*** Write Welfare Table ***

put "\begin{table}[htb]\caption{Welfare (\euro)}"/;
put "\begin{tabular}{l|rrrrrrr}" /;
put "\toprule" /;
put " P(k=1) & $\Delta$ total Welfare & $ s1_{all}$ & $s1_N$ & $s1_S$ & $s2_{all}$ & $s2_N$ & $s2_S$  \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{", (Results_total_welfare(Loop_Probability)-Results_total_welfare("1")),              "}",
         "&\num{", (Results_welfare(Loop_Probability, "1")),               "}",
         "&\num{", (Results_nodal_welfare(Loop_Probability, "1", "1")),    "}",
         "&\num{", (Results_nodal_welfare(Loop_Probability, "1", "2")),    "}",
         "&\num{", (Results_welfare(Loop_Probability, "2")),               "}",
         "&\num{", (Results_nodal_welfare(Loop_Probability, "2", "1")),    "}",
         "&\num{", (Results_nodal_welfare(Loop_Probability, "2", "2")),    "}",
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;

*** Write Consumer Surplus Table ***

put "\begin{table}[htb]\caption{Consumer Surplus (\euro)}"/;
put "\begin{tabular}{l|rrrrrrr}" /;
put "\toprule" /;
put " P(k=1) &$\Delta$ CS & $ s1_{all}$ & $s1_N$ & $s1_S$ & $s2_{all}$ & $s2_N$ & $s2_S$  \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{", (sum((D,S),Results_rents_CS(Loop_Probability,D,S) * Loop_Probability_results(Loop_Probability,S))
                         - sum((D,S),Results_rents_CS("1",D,S) * Loop_Probability_results("1",S))),     "}",
         "&\num{", (sum(D,Results_rents_CS(Loop_Probability,D,"1"))),     "}",
         "&\num{", (Results_rents_CS(Loop_Probability,"1","1")),      "}",
         "&\num{", (Results_rents_CS(Loop_Probability,"2","1")),      "}",
         "&\num{", (sum(D,Results_rents_CS(Loop_Probability,D,"2"))),     "}",
         "&\num{", (Results_rents_CS(Loop_Probability,"1","2")),      "}",
         "&\num{", (Results_rents_CS(Loop_Probability,"2","2")),      "}",
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;



*** Write Generator Surplus Table ***

put "\begin{table}[htb]\caption{Generator Surplus (\euro)}"/;
put "\begin{tabular}{l|rrrrrr|rrrrrrr}" /;
put "\toprule" /;
put " P(k=1) & $g1_{1z}$ & $g1_{2z}$ & $g2_{1z}$ & $g2_{2z}$ & $g3_{1z}$ & $g3_{2z}$ & $g4_{1z}$ & $g4_{2z}$ & $g5_{1z}$ & $g5_{2z}$ & $g6_{1z}$ & $g6_{2z}$  \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{", Results_rents_PS(Loop_Probability,"1","1") , "}",
         "&\num{", Results_rents_PS(Loop_Probability,"1","2") , "}",
         "&\num{", Results_rents_PS(Loop_Probability,"2","1") , "}",
         "&\num{", Results_rents_PS(Loop_Probability,"2","2") , "}",
         "&\num{", Results_rents_PS(Loop_Probability,"3","1") , "}",
         "&\num{", Results_rents_PS(Loop_Probability,"3","2") , "}",
         "&\num{", Results_rents_PS(Loop_Probability,"4","1") , "}",
         "&\num{", Results_rents_PS(Loop_Probability,"4","2") , "}",
         "&\num{", Results_rents_PS(Loop_Probability,"5","1") , "}",
         "&\num{", Results_rents_PS(Loop_Probability,"5","2") , "}",
         "&\num{", Results_rents_PS(Loop_Probability,"6","1") , "}",
         "&\num{", Results_rents_PS(Loop_Probability,"6","2") , "}",
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;


*** Write Redispatch Cost Table ***

put "\begin{table}[htb]\caption{Redispatch Cost (\euro)}"/;
put "\begin{tabular}{l|rrrrrrr}" /;
put "\toprule" /;
put " P(k=1) & total & $ Line_{all}$ & $BUFix_{all}$ & $genVar_{s1}$ & $BuVar_{s1}$ & $genVar_{s2}$ & $BuVar_{s2}$  \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{",  Results_totalRediCost(Loop_Probability),     "}",
         "&\num{",  Results_lineInvCost(Loop_Probability),     "}",
         "&\num{",  Results_buCost(Loop_Probability),      "}",
         "&\num{",  Results_RediGenCost(Loop_Probability, "1"),      "}",
         "&\num{",  Results_RediBuCost(Loop_Probability, "1"),      "}",
         "&\num{",  Results_RediGenCost(Loop_Probability, "2"),      "}",
         "&\num{",  Results_RediBuCost(Loop_Probability, "2"),      "}",
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;

*** Write Prices Table ***

put "\begin{table}[htb]\caption{Prices (\euro / MWh)}"/;
put "\begin{tabular}{l|rrrrrrr}" /;
put "\toprule" /;
put " P(k=1) & $all_{wavg}$ & $ s1_{wavg}$ & $s1_N$ & $s1_S$ & $s2_{wavg}$ & $s2_N$ & $s2_S$  \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{",  Results_totalAvgPriceSpot(Loop_Probability)                          , "}",
         "&\num{",  Results_avgPriceSpot(Loop_Probability,"1")      , "}",
         "&\num{",  Results_nodalAvgPriceSpot(Loop_Probability,"1","1")                     , "}",
         "&\num{",  Results_nodalAvgPriceSpot(Loop_Probability,"1","2")                     , "}",
         "&\num{",  Results_avgPriceSpot(Loop_Probability,"2")      , "}",
         "&\num{",  Results_nodalAvgPriceSpot(Loop_Probability,"2","1")                     , "}",
         "&\num{",  Results_nodalAvgPriceSpot(Loop_Probability,"2","2")                     , "}",
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;


*** Write Demand Table ***

put "\begin{table}[htb]\caption{Demand (MW)}"/;
put "\begin{tabular}{l|rrrrrrr}" /;
put "\toprule" /;
put " P(k=1) & total & $ s1_{all}$ & $s1_N$ & $s1_S$ & $s2_{all}$ & $s2_N$ & $s2_S$  \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{", (sum((S,D,T),probability(S)*Results_demand(Loop_Probability,S,D,T))                  ), "}",
         "&\num{", (sum((D,T),Results_demand(Loop_Probability,"1",D,T))                    ), "}",
         "&\num{", (sum((D,T)$(consAtNode(D) = 1), Results_demand(Loop_Probability,"1",D,T)) ), "}",
         "&\num{", (sum((D,T)$(consAtNode(D) = 2), Results_demand(Loop_Probability,"1",D,T)) ), "}",
         "&\num{", (sum((D,T),Results_demand(Loop_Probability,"2",D,T))                    ), "}",
         "&\num{", (sum((D,T)$(consAtNode(D) = 1), Results_demand(Loop_Probability, "2",D,T)) ), "}",
         "&\num{", (sum((D,T)$(consAtNode(D) = 2), Results_demand(Loop_Probability, "2",D,T)) ), "}",

  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;

*** Write Generation and Flows Table Part 1 ***
*TODO:PeriodScale for hourly values!

put "\begin{table}[htb]\caption{Average Hourly Generation and Flows part 1 (scenario 1)}"/;
put "\begin{tabular}{l|rrrrrrrrr}" /;
put "\toprule" /;
put " P(k=1) & Line & $ BU_{all} $ & $gen_{all}$ & $g_1$ & $g_2$ & $g_3$ & $g_4$ & $g_5$ & $g_6$ \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{", ((sum((L,T),Results_flowFinal(Loop_Probability,"1",L,T))) / card(T))            , "}",
         "&\num{", ((sum((B,T),Results_generationBU(Loop_Probability,"1",B,T)))/card(T))           , "}",
         "&\num{", ((sum((G,T),Results_generation(Loop_Probability,"1",G,T)))/card(T))             , "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"1","1",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"1","2",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"1","3",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"1","4",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"1","5",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"1","6",T)))/card(T)             ), "}",
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;

*** Write Generation and Flows Table Part 2 ***
*TODO:PeriodScale for hourly values!

put "\begin{table}[htb]\caption{Average Hourly Generation and Flows part 2 (scenario 1)}"/;
put "\begin{tabular}{l|rrrrrr}" /;
put "\toprule" /;
put " P(k=1) &  $sum_N$ & $sum_S$ & $g_1 + g_4$ & $g_2+g_5$ & $g_3 + g_6$ \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{", ((sum((G,T)$(genAtNode(G)= 1),Results_generation(Loop_Probability,"1",G,T)))/card(T))             , "}",
         "&\num{", ((sum((G,T)$(genAtNode(G)= 2),Results_generation(Loop_Probability,"1",G,T)))/card(T))             , "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"1","1",T)))/card(T) + (sum(T,Results_generation(Loop_Probability,"1","4",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"1","2",T)))/card(T) + (sum(T,Results_generation(Loop_Probability,"1","5",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"1","3",T)))/card(T) + (sum(T,Results_generation(Loop_Probability,"1","6",T)))/card(T)             ), "}",
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;

*** Write Generation and Flows Table scen 2 Part 1 ***
*TODO:PeriodScale for hourly values!

put "\begin{table}[htb]\caption{Average Hourly Generation and Flows part 1 (scenario 2)}"/;
put "\begin{tabular}{l|rrrrrrrrr}" /;
put "\toprule" /;
put " P(k=1) & Line & $ BU_{all} $ & $gen_{all}$ & $g_1$ & $g_2$ & $g_3$ & $g_4$ & $g_5$ & $g_6$ \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{", ((sum((L,T),Results_flowFinal(Loop_Probability,"2",L,T))) / card(T))            , "}",
         "&\num{", ((sum((B,T),Results_generationBU(Loop_Probability,"2",B,T)))/card(T))           , "}",
         "&\num{", ((sum((G,T),Results_generation(Loop_Probability,"2",G,T)))/card(T))             , "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"2","1",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"2","2",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"2","3",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"2","4",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"2","5",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"2","6",T)))/card(T)             ), "}",
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;

*** Write Generation and Flows Table scen 2 Part 2 ***
*TODO:PeriodScale for hourly values!

put "\begin{table}[htb]\caption{Average Hourly Generation and Flows part 2 (scenario 2)}"/;
put "\begin{tabular}{l|rrrrrr}" /;
put "\toprule" /;
put " P(k=1) &  $sum_N$ & $sum_S$ & $g_1 + g_4$ & $g_2+g_5$ & $g_3 + g_6$ \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{", ((sum((G,T)$(genAtNode(G)= 1),Results_generation(Loop_Probability,"2",G,T)))/card(T))             , "}",
         "&\num{", ((sum((G,T)$(genAtNode(G)= 2),Results_generation(Loop_Probability,"2",G,T)))/card(T))             , "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"1","1",T)))/card(T) + (sum(T,Results_generation(Loop_Probability,"2","4",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"1","2",T)))/card(T) + (sum(T,Results_generation(Loop_Probability,"2","5",T)))/card(T)             ), "}",
         "&\num{", ((sum(T,Results_generation(Loop_Probability,"1","3",T)))/card(T) + (sum(T,Results_generation(Loop_Probability,"2","6",T)))/card(T)             ), "}",
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;

*** Write Utilization Table for Scenario 1 ***
*TODO:PeriodScale for hourly values!

put "\begin{table}[htb]\caption{Average Hourly Average Utilization (scenario 1)}"/;
put "\begin{tabular}{l|rrrrrrrrr}" /;
put "\toprule" /;
put " P(k=1) & Line & $ BU_{1} $& $ BU_{1} $  & $g_1$ & $g_2$ & $g_3$ & $g_4$ & $g_5$ & $g_6$ \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{", Results_avgLineUtilization(Loop_Probability, "1")           , "}",
         "&\num{", Results_avgBuUtilization(Loop_probability, "1", "1")        , "}",
         "&\num{", Results_avgBuUtilization(Loop_probability, "1", "2")        , "}",
         "&\num{", Results_avgGenUtilization(Loop_probability, "1", "1")       , "}",
         "&\num{", Results_avgGenUtilization(Loop_probability, "1", "2")       , "}",
         "&\num{", Results_avgGenUtilization(Loop_probability, "1", "3")       , "}",
         "&\num{", Results_avgGenUtilization(Loop_probability, "1", "4")       , "}",
         "&\num{", Results_avgGenUtilization(Loop_probability, "1", "5")       , "}",
         "&\num{", Results_avgGenUtilization(Loop_probability, "1", "6")       , "}",

  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;

*** Write Utilization Table for Scenario 2 ***
*TODO:PeriodScale for hourly values!

put "\begin{table}[htb]\caption{Average Utilization (scenario 2)}"/;
put "\begin{tabular}{l|rrrrrrrrr}" /;
put "\toprule" /;
put " P(k=1) & Line & $ BU_{1} $& $ BU_{1} $  & $g_1$ & $g_2$ & $g_3$ & $g_4$ & $g_5$ & $g_6$ \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&\num{", Results_avgLineUtilization(Loop_Probability, "2")           , "}",
         "&\num{", Results_avgBuUtilization(Loop_probability, "2", "1")        , "}",
         "&\num{", Results_avgBuUtilization(Loop_probability, "2", "2")        , "}",
         "&\num{", Results_avgGenUtilization(Loop_probability, "2", "1")       , "}",
         "&\num{", Results_avgGenUtilization(Loop_probability, "2", "2")       , "}",
         "&\num{", Results_avgGenUtilization(Loop_probability, "2", "3")       , "}",
         "&\num{", Results_avgGenUtilization(Loop_probability, "2", "4")       , "}",
         "&\num{", Results_avgGenUtilization(Loop_probability, "2", "5")       , "}",
         "&\num{", Results_avgGenUtilization(Loop_probability, "2", "6")       , "}",

  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;


$offtext

put "\end{document}"/;



