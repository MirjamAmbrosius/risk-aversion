  Parameters

  Test

*welfare
  wf_sp                  "spot market welfare"
  wf_sc_sp(S)            "spot market welfare for scenario s"
  wf_SP_Test             "TEST"
  wf_sc_all(S)           "final welfare for scenario s"
  wf_all                 "final welfare"
  wf_SP_d(S,D)
*  nodal_welfare(S,N)     "welfare for node d in scenario s"

*costs
  ct_RD_TEST
* COST_FC_G
  Cost_sc_rd_g(S)
  Cost_sc_rd_b(S)
  Cost_sc_rd_l(S)
  Cost_sc_sp_g(S)
  Cost_fc_l
  Cost_fc_b
  Cost_fc_g
  Cost_sc_cr(S)          "Congestion rent by scenario"
*  genCost                "cost of generation investment"
*  buCost
  rediCost(S)            "network costs and redispatch cost in scenario s"
  totalRediCost          "total redispatch cost for all scenarios"
  rediGenCost            "cost for generation redispatch in scenario s"
  rediBuCost             "variable cost for backup capacity in scenario s"
  Demand
*investment
  SP_CAP_G(G)            "investment decision in conv. generation capacity of spot market level"
  RD_CAP_B(B)             "investment of backup generator B"
*generation and demand
  SP_DEM(S,D,T)          "demand Spot"
  SP_GEN_G(S,G,T)        "generation amount Spot"
  RD_GEN_G(S,G,T)        "generation after Redispatch"
  RD_GEN_B(S,B,T)        "generation of backup capacity b in scenario s and time t"
  RD_DEM_L(S,D,T)        "load shedding"
*  averageDemand(S,D,T)   "total redispatched demand of consumer d over all periods and scenarios"

*prices
  priceD_Spot(S,D,T)     "price for consumer d in period t in scenario s"
  priceG_Spot(S,G,T)     "price for producer g in period t in scenario s"
  Price_SP_nodalAvg(S,N)
  Price_RD_Markup(S)
  Price_FI_nodal(S,N)

*  avgPriceSpot(S)        "average price in scenario s"
*  nodalAvgPriceSpot(S,N) "average price for node n in scenario s"
*  totalAvgPriceSpot      "weighted average spot price over all scenarios"
*transmission
  lineB(L)
  SP_FLOW(S,L,T)
  SP_CAP_L(L)
  RD_FLOW(S,L,T)         "flow through line L in scenario s and time t after redispatch"
*  networkRevenues(S)     "network revenues in scenario s"
*  networkFee(S)          "network fee in scenario s"
*utilization
*  avgGenUtilization(S,G) "average utilization of generator g in scenario s"
*  avgLineUtilization(S)  "average utilization of transmission capacity in scenario s"
*  avgBuUtilization(S,B)  "average utilization of backup b in scenario s"

*risk aversion
weight_spot              "weight assigned to the worst-case spot market outcome for risk averse market participants"
weight_redi              "weight assigned to the worst-case redispacth outcome for risk averse market participants"
percentile               "lower percentile of welfare function that is considered to be the worst case"

  Loop_Probability_results(Loop_Probability,S);

  Parameters
  Loop_welfare_sp(Loop_Probability, LineInvest)          "spot market welfare"
  Loop_welfare_sp_sc(Loop_Probability,LineInvest,S)      "spot market welfare for scenario s"
  Loop_welfare_all_sc(Loop_Probability,LineInvest,S)     "welfare for scenario s"
  Loop_welfare_all(Loop_Probability,LineInvest)          "total welfare"
  Loop_welfare_sp_TEST(Loop_Probability, LineInvest)
  Loop_welfare_sp_sc_d(Loop_Probability, LineInvest,S,D)

  Loop_genInv(Loop_Probability, LineInvest, G)           "generation investment"
  Loop_lineInv(Loop_Probability,LineInvest)              "cost of line investement"

  Loop_price_SP_D(Loop_Probability,LineInvest,S,D,T)     "price for consumer d in period t in scenario s"
  Loop_price_SP_G(Loop_Probability,LineInvest,S,G,T)     "price for generators g in period t in scenario s"
  Loop_price_SP_nodal(Loop_Probability,LineInvest,S,N)
  Loop_price_RD_markup(Loop_Probability,LineInvest,S,results)
  Loop_price_Final(Loop_Probability,LineInvest,S,N)

  Loop_results_rents_A(Loop_Probability,LineInvest,S,results)
  Loop_results_rents_N(Loop_Probability,LineInvest,S,N,results)
  Loop_rents_CS(Loop_Probability,LineInvest,D,S)
  Loop_rents_PS(Loop_Probability,LineInvest,G,S)
  Loop_profits_PS(Loop_Probability,LineInvest,G,S)

  Loop_redispatch_TEST(Loop_Probability, LineInvest)
  Loop_redispatch(Loop_Probability, LineInvest)
  Loop_redispatch_sc(Loop_Probability, LineInvest,s)

  Loop_demand(Loop_Probability, LineInvest,S,N)
  Loop_nodal(Loop_Probability, LineInvest,S,N,results)

