
***--------------------------------------------------------------------------***
***                             GENERAL OPTIONS                              ***
***--------------------------------------------------------------------------***

option  optcr = 0.0001
        limrow = 0,
*equations listed per block */
        limcol = 0
*variables listed per block */
        solprint = off,
*solver's solution output printed */
        sysout = off,
*define standard solver
        QCP = Gurobi,
        LP = Gurobi
;

***--------------------------------------------------------------------------***
***            OPTIONS FOR DIFFERENT SCENARIOS & LINE INVESTMENT             ***
***--------------------------------------------------------------------------***

*** Choose number of zones (one, two)
$set no_of_zones one

Sets
         L "indices for power lines"     / 2 * 10 /
         LineInvest                      / 2  /
 ;

***--------------------------------------------------------------------------***
***             LOAD DATA AND SETUP FOR LOOP WITH PROBABILITIES              ***
***--------------------------------------------------------------------------***

  
$include input-risk-aversion.gms
$include parameters-risk-aversion.gms
$include model-risk-aversion.gms

*** read gurobi.opt
*  Spotmarket.OptFile = 1 ;
*  RedispatchWelfare.OptFile = 1 ;

*** time after which the solver terminates:
 Spotmarket.reslim = 10000;
 Redispatch.reslim = 36000;

 Alias(LineInvest,LineInvest2) ;

***--------------------------------------------------------------------------***
***           START MODEL LOOP FOR PROBABILITIES AND LINE INVEST             ***
***--------------------------------------------------------------------------***

Loop(LineInvest,

   lineB(L) = 1$(LineInvest.val=L.val);

***--------------------------------------------------------------------------***
***                        SOLVE SPOT MARKET MODEL                           ***
***--------------------------------------------------------------------------***

  option clear= welfareSpot ;
  option clear= d_sp        ;
  option clear= g_sp        ;
  option clear= ig_sp       ;
  option clear= f_sp        ;

  SOLVE Spotmarket USING QCP MAXIMIZE welfareSpot ;

  SP_DEM(S_trans,S_co2,S_dloc,S_dlev,D,T)   =  d_sp.l(S_trans,S_co2,S_dloc,S_dlev,D,T);
  SP_GEN_G(S_trans,S_co2,S_dloc,S_dlev,G,T) = g_sp.l(S_trans,S_co2,S_dloc,S_dlev,G,T)          ;
  SP_CAP_G(G)     = ig_sp.l(G)                                                                 ;
  SP_FLOW(S_trans,S_co2,S_dloc,S_dlev,L,T)  = f_sp.l(S_trans,S_co2,S_dloc,S_dlev,L,T)          ;
  SP_CAP_L(L)     = lineB(L) * lineUB(L)   ;
*  wf_sc_SP(S_trans,S_co2,S_dloc,S_dlev)         = ( sum((D,T), ( consObjA(D,T,S_dlev,S_dloc) * SP_DEM(S_trans,S_co2,S_dloc,S_dlev,D,T)
*                                       - 0.5 * consObjB(D,T,S_dlev,S_dloc) * SP_DEM(S_trans,S_co2,S_dloc,S_dlev,D,T) * SP_DEM(S_trans,S_co2,S_dloc,S_dlev,D,T) ) * periodScale(T) )
*                                       - sum((G,T), genVarInv(G) * SP_GEN_G(S_trans,S_co2,S_dloc,S_dlev,G,T) * periodScale(T) ) ) * YEAR
*                                       - sum(G, genFixInv(G) * SP_CAP_G(G)) ;
*  wf_SP                              = sum((S_trans,S_co2,S_dloc,S_dlev), prob_trans(S_trans)*prob_co2(S_co2)*prob_dloc(S_dloc)*prob_dlev(S_dlev)
*                                        * wf_sc_SP(S_trans,S_co2,S_dloc,S_dlev) ) ;
*  wf_SP_TEST                         = welfareSpot.l ;
*  priceD_Spot(S_trans,S_co2,S_dloc,S_dlev,D,T) = ( consObjA(D,T,S_dlev,S_dloc) - consObjB(D,T,S_dlev,S_dloc) * SP_DEM(S_trans,S_co2,S_dloc,S_dlev,D,T) ) ;
*  priceG_Spot(S_trans,S_co2,S_dloc,S_dlev,G,T) = sum(Z$(Z.val = GenInZone(G,S_trans,S_co2,S_dloc,S_dlev)), ZFKL.m(S_trans,S_co2,S_dloc,S_dlev,Z,T) / Year / periodScale(T) / probability(S));
*  wf_SP_d(S,D)       $probability(S) = ( sum(T, (consObjA(D,T) * SP_DEM(S,D,T) - 0.5 * consObjB(D,T) * SP_DEM(S,D,T) * SP_DEM(S,D,T)) * periodScale(T) )
*                                       - sum(T, priceD_Spot(S,D,T)  * SP_DEM(S,D,T) * periodScale(T) ) ) * YEAR;
                                     

*  avgPriceSpot(S)    $probability(S) = sum((D,T), demSpot(S,D,T) * priceSpot(S,D,T) * periodScale(T) ) / sum((D,T), demSpot(S,D,T) * periodScale(T) );
*  totalAvgPriceSpot = sum(S$probability(S),Probability(S)*(sum((D,T), demSpot(S,D,T) * priceSpot(S,D,T) * Year * periodScale(T) ) / sum((D,T), demSpot(S,D,T) * Year * periodScale(T) )));

$ontext
  option clear= welfareSpot ;
  option clear= d_sp        ;
  option clear= g_sp        ;
  option clear= ig_sp       ;
  option clear= f_sp        ;
$offtext

***--------------------------------------------------------------------------***
***                         SOLVE REDISPATCH MODEL                           ***
***--------------------------------------------------------------------------***


  option clear = costRedispatch ;
  option clear = f_rd   ;
  option clear = angle  ;
  option clear = d_rd   ;
  option clear = g_rd   ;
  option clear = gb_rd  ;
  option clear = ib_rd  ;
  option clear = g_n_rd ;
  option clear = g_p_rd ;

  SOLVE Redispatch USING LP MINIMIZE costRedispatch ;
    )
