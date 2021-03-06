***--------------------------------------------------------------------------***
***                             GENERAL OPTIONS                              ***
***--------------------------------------------------------------------------***

option  optcr = 0.0
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
*** Choose deterministic or uncertain model (deterministic, uncertain)
$set mode uncertain
*deterministic

Sets
         Weight                                  / 1   /
         L "indices for power lines"             / 1* 60 /
         LineInvest "number of iterations"       / 1 * 2 /
;


Parameter xscale(Weight) determine lower bound for line investment for each weight (*0.05);

*1 zone risk-neutral TSO (lower bounds for line investment)
*$ontext
* xscale('1') = 48;
* xscale('2') = 48;
* xscale('3') = 48;
* xscale('4') = 49;
* xscale('6') = 50;
*$offtext

*1 zone fixed line investment
$ontext
xscale('1') = 48 ;
xscale('2') = 49 ;
xscale('3') = 49 ;
xscale('4') = 50 ;
xscale('5') = 51 ;
xscale('6') = 51 ;
$offtext

*1 zone risk-neutral TSO without anticipating risk-aversion of priv. firms
$ontext
xscale('1') = 48 ;
xscale('2') = 48 ;
xscale('3') = 48 ;
xscale('4') = 48 ;
xscale('5') = 48 ;
xscale('6') = 48 ;
$offtext

*2 zones risk neutral TSO (lower bounds for line investment)
$ontext
xscale('1') = 5 ;
xscale('2') = 5 ;
xscale('3') = 5 ;
xscale('4') = 5 ;
xscale('5') = 5 ;
xscale('6') = 5 ;
$offtext

*2 zones fixed line investment
$ontext
xscale('1') = 11 ;
xscale('2') = 34 ;
xscale('3') = 22 ;
xscale('4') = 8 ;
xscale('5') = 9 ;
xscale('6') = 9 ;
$offtext

*2 zones risk-neutral TSO without anticipating risk-aversion of priv. firms
$ontext
xscale('1') = 11 ;
xscale('2') = 11 ;
xscale('3') = 11 ;
xscale('4') = 11 ;
xscale('5') = 11 ;
xscale('6') = 11;
$offtext

*Results 1Zone        0.01   0.05
*xscale('1') = 48 ;  #0.48  #0.45
*xscale('2') = 46 ;  #0.49  #0.50
*xscale('3') = 46 ;  #0.49  #0.50
*xscale('4') = 46 ;  #0.50  #0.50
*xscale('5') = 46 ;  #0.51  #0.50
*xscale('6') = 46 ;  #0.51  #0.50

*Results 2Zone      0.01   0.05
*xscale('1') = 11; #0.11  #0.10
*xscale('2') = 34; #0.34  #0.35
*xscale('3') = 22; #0.22  #0.25
*xscale('4') = 8 ; #0.08  #0.10
*xscale('5') = 9 ; #0.09  #0.1
*xscale('6') = 8 ; #0.08  #0.10




***--------------------------------------------------------------------------***
***             LOAD DATA AND SETUP FOR LOOP WITH PROBABILITIES              ***
***--------------------------------------------------------------------------***

$include input_ra.gms
$include parameters_ra.gms
$include model_ra.gms

*** read gurobi.opt
  Spotmarket.OptFile = 1 ;
  Redispatch.OptFile = 1 ;

*** time after which the solver terminates:
 Spotmarket.reslim = 10000;
 Redispatch.reslim = 36000;

 Alias(LineInvest,LineInvest2) ;

***--------------------------------------------------------------------------***
***           START MODEL LOOP FOR PROBABILITIES AND LINE INVEST             ***
***--------------------------------------------------------------------------***

 Loop(Weight,

  weight_sp = (Weight.val-1)*0.2-0.01$(Weight.val=6);
*  weight_rd = (Weight.val-1)*0.2-0.01$(Weight.val=6);
* Risk neutral TSO:
  weight_rd = 0;

     Loop(LineInvest,

       lineB(L) = 1$(LineInvest.val=L.val-xscale(Weight));

***--------------------------------------------------------------------------***
***                        SOLVE SPOT MARKET MODEL                           ***
***--------------------------------------------------------------------------***

  option clear= welfareSpot ;
  option clear= d_sp        ;
  option clear= g_sp        ;
  option clear= ig_sp       ;
  option clear= f_sp        ;



  SOLVE Spotmarket USING QCP MAXIMIZE welfareSpot ;

*  SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)   = d_sp.l(D,T,S_co2,S_dloc,S_dlev,S_lcost)    ;
*  SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) = g_sp.l(G,T,S_co2,S_dloc,S_dlev,S_lcost)    ;
  SP_CAP_G(G)                               = ig_sp.l(G)                                 ;