$ontext
  Loop_nodal_welfare(Loop_Probability, LineInvest, S,N)  "welfare for node d in scenario s"
  Loop_avgPriceSpot(Loop_Probability,LineInvest,S)       "average price in scenario s"
  Loop_nodalAvgPriceSpot(Loop_Probability,LineInvest,S,N)"average price for node n in scenario s"

  Loop_genCost(Loop_Probability,LineInvest)              "cost of generation investment"
  Loop_buCost(Loop_Probability,LineInvest)               "cost of generation investment"


  Loop_buInv(Loop_Probability, LineInvest, B)            "generation investment backup capacity"
*  Loop_resInv(Loop_Probability, LineInvest, R)           "generation investment RES capacity"
  Loop_totalAvgPriceSpot(Loop_Probability, LineInvest)   "weighted average spot price over all scenarios"
  Loop_demand(Loop_Probability, LineInvest,S,D,T)        "redispatched demand of consumer D"
  Loop_avgPriceCons(Loop_Probability, LineInvest, S,D)   "weighted average price at consumer d in scenario s over all periods"


  Loop_rediCost(Loop_Probability, LineInvest, S)         "redispatch cost in scenario s"
  Loop_totalRediCost(Loop_Probability, LineInvest)       "total redispatch cost in all scenarios"
  Loop_rediGenCost(Loop_Probability, LineInvest, S)      "cost for generation redispatch in scenario s"
  Loop_rediBuCost(Loop_Probability, LineInvest, S)       "variable cost for backup capacity in scenario s"


  Loop_flowFinal(Loop_Probability, LineInvest, S,L,T)            "flow through line L in scenario s and time t after redispatch"
  Loop_generationBU(Loop_Probability, LineInvest,S,B,T)          "generation of backup capacity b in scenario s and time t"
  Loop_generation(Loop_Probability, LineInvest,S,G,T)            "generation of generator g in scenario s and time t"
  Loop_totalLineCapacity(Loop_Probability, LineInvest)           "total line capacity"
  Loop_avgGenUtilization(Loop_Probability, LineInvest, S,G)      "average utilization of generator g in scenario s"
  Loop_avgLineUtilization(Loop_Probability, LineInvest,S)        "average utilization of transmission capacity in scenario s"
  Loop_avgBuUtilization(Loop_Probability, LineInvest, S,B)       "average utilization of backup b in scenario s"
  Loop_networkFee(Loop_Probability, LineInvest, S)               "network fee in scenario s"
  Loop_networkRev(Loop_Probability,LineInvest,S)                 "Congestion rents"
  Loop_results_rents_N(Loop_Probability,LineInvest,S,N,results)

  Loop_price_comp(Loop_Probability,LineInvest,N,results)
  Loop_RD_comp(Loop_Probability,LineInvest,N,results)
  Loop_CR_comp(Loop_Probability,LineInvest,N,S)
  Loop_results_price_N(Loop_Probability,LineInvest,S,N,results)
  Loop_results_price_A(Loop_Probability,LineInvest,S,results)
$offtext
;