$stop; 

  RD_GEN_G(S,G,T) = g_rd.l(S,G,T)  ;
  RD_CAP_B(B)     = ib_rd.l(B)     ;
  RD_GEN_B(S,B,T) = gb_rd.l(S,B,T) ;
*  RD_DEM_L(S,D,T) = ls_rd.l(S,D,T) ;


Display test;
$ontext
  option clear = costRedispatch ;
  option clear = f_rd   ;
  option clear = angle  ;
  option clear = d_rd   ;
  option clear = g_rd   ;
  option clear = gb_rd  ;
  option clear = ib_rd  ;
  option clear = g_n_rd ;
  option clear = g_p_rd ;
$offtext

***--------------------------------------------------------------------------***
***                        CALCULATION OF RESULTS                            ***
***--------------------------------------------------------------------------***

*Calculate variable generation costs per scenario (fuel + CO2)
  Cost_sc_sp_g(S)$probability(S)    = sum((G,T),                genVarInv(G) * SP_GEN_G(S,G,T) * periodScale(T) * YEAR ) ;
*Calculate redispatch costs existing capacity per scenario
  Cost_sc_rd_g(S)$probability(S) = sum((G,T), genVarInv(G) * ( RD_GEN_G(S,G,T) - SP_GEN_G(S,G,T) ) * periodScale(T) ) * Year ;
*Calculate redispatch costs backup capacity per scenario
  Cost_sc_rd_b(S)$probability(S) = sum((B,T),  buVarInv    * ( RD_GEN_B(S,B,T)                   ) * periodScale(T) ) * Year ;
*Calculate redispatch costs backup capacity per scenario
*  Cost_sc_rd_l(S)$probability(S) = sum((D,T),  DSM         * ( RD_DEM_L(S,D,T)                   ) * periodScale(T) ) * Year ;
*Calculate total congestion rent per scenario
  Cost_sc_cr(S)$probability(S)   = sum((L,T)$lineB(L), YEAR * periodScale(T) * abs( SP_FLOW(S,L,T) ) * abs(sum(D$(lineStart(L) =D.val), PriceD_Spot(S,D,T)) - sum(D$(lineEnd(L) = D.val), PriceD_Spot(S,D,T))));
  Cost_fc_l                      = sum(L$SP_CAP_L(L),        lineFixInv(L) ) ;
  Cost_fc_b                      = sum(B,                    buFixInv     * RD_CAP_B(B) ) ;
  Cost_fc_g                      = sum(G,                    genFixInv(G) * SP_CAP_G(G) ) ;