*  SP_FLOW(L,T,S_co2,S_dloc,S_dlev,S_lcost)  = f_sp.l(L,T,S_co2,S_dloc,S_dlev,S_lcost)    ;
  SP_CAP_L(L)                               = lineB(L) * lineUB(L)                       ;


*$ontext
* option clear= welfareSpot ;
  option clear= d_sp        ;
  option clear= g_sp        ;
*  option clear= ig_sp       ;
  option clear= f_sp        ;

 SOLVE Spotmarket_Riskneutral USING QCP MAXIMIZE welfareSpot_rn ;
*$offtext

  SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)   = d_sp.l(D,T,S_co2,S_dloc,S_dlev,S_lcost)    ;
  SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) = g_sp.l(G,T,S_co2,S_dloc,S_dlev,S_lcost)    ;
  SP_FLOW(L,T,S_co2,S_dloc,S_dlev,S_lcost)  = f_sp.l(L,T,S_co2,S_dloc,S_dlev,S_lcost)    ;


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

*  SOLVE Redispatch USING LP MINIMIZE costRedispatch ;
  SOLVE Redispatch USING LP MAXIMIZE welfareRedispatch;

  RD_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) = g_rd.l(G,T,S_co2,S_dloc,S_dlev,S_lcost)  ;
  RD_CAP_B(B)     = ib_rd.l(B)     ;
  RD_GEN_B(B,T,S_co2,S_dloc,S_dlev,S_lcost) = gb_rd.l(B,T,S_co2,S_dloc,S_dlev,S_lcost) ;
  VAR_RD_FIX = VAR_rd.l;
  ETA_RD_FIX(S_co2,S_dloc,S_dlev,S_lcost) = eta_rd.l(S_co2,S_dloc,S_dlev,S_lcost);


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
  Cost_sc_sp_g(S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost)   =
        sum((G,T),genVarInv(G, S_co2)
        * SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost)
        * periodScale(T)
        * YEAR );

*Calculate redispatch costs existing capacity per scenario
  Cost_sc_rd_g(S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost)  =
        sum((G,T), genVarInv(G,S_co2)
        * (RD_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost)
        - SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost))
        * periodScale(T))
        * Year ;

*Calculate redispatch costs of backup capacity per scenario
  Cost_sc_rd_b(S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost) =
        sum((B,T), buVarInv(S_co2)
        * (RD_GEN_B(B,T,S_co2,S_dloc,S_dlev,S_lcost))
        * periodScale(T))
        * Year                  ;

*Calculate redispatch DSM cost per scenario
*not included

*Calculate spot price
  priceSpot(D,T,S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost) =
        (consObjA(D,T,S_dloc,S_dlev)
        - consObjB(D,T,S_dloc,S_dlev)
        * SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost));

*Calculate total congestion rent per scenario
  Rent_sc_cr(S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost) =
         sum((L,T)$lineB(L), YEAR
        * periodScale(T)
        * abs(SP_FLOW(L,T,S_co2,S_dloc,S_dlev,S_lcost))
        * abs(sum(D$(lineStart(L) =D.val), priceSpot(D,T,S_co2,S_dloc,S_dlev,S_lcost))
        - sum(D$(lineEnd(L) = D.val), priceSpot(D,T,S_co2,S_dloc,S_dlev,S_lcost))));

*Calculate total line investment cost
  Cost_sc_rd_l(S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost) =
         sum(L$SP_CAP_L(L),lineFixInv(L,S_lcost)) ;

