Parameters
unit "mio" / 1000000 /;

*** Write texfile with results overview
file solution/Results2Nodes.tex/;
put solution;

*** Write Header for tex-file ***

put "\documentclass[]{article}" /;
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
put "Overview Results "
put system.date /;

*** Write Input Table ***

*put "\begin{table}[htb]\caption{Input Parameters Demand}"/;
*put "\begin{tabular}{l|rrrrrrr}" /;
*put "\toprule" /;
*put " period & Occurence & Ref. Demand & Ref. Price \\" /;
*put "\midrule" /;
*loop(T,
*  put ord(T),
*         "&", periodScale(T),
*         "&", dRef(T),
*         "&", pRef(T),
*
*  "\\" /;
*);
*put "\bottomrule" /;
*put "\end{tabular}" /;
*put "\end{table}" /;

put "\begin{table}[htb]\caption{Summary of generation capacity}"/;
put "\begin{tabular}{l|rrrrrr|rr|r|r}" /;
put "\toprule" /;
put " P(k=1) &    Coal &     CCGT &      GT &   Coal  &   CCGT &      GT &    Wind &    Wind  &    Line   &  Welf   \\" /;
put "        &      MW &       MW &      MW &      MW &     MW &      MW &      MW &      MW  &    MW     &  TEUR   \\" /;
put "        &       N &       N  &      N  &      S  &      S &       S &       N &       S  &    N-S    &   NS    \\" /;
put "\midrule" /;
loop(Loop_Probability,
  put (1 - (ord(Loop_Probability)-1) * 0.1),
         "&", Results_genInv(Loop_Probability, "1"),
         "&", Results_genInv(Loop_Probability, "2"),
         "&", Results_genInv(Loop_Probability, "3"),
         "&", Results_genInv(Loop_Probability, "4"),
         "&", Results_genInv(Loop_Probability, "5"),
         "&", Results_genInv(Loop_Probability, "6"),
         "&", Results_genInv(Loop_Probability, "7"),
         "&", Results_genInv(Loop_Probability, "8"),
         "&", Results_lineInv(Loop_Probability),
*         "&", ((Results_welfare_all(Loop_Probability) - Results_welfare_all('1'))/1e3),
  "\\" /;
);
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;

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



$ontext
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