*Calculate all network & backup investment and redispatch costs per scenario
  rediCost(S)$probability(S)     = sum((G,T), genVarInv(G) * ( RD_GEN_G(S,G,T) - SP_GEN_G(S,G,T) ) * periodScale(T)) * YEAR
                                  + sum((B,T), buVarInv * RD_GEN_B(S,B,T) * periodScale(T) ) * YEAR
*                                  + sum((D,T), DSM * RD_DEM_L(S,D,T) * periodScale(T) ) * YEAR
                                  + sum(B, buFixInv * RD_CAP_B(B))
                                  + sum(L$SP_CAP_L(L), lineFixInv(L) )

;
*Calculate all network & backup investment and redispatch costs
  totalRediCost                  = sum(S$probability(S), probability(S) * ( sum((G,T), genVarInv(G) * ( RD_GEN_G(S,G,T) - SP_GEN_G(S,G,T) ) * periodScale(T) )
                                  + sum((B,T), buVarInv * RD_GEN_B(S,B,T) * periodScale(T) ) )
*                                  + sum((D,T), DSM * RD_DEM_L(S,D,T) * periodScale(T) ) * YEAR)
                                  ) * YEAR
                                  + sum(B, buFixInv * RD_CAP_B(B))
                                  + sum(L$SP_CAP_L(L), lineFixInv(L) ) ;

*Welfare after redispatch and investment costs in scenario S
  wf_sc_all(S)$probability(S)    = ( sum((D,T), ( consObjA(D,T) * SP_dem(S,D,T) - 0.5 * consObjB(D,T) * SP_dem(S,D,T) * SP_dem(S,D,T) ) * periodScale(T) )
                                   - sum((G,T), genVarInv(G) * RD_GEN_G(S,G,T) * periodScale(T) )
                                   - sum((B,T), buVarInv     * RD_GEN_B(S,B,T) * periodScale(T) ) ) * Year
                                     - sum(G,             genFixInv(G)  * SP_CAP_G(G) )
                                     - sum(B,             buFixInv      * RD_CAP_B(B) )
                                     - sum(L$SP_CAP_L(L), lineFixInv(L) ) ;

*Welfare after redispatch for both scenarios
  wf_all                         = sum(S$probability(S), probability(S) * wf_sc_all(S) ) ;

*Prices
  Price_SP_nodalAvg(S,N)$(sum((D,T)$(consAtNode(D) = N.val), SP_DEM(S,D,T))) = sum((D,T)$(consAtNode(D) = N.val), SP_DEM(S,D,T) * PriceD_Spot(S,D,T) * Year * periodScale(T))
                                                                             / sum((D,T)$(consAtNode(D) = N.Val), SP_DEM(S,D,T) * Year * periodScale(T) );

  Price_RD_Markup(S)$probability(S)  = ( Cost_sc_rd_g(S) + Cost_sc_rd_b(S) - Cost_sc_cr(S) + Cost_fc_l + Cost_fc_b ) / sum((D,T), SP_DEM(S,D,T) * periodScale(T) * YEAR ) ;

  Price_FI_nodal(S,N)$probability(S) = Price_SP_nodalAvg(S,N) + Price_RD_Markup(S) ;

  Demand(s,'1')$probability(S)         = sum(t, SP_DEM(s,'1',t) * periodScale(T) * YEAR ) ;
  Demand(s,'2')$probability(S)         = sum(t, SP_DEM(s,'2',t) * periodScale(T) * YEAR ) ;

$ontext
*Nodal welfare in scenario S
*MISSING TRADE FLOWS !!!!
  nodal_welfare(S,N)$probability(S) = (sum((D,T)$(consAtNode(D) = N.val), (consObjA(D,T) * dem.l(S,D,T) - 0.5 * consObjB(D,T) * dem.l(S,D,T) * dem.l(S,D,T)) * periodScale(T))
                         - sum((G,T)$(genAtNode(G) = N.val), genVarInv(G) * gen.l(S,G,T) * periodScale(T)) - sum((B,T)$(buAtNode(B) = N.val), buVarInv * genBU.l(S,B,T) * periodScale(T))) * Year
                         - sum(G$(genAtNode(G)=N.val), genFixInv(G) * genC.l(G))
                         - sum(B$(buAtNode(B) = N.val), buFixInv * genCbu.l(B))
                         - sum(L$(lineIsNew(L) = 1), lineFixInv(L) * lineB.l(L));

