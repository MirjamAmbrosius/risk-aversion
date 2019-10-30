Parameters

*welfare
  wf_sp                  "spot market welfare"
*Welfare after redispatch and investment costs in scenario S
  wf_sc_all(S_co2,S_dloc,S_dlev,S_lcost)      "welfare in each scenario"
  wf_all                 "final welfare"
  wf_rn     "welfare witout risk adjustment"
  risk_adjustment "value of worst case adjustment in objective function"

*costs
 Cost_sc_sp_g(S_co2,S_dloc,S_dlev,S_lcost)         "variable generation costs per scenario"
 Cost_sc_rd_g(S_co2,S_dloc,S_dlev,S_lcost)         "redispatch costs existing capacity per scenario"
 Cost_sc_rd_b(S_co2,S_dloc,S_dlev,S_lcost)         "redispatch costs backup capacity per scenario"
 Cost_sc_rd_l(S_co2,S_dloc,S_dlev,S_lcost)         "fixed line investment cost"
 Cost_fc_b                                         "fixed backup investment cost"
 Cost_fc_g                                         "fixed generation capacity investment cost"
 rediCost(S_co2,S_dloc,S_dlev,S_lcost)             "total congestion management cost (line invest, redi, bu)"
 Rent_sc_cr(S_co2,S_dloc,S_dlev,S_lcost)          "total congestion rent per scenario"

*generation and demand
  SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)          "demand Spot"
  SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost)        "generation amount Spot"
  RD_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost)        "generation after Redispatch"
  RD_GEN_B(B,T,S_co2,S_dloc,S_dlev,S_lcost)        "generation of backup capacity b in scenario s and time t"
  lineB(L)
  SP_FLOW(L,T,S_co2,S_dloc,S_dlev,S_lcost)
  SP_CAP_L(L)
  SP_CAP_G(G)
  RD_CAP_B(B)
  Loop_welfare_all(Weight,LineInvest)          "total welfare"
  Loop_genInv(Weight,LineInvest, G)           "generation investment"
  Loop_buInv(Weight, LineInvest, B)            "investment in backup capacity"
  Loop_lineInv(Weight,LineInvest)              "cost of line investement"
  Loop_expPriceSpot(Weight,LineInvest)          "expected spot price"
  Loop_priceAvgNode(Weight, LineInvest, D)      "expected average spot price per node"
  Loop_expConsSurpl(Weight, LineInvest)         "expected consumer surplus"
  Loop_welfare_scenario_all(Weight, LineInvest, S_co2,S_dloc,S_dlev,S_lcost)    "welfare per scenario"
  Loop_wf_rn(Weight)                            "risk neutral welfare"
  Loop_risk_adjustment(Weight)                   "value of risk adjustment"
  Loop_exp_rents_CS(Weight,LineInvest,D)        "expected consumer surplus"
  Loop_exp_rents_PS(Weight,LineInvest,G)        "expected producer surplus"
  Loop_rents_sc_CS(Weight, LineInvest,D,S_co2,S_dloc,S_dlev,S_lcost) "consumer rents per scenario"
  Loop_rents_sc_PS(Weight, LineInvest,G,S_co2,S_dloc,S_dlev,S_lcost) "producer rents per scenario"
  Loop_rents_sc_cr(Weight, LineInvest,  S_co2,S_dloc,S_dlev,S_lcost) "congestion rent per scenario"
  Loop_costs_sc_rd_l(Weight, LineInvest,S_co2,S_dloc,S_dlev,S_lcost) "network cost per scenario"
  Loop_costs_sc_rd_g(Weight, LineInvest,S_co2,S_dloc,S_dlev,S_lcost) "generation redispatch cost per scenario"
  Loop_costs_sc_rd_b(Weight, LineInvest,S_co2,S_dloc,S_dlev,S_lcost) "bu redispatch cost per scenario"


  total_generation(S_co2,S_dloc,S_dlev,S_lcost)               "total generation by private firms"
  total_bu_generation(S_co2,S_dloc,S_dlev,S_lcost)            "total bu generation"
  total_spot_generation(S_co2,S_dloc,S_dlev,S_lcost)          "total spot generation"
  priceSpot(D,T,S_co2,S_dloc,S_dlev,S_lcost)                  "spot price per node and time step"
  priceSpotAvg(S_co2,S_dloc,S_dlev,S_lcost)                   "weighted average spot price"
  expPriceSpot                                                "expected weighted average spot market price"
  price_Spot_G(G,T,S_co2,S_dloc,S_dlev,S_lcost)               "spot price generators per scenario"
  priceAvgNode(D)                                             "Average expected spot price at node D"
  consumerSurplus(D,S_co2,S_dloc,S_dlev,S_lcost)                "Consumer surplus in scenario s"
  totalConsSurpl(S_co2,S_dloc,S_dlev,S_lcost)                   "total consumer surplus in scenario s"
  expConsSurpl                                  "expected total consumer surplus"

* Risk Aversion
  VAR_RD_FIX        "value at risk redispatch (cutoff point for tale)"
  ETA_RD_FIX(S_co2,S_dloc,S_dlev,S_lcost)   "eta redispatch stage"
;