*Calculate total backup investment cost
  Cost_fc_b  = sum(B, buFixInv * RD_CAP_B(B)) ;

*Calculate total generation capacity investment cost
  Cost_fc_g = sum(G, genFixInv(G) * SP_CAP_G(G) ) ;

*Calculate all network and backup investment and redispatch costs per scenario
  rediCost(S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost) =
        sum((G,T), genVarInv(G,S_co2)
        * (RD_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost)
        - SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost))
        * periodScale(T)) * YEAR
        + sum((B,T), buVarInv(S_co2) * RD_GEN_B(B,T,S_co2,S_dloc,S_dlev,S_lcost)
        * periodScale(T) ) * YEAR
        + sum(B, buFixInv * RD_CAP_B(B))
        + sum(L$SP_CAP_L(L), lineFixInv(L,S_lcost));

*Calculate total generation redispatch cost per scenario
  gen_redi_cost(S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost) =
        sum((G,T), genVarInv(G,S_co2)
        * (RD_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost)
        - SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost))
        * periodScale(T)) * YEAR;

*Calculate total line investment cost per scenario
  line_inv_cost(S_lcost) = sum(L$SP_CAP_L(L), lineFixInv(L,S_lcost));

*Calculate expected network & backup investment and redispatch costs
  totalRediCost = sum((S_co2,S_dloc,S_dlev,S_lcost),prob_scen(S_co2,S_dloc,S_dlev,S_lcost)*(rediCost(S_co2,S_dloc,S_dlev,S_lcost)-Rent_sc_cr(S_co2,S_dloc,S_dlev,S_lcost)));

*Calculate total expected demand
  totalDem = sum((S_co2,S_dloc,S_dlev,S_lcost),prob_scen(S_co2,S_dloc,S_dlev,S_lcost)*(sum((T,D),SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)* periodScale(T)*YEAR)));

*Calculate expected network & backup investment and redispatch costs
*  totalRediCost                  = sum(S$probability(S), probability(S) * ( sum((G,T), genVarInv(G) * ( RD_GEN_G(S,G,T) - SP_GEN_G(S,G,T) ) * periodScale(T) )
*                                  + sum((B,T), buVarInv * RD_GEN_B(S,B,T) * periodScale(T) ) )
*                                  ) * YEAR
*                                  + sum(B, buFixInv * RD_CAP_B(B))
*                                  + sum(L$SP_CAP_L(L), lineFixInv(L));