$offtext

***--------------------------------------------------------------------------***
***                       RESULTS to LOOP-PARAMETER                          ***
***--------------------------------------------------------------------------***

  Loop_welfare_sp_sc(Loop_Probability, LineInvest,S)     = wf_sc_SP(S)   ;
  Loop_welfare_sp(Loop_Probability, LineInvest)          = wf_SP         ;
  Loop_welfare_all_sc(Loop_Probability,LineInvest,S)     = wf_sc_all(S)  ;
  Loop_welfare_all(Loop_Probability, LineInvest)         = wf_all        ;
  Loop_welfare_sp_TEST(Loop_Probability, LineInvest)     = wf_sp_TEST    ;
  Loop_welfare_sp_sc_d(Loop_Probability, LineInvest,S,D) = wf_sp_d(S,D)  ;

  Loop_nodal(Loop_Probability,LineInvest,S,'1',"CS")$probability(S) = ( sum((D,T), ( consObjA('1',T) * SP_dem(S,'1',T) - 0.5 * consObjB('1',T) * SP_dem(S,'1',T) * SP_dem(S,'1',T) ) * periodScale(T) ) ) * YEAR ;
  Loop_nodal(Loop_Probability,LineInvest,S,'2',"CS")$probability(S) = ( sum((D,T), ( consObjA('2',T) * SP_dem(S,'2',T) - 0.5 * consObjB('2',T) * SP_dem(S,'2',T) * SP_dem(S,'2',T) ) * periodScale(T) ) ) * YEAR;
  Loop_nodal(Loop_Probability,LineInvest,S,N,"SP_G")$probability(S) = sum(G$(ord(N)=genAtNode(G)),
                                                                         sum(T, genVarInv(G) * SP_GEN_G(S,G,T) * periodScale(T) ) ) * Year ;
  Loop_nodal(Loop_Probability,LineInvest,S,N,"SP_P")$probability(S) = sum(G$(ord(N)=genAtNode(G)),
                                                                         sum(T, priceG_Spot(S,G,T)  * SP_GEN_G(S,G,T) * periodScale(T) ) ) * Year ;
  Loop_nodal(Loop_Probability,LineInvest,S,N,"SP_P")$probability(S) = sum(G$(ord(N)=genAtNode(G)),
                                                                         genFixInv(G) * SP_CAP_G(G) ) ;
  Loop_nodal(Loop_Probability,LineInvest,S,N,"CR")$probability(S)  = Cost_sc_cr(S) * Demand(s,n) / sum(nn, Demand(s,nn) ) ;
  Loop_nodal(Loop_Probability,LineInvest,S,N,"C_L")$probability(S) = Cost_fc_l * Demand(s,n) / sum(nn, Demand(s,nn) ) ;
  Loop_nodal(Loop_Probability,LineInvest,S,N,"C_B")$probability(S) = Cost_fc_b * Demand(s,n) / sum(nn, Demand(s,nn) ) ;
  Loop_nodal(Loop_Probability,LineInvest,S,N,"RD_G")$probability(S) = ( Cost_sc_rd_g(S) + Cost_sc_rd_b(S) ) * Demand(s,n) / sum(nn, Demand(s,nn) ) ;

  Loop_genInv(Loop_Probability, LineInvest, G)           = SP_CAP_G(G)   ;
  Loop_lineInv(Loop_Probability,LineInvest)              = sum(l, SP_CAP_L(L) ) ;

  Loop_price_SP_D(Loop_Probability,LineInvest,S,D,T)     = priceD_Spot(S,D,T)     ;
  Loop_price_SP_G(Loop_Probability,LineInvest,S,G,T)     = priceG_Spot(S,G,T)     ;

  Loop_price_SP_nodal(Loop_Probability,LineInvest,S,N)$probability(S)      = Price_SP_nodalAvg(S,N) ;
  Loop_price_RD_markup(Loop_Probability,LineInvest,S,"all")$probability(S) = Price_RD_Markup(S)     ;
  Loop_price_RD_markup(Loop_Probability,LineInvest,S,"CR")$probability(S)  = - Cost_sc_cr(S) / sum((D,T), SP_DEM(S,D,T) * periodScale(T) * YEAR )  ;
  Loop_price_RD_markup(Loop_Probability,LineInvest,S,"C_L")$probability(S) = + Cost_fc_l / sum((D,T), SP_DEM(S,D,T) * periodScale(T) * YEAR )      ;
  Loop_price_RD_markup(Loop_Probability,LineInvest,S,"C_B")$probability(S) = + Cost_fc_b / sum((D,T), SP_DEM(S,D,T) * periodScale(T) * YEAR )      ;
  Loop_price_RD_markup(Loop_Probability,LineInvest,S,"RD_G")$probability(S)= ( Cost_sc_rd_g(S) + Cost_sc_rd_b(S) ) / sum((D,T), SP_DEM(S,D,T) * periodScale(T) * YEAR )  ;
  Loop_price_Final(Loop_Probability,LineInvest,S,N)      = Price_FI_nodal(S,N)    ;

  Loop_demand(Loop_Probability, LineInvest,S,N)          = Demand(s,n) ;

