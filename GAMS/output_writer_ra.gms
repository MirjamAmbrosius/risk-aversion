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
put "\begin{tabular}{l|rrrrrr|rr|rr|rr|rrrr}" /;
put "\toprule" /;
put " weight &    Coal &     CCGT &      GT &   Coal  &   CCGT &      GT &    Wind &    Wind  &  BU  &  BU  & totalInv  &    Line   &  Spotprice   &  Welf (RA) & Welf (RN)& price RA \\" /;
put "        &      MW &       MW &      MW &      MW &     MW &      MW &      MW &      MW  &  MW  &  MW  &    MW     &    MW     &  \euro/MWh &  T\euro &  T\euro &  T\euro   \\" /;
put "        &       N &       N  &      N  &      S  &      S &       S &       N &       S  &  N   &  S   &    NS     &    N-S    &  NS      &   NS &   NS &   NS   \\" /;
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
         "&", ((Results_wf_rn(Weight))/1000),
         "&", ((Results_risk_adjustment(Weight))/1000),
         
  "\\" /;
  );
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;
put "\clearpage" /;


put "\begin{table}[htb]\caption{Overview Table}"/;
put "\begin{tabular}{lrrrrrrr}" /;
put "\toprule" /;
put " weight &     totalInv & BU  &  BU   &    Line   &  Spotprice   &  delta Welf & price RA \\" /;
put "        &      MW      & MW  &  MW    &    MW     &  \euro/MWh   &  T\euro     &   T\euro   \\" /;
put "        &      NS      & N   &  S    &    N-S    &  NS          &   NS        &   NS    \\" /;
put "\midrule" /;
loop(Weight,
  put ((Weight.val-1)*0.2),
         "&", Results_totalInv(Weight),        
         "&", Results_buInv(Weight, "1"),
         "&", Results_buInv(Weight, "2"),
         "&", Results_lineInv(Weight),
         "&", Results_expPriceSpot(Weight),
         "&", ((Results_welfare_all(Weight) - Results_welfare_all("1")) /1000),
         "&", ((Results_risk_adjustment(Weight))/1000),         
  "\\" /;
  );
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;
put "\clearpage" /;

put "\begin{table}[htb]\caption{Expected PS and CS (\euro, difference to $\omega = 0$) }"/;
put "\begin{tabular}{l|rrrrrrrrrr}" /;
put "\toprule" /;
put " weight &  CCGT &   GT &  Wind  & total &  CCGT &   GT &   Wind &   total  &  CS  & CS   \\" /;
put "        &     N &   N  &    N   &  N    &    S  &    S &       S &    S    &  N  &  S    \\" /;
put "\midrule" /;
loop(Weight,
  put ((Weight.val-1)*0.2),
         "&", ( (Results_exp_rents_ps("1","2") - Results_exp_rents_ps(Weight,"2"))/1000),
         "&", ( (Results_exp_rents_ps("1","3") - Results_exp_rents_ps(Weight,"3"))/1000),
         "&", ( (Results_exp_rents_ps("1","3") - Results_exp_rents_ps(Weight,"7"))/1000),
         "&", ( (Results_exp_rents_ps_node("1","1") - Results_exp_rents_ps_node(Weight,"1"))/1000),         
         "&", ( (Results_exp_rents_ps("1","5") - Results_exp_rents_ps(Weight,"5"))/1000),
         "&", ( (Results_exp_rents_ps("1","6") - Results_exp_rents_ps(Weight,"6"))/1000),
         "&", ( (Results_exp_rents_ps("1","8") - Results_exp_rents_ps(Weight,"8"))/1000),
         "&", ( (Results_exp_rents_ps_node("1","2") - Results_exp_rents_ps_node(Weight,"2"))/1000),
         "&", ( (Results_exp_rents_cs("1","1") - Results_exp_rents_cs(Weight,"1"))/1000),
         "&", ( (Results_exp_rents_cs("1","2") - Results_exp_rents_cs(Weight,"2"))/1000), 
  "\\" /;
  );
put "\bottomrule" /;
put "\end{tabular}" /;
put "\end{table}" /;
put "\clearpage" /;
put "\end{document}"/;