* Welfare after redispatch

  wf_all = (1-weight_rd)
            * (sum((S_co2,S_dloc,S_dlev,S_lcost),prob_scen(S_co2,S_dloc,S_dlev,S_lcost)
            * (( sum((D,T),(consObjA(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)
            - 0.5 * consObjB(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)) * periodScale(T))
            - sum((G,T), genVarInv(G,S_co2) * RD_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T))
            - sum((B,T), buVarInv(S_co2) * RD_GEN_B(B,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T))) * Year
            - sum(L$SP_CAP_L(L), lineFixInv(L,S_lcost))))
            - sum(G,genFixInv(G)* SP_CAP_G(G))
            - sum(B,buFixInv * RD_CAP_B(B)))
            + weight_rd
            * (VAR_RD_FIX - (1/(1-percentile)
            * sum((S_co2,S_dloc,S_dlev,S_lcost),prob_scen(S_co2,S_dloc,S_dlev,S_lcost)
            * ETA_RD_FIX(S_co2,S_dloc,S_dlev,S_lcost))));

  wf_rn = (sum((S_co2,S_dloc,S_dlev,S_lcost),prob_scen(S_co2,S_dloc,S_dlev,S_lcost)
            * (( sum((D,T),(consObjA(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)
            - 0.5 * consObjB(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)) * periodScale(T))
            - sum((G,T), genVarInv(G,S_co2) * RD_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T))
            - sum((B,T), buVarInv(S_co2) * RD_GEN_B(B,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T))) * Year
            - sum(L$SP_CAP_L(L), lineFixInv(L,S_lcost))))
            - sum(G,genFixInv(G)* SP_CAP_G(G))
            - sum(B,buFixInv * RD_CAP_B(B)));
  risk_adjustment = wf_all-wf_rn;

  wf_sc_all(S_co2,S_dloc,S_dlev,S_lcost) =
              (sum((D,T),(consObjA(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)
            - 0.5 * consObjB(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)) * periodScale(T))
            - sum((G,T), genVarInv(G,S_co2) * RD_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T))
            - sum((B,T), buVarInv(S_co2) * RD_GEN_B(B,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T))) * Year
            - sum(L$SP_CAP_L(L), lineFixInv(L,S_lcost))
            - sum(G,genFixInv(G)* SP_CAP_G(G))
            - sum(B,buFixInv * RD_CAP_B(B));

  total_generation(S_co2,S_dloc,S_dlev,S_lcost) = sum((G,T), RD_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost));
  total_bu_generation(S_co2,S_dloc,S_dlev,S_lcost) = sum((B,T),RD_GEN_B(B,T,S_co2,S_dloc,S_dlev,S_lcost));
  total_spot_generation(S_co2,S_dloc,S_dlev,S_lcost) = sum((G,T),SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost));
  priceSpotAvg(S_co2,S_dloc,S_dlev,S_lcost)$(prob_scen(S_co2,S_dloc,S_dlev,S_lcost) and sum((D,T),SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)*periodScale(T))) = sum((D,T),priceSpot(D,T,S_co2,S_dloc,S_dlev,S_lcost)*SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)*periodScale(T))/sum((D,T),SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)*periodScale(T));
  expPriceSpot = sum((S_co2,S_dloc,S_dlev,S_lcost),prob_scen(S_co2,S_dloc,S_dlev,S_lcost) * priceSpotAvg(S_co2,S_dloc,S_dlev,S_lcost));
  price_Spot_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) $prob_scen(S_co2,S_dloc,S_dlev,S_lcost) = sum(D$(D.Val = GenInZone(G)),  priceSpot(D,T,S_co2,S_dloc,S_dlev,S_lcost) ) ;
  priceAvgNode(D) = sum((S_co2,S_dloc,S_dlev,S_lcost),prob_scen(S_co2,S_dloc,S_dlev,S_lcost)*(sum(T, priceSpot(D,T,S_co2,S_dloc,S_dlev,S_lcost)*SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost))/(sum(T,SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)))));


***--------------------------------------------------------------------------***
***                       RESULTS to LOOP-PARAMETER                          ***
***--------------------------------------------------------------------------***

  Loop_welfare_all(Weight,LineInvest)           = wf_all        ;
  Loop_genInv(Weight,LineInvest, G)             = SP_CAP_G(G)   ;
  Loop_buInv(Weight, LineInvest, B)             = RD_CAP_B(B)  ;
  Loop_lineInv(Weight,LineInvest)               = sum(l, SP_CAP_L(L) ) ;
  Loop_expPriceSpot(Weight,LineInvest)          = expPriceSpot ;
  Loop_priceAvgNode(Weight, LineInvest, D)      = priceAvgNode(D);
  Loop_wf_rn(Weight)                            = wf_rn;
  Loop_risk_adjustment(Weight)                  = risk_adjustment;
  Loop_welfare_scenario_all(Weight, LineInvest,S_co2,S_dloc,S_dlev,S_lcost)  = wf_sc_all(S_co2,S_dloc,S_dlev,S_lcost);
  Loop_costs_sc_rd_l(Weight, LineInvest,S_co2,S_dloc,S_dlev,S_lcost) = Cost_sc_rd_l(S_co2,S_dloc,S_dlev,S_lcost);
  Loop_costs_sc_rd_g(Weight, LineInvest,S_co2,S_dloc,S_dlev,S_lcost) = Cost_sc_rd_g(S_co2,S_dloc,S_dlev,S_lcost);
  Loop_costs_sc_rd_b(Weight, LineInvest,S_co2,S_dloc,S_dlev,S_lcost) = Cost_sc_rd_b(S_co2,S_dloc,S_dlev,S_lcost);
  Loop_rents_sc_cr(Weight, LineInvest,S_co2,S_dloc,S_dlev,S_lcost)   = Rent_sc_cr(S_co2,S_dloc,S_dlev,S_lcost);
  Loop_totalRediCost(Weight, LineInvest) = totalRediCost;
  Loop_totalDem(Weight, LineInvest) = totalDem;