$ontext
*Individual price components
  Loop_results_price_N(Loop_Probability,LineInvest,S,N,"p_sp")$probability(S) = sum(T, sum(D$(consAtNode(D)=ord(N)), ( priceSpot(S,D,T) * demSpot(S,D,T) ) * periodScale(T) ) )
                                                                         / sum(T, sum(D$(consAtNode(D)=ord(N)), demSpot(S,D,T) ) * periodScale(T) ) ;

  Loop_results_price_N(Loop_Probability,LineInvest,S,N,"p_rd")$probability(S) = rediCost(S) / ( sum((D,T), demSpot(S,D,T) * periodScale(T) ) * YEAR ) ;

  Loop_results_price_N(Loop_Probability,LineInvest,S,N,"p_cr")$probability(S) = -networkRevenues(S)/ ( sum((D,T), demSpot(S,D,T) * periodScale(T) ) * YEAR ) ;

  Loop_results_price_A(Loop_Probability,LineInvest,S,"p_sp")$probability(S) = sum((T,D), ( priceSpot(S,D,T) * demSpot(S,D,T) ) * periodScale(T) )
                                                                         / sum((T,D), demSpot(S,D,T) * periodScale(T) ) ;
  Loop_results_price_A(Loop_Probability,LineInvest,S,"p_rd")$probability(S) = Loop_results_price_N(Loop_Probability,LineInvest,S,'1',"p_rd") ;
  Loop_results_price_A(Loop_Probability,LineInvest,S,"p_cr")$probability(S) = Loop_results_price_N(Loop_Probability,LineInvest,S,'1',"p_cr") ;

$offtext

  Loop_redispatch_TEST(Loop_Probability, LineInvest)   = ct_rd_TEST    ;
  Loop_redispatch_sc(Loop_Probability, LineInvest,s)   = RediCost(S) ;
  Loop_redispatch(Loop_Probability, LineInvest)        = totalRediCost ;



*Individual rents for consumers, producers and TSOs
  Loop_rents_CS(Loop_Probability,LineInvest,D,S)$probability(S) = ( sum( (T), ( consObjA(D,T) * SP_dem(S,D,T) - 0.5 * consObjB(D,T) * SP_dem(S,D,T) * SP_dem(S,D,T) ) * periodScale(T) )
                                                                  - sum( (T), ( PriceD_Spot(S,D,T) * SP_dem(S,D,T) ) * periodScale(T) ) ) * YEAR ;

  Loop_rents_PS(Loop_Probability,LineInvest,G,S)$(probability(S) and SP_CAP_G(G)) =  ( sum( (T), ( PriceG_Spot(S,G,T) - genVarInv(G) ) * SP_GEN_G(S,G,T) * periodScale(T) ) * YEAR
                                                                                         - genFixInv(G) * SP_CAP_G(G) ) ;

  Loop_results_rents_N(Loop_Probability,LineInvest,S,N,"CS")               = sum(D$(consAtNode(D)=ord(N)), Loop_rents_CS(Loop_Probability,LineInvest,D,S) );
  Loop_results_rents_N(Loop_Probability,LineInvest,S,N,"PS")               = sum(G$(genAtNode(G)=ord(N)),  Loop_rents_PS(Loop_Probability,LineInvest,G,S) );
  Loop_results_rents_A(Loop_Probability,LineInvest,S,"CS")                 = sum(n, Loop_results_rents_N(Loop_Probability,LineInvest,S,N,"CS") ) ;
  Loop_results_rents_A(Loop_Probability,LineInvest,S,"PS")                 = sum(n, Loop_results_rents_N(Loop_Probability,LineInvest,S,N,"PS") ) ;
  Loop_results_rents_A(Loop_Probability,LineInvest,S,"CR")                 = Cost_sc_cr(S)   ;
  Loop_results_rents_A(Loop_Probability,LineInvest,S,"SP_G")               = Cost_sc_sp_g(S) ;
  Loop_results_rents_A(Loop_Probability,LineInvest,S,"RD_G")               = Cost_sc_rd_g(S) ;
  Loop_results_rents_A(Loop_Probability,LineInvest,S,"RD_B")               = Cost_sc_rd_b(S) ;
  Loop_results_rents_A(Loop_Probability,LineInvest,S,"SP_G")               = Cost_sc_sp_g(S) ;
  Loop_results_rents_A(Loop_Probability,LineInvest,S,"C_L")$probability(S) = Cost_fc_l ;
  Loop_results_rents_A(Loop_Probability,LineInvest,S,"C_B")$probability(S) = Cost_fc_b ;
  Loop_results_rents_A(Loop_Probability,LineInvest,S,"C_G")$probability(S) = Cost_fc_g ;

  Loop_profits_PS(Loop_Probability,LineInvest,G,S)$sum(T, SP_GEN_G(S,G,T)) = Loop_rents_PS(Loop_Probability,LineInvest,G,S) / ( sum(T, SP_GEN_G(S,G,T) * periodScale(T) ) * YEAR ) ;


***--------------------------------------------------------------------------***
***                     CLEAR PARAMETERs OF MODEL RUN                        ***
***--------------------------------------------------------------------------***

* Clear Spot Resuls
  option clear= SP_DEM           ;
  option clear= SP_GEN_G         ;
  option clear= SP_CAP_G         ;
  option clear= SP_FLOW          ;
  option clear= SP_CAP_L         ;

  option clear= wf_sc_SP         ;
  option clear= wf_SP            ;
  option clear= wf_sp_TEST       ;
  option clear= wf_sp_d          ;
  option clear= priceD_Spot      ;
  option clear= priceG_Spot      ;

* Clear RD Results
  option clear= RD_GEN_G         ;
  option clear= RD_CAP_B         ;
  option clear= RD_GEN_B         ;
  option clear= ct_RD_TEST       ;

* Clear calculation results
  option clear= Cost_sc_sp_g     ;
  option clear= Cost_sc_rd_g     ;
  option clear= Cost_sc_rd_b     ;
  option clear= Cost_sc_cr       ;
  option clear= Cost_fc_l        ;
  option clear= Cost_fc_b        ;
  option clear= Cost_fc_g        ;

  option clear= rediCost         ;
  option clear= totalRediCost    ;
  option clear= wf_sc_all        ;
  option clear= wf_all           ;

  option clear= Price_SP_nodalAvg;
  option clear= Price_RD_Markup  ;
  option clear= Price_FI_nodal   ;

    );
  );

***--------------------------------------------------------------------------***
***                            END OF MODEL LOOP                             ***
***--------------------------------------------------------------------------***