*** Consumer and Producer Surplus
  Loop_exp_rents_CS(Weight,LineInvest,D) = sum((S_co2,S_dloc,S_dlev,S_lcost),prob_scen(S_co2,S_dloc,S_dlev,S_lcost)
                                            * ((sum(T,(consObjA(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)
                                            - 0.5 * consObjB(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)
                                            * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)) * periodScale(T))
                                            - sum((T), (priceSpot(D,T,S_co2,S_dloc,S_dlev,S_lcost)
                                            * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)) * periodScale(T)))
                                             * YEAR)) ;

  Loop_exp_rents_PS(Weight,LineInvest,G)  = sum((S_co2,S_dloc,S_dlev,S_lcost),prob_scen(S_co2,S_dloc,S_dlev,S_lcost)
                                            *( sum((T), ( Price_Spot_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) - genVarInv(G,S_co2) ) * SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T) ) * YEAR
                                                                                         - genFixInv(G) * SP_CAP_G(G))) ;

  Loop_rents_sc_CS(Weight, LineInvest,D,S_co2,S_dloc,S_dlev,S_lcost) = (sum(T,(consObjA(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)
                                            - 0.5 * consObjB(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)
                                            * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)) * periodScale(T))
                                            - sum((T), (priceSpot(D,T,S_co2,S_dloc,S_dlev,S_lcost)
                                            * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)) * periodScale(T)))
                                            * YEAR ;
  Loop_rents_sc_PS(Weight, LineInvest,G,S_co2,S_dloc,S_dlev,S_lcost) = sum((T), ( Price_Spot_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) - genVarInv(G,S_co2) ) * SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T) ) * YEAR
                                                                                         - genFixInv(G) * SP_CAP_G(G);




***--------------------------------------------------------------------------***
***                     CLEAR PARAMETERs OF MODEL RUN                        ***
***--------------------------------------------------------------------------***

* Clear Spot Resuls
  option clear= SP_DEM           ;
  option clear= SP_GEN_G         ;
  option clear= SP_CAP_G         ;
  option clear= SP_FLOW          ;
  option clear= SP_CAP_L         ;
  option clear= wf_all           ;
  option clear= wf_sc_all        ;

  );
);

***--------------------------------------------------------------------------***
***                            END OF MODEL LOOP                             ***
***--------------------------------------------------------------------------***

***--------------------------------------------------------------------------***
***                 OUTPUT WITH RESULTS FOR BEST LINE INVEST                 ***
***--------------------------------------------------------------------------***

  Parameter
  Results_genInv(Weight,G)
  Results_buInv(Weight,B)
  Results_lineInv(Weight)
  maxWelfare(Weight)
  Results_welfare_all(Weight)
  Results_totalInv(Weight)
  Results_expPriceSpot(Weight)
  Results_priceAvgNode(Weight,D)
*  Results_expConsSurpl(Weight)
  Results_welfare_scenario_all(Weight,S_co2,S_dloc,S_dlev,S_lcost)
  Results_wf_rn(Weight)
  Results_risk_adjustment(Weight)
  Results_wf_market(Weight)
  Results_exp_rents_cs(Weight,D)
  Results_exp_rents_ps(Weight,G)
  Results_rents_sc_cr(Weight,S_co2,S_dloc,S_dlev,S_lcost)
  Results_rents_sc_cs(Weight,D,S_co2,S_dloc,S_dlev,S_lcost)
  Results_rents_sc_ps(Weight,G,S_co2,S_dloc,S_dlev,S_lcost)
  Results_rents_sc_total_cs(Weight,S_co2,S_dloc,S_dlev,S_lcost)
  Results_rents_sc_total_ps(Weight,S_co2,S_dloc,S_dlev,S_lcost)
  Results_costs_sc_rd_l(Weight,S_co2,S_dloc,S_dlev,S_lcost)
  Results_costs_sc_rd_g(Weight,S_co2,S_dloc,S_dlev,S_lcost)
  Results_costs_sc_rd_b(Weight,S_co2,S_dloc,S_dlev,S_lcost)
  Results_totalRediCost(Weight)
  Results_totalDem(Weight)
  ;


  Loop(LineInvest,

    maxWelfare(Weight)$(Loop_welfare_all(Weight,LineInvest)=smax(LineInvest2, Loop_welfare_all(Weight,LineInvest2) )) = LineInvest.val + xscale(weight)             ;

  );