***--------------------------------------------------------------------------***
***                 OUTPUT WITH RESULTS FOR BEST LINE INVEST                 ***
***--------------------------------------------------------------------------***

  Parameter
  Results_genInv(Loop_Probability,G)
  Results_lineInv(Loop_Probability)

  maxWelfare(Loop_Probability)
  Results_welfare_sp_sc(Loop_Probability,S)
  Results_welfare_sp(Loop_Probability)
  Results_welfare_sp_sc_d(Loop_Probability,S,D)
  Results_welfare_sp_test(Loop_Probability)
  Results_welfare_all_sc(Loop_Probability,S)
  Results_welfare_all(Loop_Probability)


  Results_redispatch_sc(Loop_Probability,S)
  Results_redispatch_all(Loop_Probability)
  Results_redispatch_all_TEST(Loop_Probability)

  Results_price_SP_D(Loop_Probability,S,D,T)
  Results_price_SP_G(Loop_Probability,S,G,T)
  Results_price_SP_nodal(Loop_Probability,S,N)
  Results_price_RD_Markup(Loop_Probability,S,results)
  Results_price_FI_nodal(Loop_Probability,S,N)

  Results_results_rents_A(Loop_Probability,S,results)
  Results_rents_PS(Loop_Probability,G,S)
  Results_profits_PS(Loop_Probability,G,S)

  Results_demand(Loop_Probability,S,N)
  Results_nodal(Loop_Probability,S,N,results)

$ontext
  Results_nodal_welfare(Loop_Probability,S,N)
  Results_avgPriceSpot(Loop_Probability,S)
  Results_totalAvgPriceSpot(Loop_Probability)
  Results_demand(Loop_Probability,S,D,T)

  Results_rents_CS(Loop_Probability,D,S)
  Results_rediCost(Loop_Probability,S)
  Results_totalRediCost (Loop_Probability)
  Results_rediGenCost(Loop_Probability,S)
  Results_rediBuCost(Loop_Probability,S)
  Results_totalLineCapacity(Loop_Probability)
  Results_nodalAvgPriceSpot(Loop_Probability,S,N)

  Results_results_rents_N(Loop_Probability,S,N,results)

  Results_results_price_N(Loop_Probability,S,N,results)
  Results_results_price_A(Loop_Probability,S,results)
$offtext
  ;


  Loop(LineInvest,

    maxWelfare(Loop_Probability)$(Loop_welfare_all(Loop_Probability,LineInvest)=smax(LineInvest2, Loop_welfare_all(Loop_Probability,LineInvest2) )) = LineInvest.val             ;

  );

  Results_genInv(Loop_Probability,G)                     = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_genInv(Loop_Probability, LineInvest, G) )         ;
  Results_lineInv(Loop_Probability)                      = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_lineInv(Loop_Probability, LineInvest) )           ;

  Results_welfare_sp_sc(Loop_Probability,S)              = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_welfare_sp_sc(Loop_Probability,LineInvest,S) )    ;
  Results_welfare_sp(Loop_Probability)                   = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_welfare_sp(Loop_Probability,LineInvest) )         ;
  Results_welfare_sp_TEST(Loop_Probability)              = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_welfare_sp_TEST(Loop_Probability,LineInvest) )    ;
  Results_welfare_sp_sc_d(Loop_Probability,S,D)          = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_welfare_sp_sc_d(Loop_Probability,LineInvest,S,D) );

  Results_welfare_all_sc(Loop_Probability,S)             = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_welfare_all_sc(Loop_Probability,LineInvest,S) )   ;
  Results_welfare_all(Loop_Probability)                  = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_welfare_all(Loop_Probability,LineInvest) )        ;
*  Results_nodal_welfare(Loop_Probability,S,N)     = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_nodal_welfare(Loop_Probability,LineInvest,S,N)) ;

  Results_redispatch_sc(Loop_Probability,S)              = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_redispatch_sc(Loop_Probability, LineInvest,S) )   ;
  Results_redispatch_all(Loop_Probability)               = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_redispatch(Loop_Probability, LineInvest)      )   ;
  Results_redispatch_all_TEST(Loop_Probability)          = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_redispatch_TEST(Loop_Probability, LineInvest) )   ;

  Results_price_SP_D(Loop_Probability,S,D,T)             = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_price_SP_D(Loop_Probability,LineInvest,S,D,T) )   ;
  Results_price_SP_G(Loop_Probability,S,G,T)             = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_price_SP_G(Loop_Probability,LineInvest,S,G,T) )   ;
  Results_price_SP_nodal(Loop_Probability,S,N)           = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_price_SP_nodal(Loop_Probability,LineInvest,S,N) ) ;
  Results_price_RD_Markup(Loop_Probability,S,results)    = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_price_RD_Markup(Loop_Probability,LineInvest,S, results) )  ;
  Results_price_FI_nodal(Loop_Probability,S,N)           = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_price_Final(Loop_Probability,LineInvest,S,N) )    ;

  Results_results_rents_A(Loop_Probability,S,results)    = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_results_rents_A(Loop_Probability,LineInvest,S,results) )     ;
  Results_rents_PS(Loop_Probability,G,S)                 = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability) and Loop_genInv(Loop_Probability,LineInvest,G)), Loop_rents_PS(Loop_Probability,LineInvest,G,S))     ;
  Results_profits_PS(Loop_Probability,G,S)               = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability) and Loop_genInv(Loop_Probability,LineInvest,G)), Loop_profits_PS(Loop_Probability,LineInvest,G,S))     ;

  Results_demand(Loop_Probability,S,N)                   = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_Demand(Loop_Probability,LineInvest,S,N) )         ;
  Results_nodal(Loop_Probability,S,N,results)                    = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_Nodal(Loop_Probability,LineInvest,S,N,results) )          ;


$ontext
  Results_avgPriceSpot(Loop_Probability,S)        = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_avgPriceSpot(Loop_Probability,LineInvest,S) )    ;
  Results_lineInvCost(Loop_Probability)           = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_lineInvCost(Loop_Probability,LineInvest) )       ;
  Results_genCost(Loop_Probability)               = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_genCost(Loop_Probability,LineInvest) )           ;
  Results_buCost(Loop_Probability)                = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_buCost(Loop_Probability,LineInvest) )            ;
  Results_buInv(Loop_Probability,B)               = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_buInv(Loop_Probability, LineInvest, B) )         ;
  Results_totalAvgPriceSpot(Loop_Probability)     = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_totalAvgPriceSpot(Loop_Probability, LineInvest)) ;

  Results_rents_CS(Loop_Probability,D,S)          = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_rents_CS(Loop_Probability,LineInvest,D,S))       ;

  Results_rediCost(Loop_Probability,S)            = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_rediCost(Loop_Probability,LineInvest,S) )        ;
  Results_totalRediCost(Loop_Probability)         = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_totalRediCost(Loop_Probability,LineInvest) )     ;
  Results_rediGenCost(Loop_Probability,S)         = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_rediGenCost(Loop_Probability,LineInvest,S) )     ;
  Results_rediBuCost(Loop_Probability,S)          = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_rediBuCost(Loop_Probability,LineInvest,S) )      ;
  Results_flowFinal(Loop_Probability, S,L,T)      = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_flowFinal(Loop_Probability,LineInvest,S,L,T) )   ;
  Results_generationBU(Loop_Probability, S,B,T)   = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_generationBU(Loop_Probability,LineInvest,S,B,T) );
  Results_generation(Loop_Probability, S,G,T)     = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_generation(Loop_Probability,LineInvest,S,G,T) )  ;
  Results_totalLineCapacity(Loop_Probability)     = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_totalLineCapacity(Loop_Probability,LineInvest) ) ;
  Results_avgGenUtilization(Loop_Probability,S,G) = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_avgGenUtilization(Loop_Probability,LineInvest, S,G) ) ;
  Results_avgLineUtilization(Loop_Probability,S)  = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_avgLineUtilization(Loop_Probability,LineInvest,S) )   ;
  Results_avgBuUtilization(Loop_Probability,S,B)  = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_avgBuUtilization(Loop_Probability,LineInvest, S,B) )  ;
  Results_nodalAvgPriceSpot(Loop_Probability,S,N) = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_nodalAvgPriceSpot(Loop_Probability,LineInvest, S,N) ) ;
  Results_networkFee(Loop_Probability,S)          = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_networkFee(Loop_Probability,LineInvest, S) )          ;
  Results_networkRev(Loop_Probability,S)          = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_networkRev(Loop_Probability,LineInvest,S) )           ;

  Results_results_rents_N(Loop_Probability,S,N,results) = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_results_rents_N(Loop_Probability,LineInvest,S,N,results) ) ;

  Results_results_price_N(Loop_Probability,S,N,results) = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_results_price_N(Loop_Probability,LineInvest,S,N,results) ) ;
  Results_results_price_A(Loop_Probability,S,results)   = sum(LineInvest$(ord(LineInvest)=maxWelfare(Loop_Probability)), Loop_results_price_A(Loop_Probability,LineInvest,S,results) )     ;
$offtext

*$include OutputWriter.gms