$offorder

  Results_genInv(Weight,G)                     = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_genInv(Weight,LineInvest, G) )         ;
  Results_buInv(Weight,B)                      = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_buInv(Weight,LineInvest, B) )         ;
  Results_lineInv(Weight)                      = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_lineInv(Weight,LineInvest) )           ;
  Results_welfare_all(Weight)                  = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_welfare_all(Weight,LineInvest) )        ;
  Results_totalInv(Weight)                     = sum(G,Results_genInv(Weight,G)) +  sum(B, Results_buInv(Weight,B));
  Results_expPriceSpot(Weight)                 = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_expPriceSpot(Weight,LineInvest) )        ;
  Results_priceAvgNode(Weight,D)               = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_priceAvgNode(Weight,LineInvest,D) )        ;
*  Results_expConsSurpl(Weight)                 = sum(LineInvest$(ord(LineInvest)=maxWelfare(Weight)), Loop_expConsSurpl(Weight,LineInvest) )        ;
  Results_welfare_scenario_all(Weight,S_co2,S_dloc,S_dlev,S_lcost) = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_welfare_scenario_all(Weight,LineInvest,S_co2,S_dloc,S_dlev,S_lcost) )        ;
  Results_wf_rn(Weight)                       = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_wf_rn(Weight) );
  Results_risk_adjustment(Weight)             = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_risk_adjustment(Weight) );
  Results_exp_rents_cs(Weight,D)              = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_exp_rents_cs(Weight,LineInvest,D) )         ;
  Results_exp_rents_ps(Weight,G)              = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_exp_rents_ps(Weight,LineInvest,G) )         ;
  Results_rents_sc_cs(Weight,D,S_co2,S_dloc,S_dlev,S_lcost) = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_rents_sc_cs(Weight, LineInvest,D,S_co2,S_dloc,S_dlev,S_lcost) );
  Results_rents_sc_ps(Weight,G,S_co2,S_dloc,S_dlev,S_lcost) = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_rents_sc_ps(Weight, LineInvest,G,S_co2,S_dloc,S_dlev,S_lcost) );
  Results_rents_sc_cr(Weight,S_co2,S_dloc,S_dlev,S_lcost)   = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_rents_sc_cr(Weight, LineInvest,S_co2,S_dloc,S_dlev,S_lcost) );
  Results_rents_sc_total_cs(Weight,S_co2,S_dloc,S_dlev,S_lcost) = sum(D,Results_rents_sc_cs(Weight,D,S_co2,S_dloc,S_dlev,S_lcost));
  Results_rents_sc_total_ps(Weight,S_co2,S_dloc,S_dlev,S_lcost) = sum(G,Results_rents_sc_ps(Weight,G,S_co2,S_dloc,S_dlev,S_lcost));
  Results_costs_sc_rd_l(Weight,S_co2,S_dloc,S_dlev,S_lcost) = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_costs_sc_rd_l(Weight, LineInvest,S_co2,S_dloc,S_dlev,S_lcost) );
  Results_costs_sc_rd_g(Weight,S_co2,S_dloc,S_dlev,S_lcost) = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_costs_sc_rd_g(Weight, LineInvest,S_co2,S_dloc,S_dlev,S_lcost) );
  Results_costs_sc_rd_b(Weight,S_co2,S_dloc,S_dlev,S_lcost) = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_costs_sc_rd_b(Weight, LineInvest,S_co2,S_dloc,S_dlev,S_lcost) );
  Results_totalRediCost(Weight)             = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_totalRediCost(Weight,LineInvest) );
  Results_totalDem(Weight)             = sum(LineInvest$(ord(LineInvest)+xscale(weight)=maxWelfare(Weight)), Loop_totalDem(Weight,LineInvest) );

$include output_writer_ra.gms
