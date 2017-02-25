(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



(* ::Input:: *)
ClearAll[coefficient1];
coefficient1::usage="Set coefficient1=1 (default) or coefficient=-1";
coefficient1=1;


(* ::Input:: *)
(*********************************************************************************)
(*                             Objective function                                *)
(*********************************************************************************)
ClearAll[objective];
objective::usage="objective[dataArray,x1,x2,...,xn] defines the objective function to maximize, as the number of satisfied inequalities. For a specific x-vector value we get a list of numbers. The number of positives is the outcome.";
objective[dataArray_,b__?NumericQ]:=(*Defining as a pure function may speed this up*)
(++objectivecounter;Total@UnitStep@(*http://mathematica.stackexchange.com/a/9673/7966*)
(dataArray.Prepend[{b},N[coefficient1]]));



(* ::Input:: *)
(*********************************************************************************)
(*                           Verbose Objective function                          *)(*         to calculate number of satisfied inequalities per market              *)
(*********************************************************************************)
ClearAll[objectiveV];
objectiveV::usage="objectiveV[dataArray,x1,x2,...,xn] is the verbose version of objective routine. It also uses groupIDs produced by CdataArray routine. It returns more information about how many inequalities are satisfied for each market. It is obviously slower than the plain objective and it is used as the final step after the maximization process.";
objectiveV[dataArray_,b__?NumericQ]:=Module[{dataarray,groupids,satisfiedineqs,totalineqs,stats},
dataarray=dataArray.Prepend[{b},N[coefficient1]];
groupids=Flatten@groupIDs;
totalineqs=(Tally@groupIDs)[[All,2]];
satisfiedineqs=Total[UnitStep[#]]&/@((GatherBy[Transpose[{dataarray,groupids}],Last])[[All,All,1]]);

stats=MapThread[Insert,{
{Range@Length@satisfiedineqs,satisfiedineqs,totalineqs,Chop@Round[100. satisfiedineqs/totalineqs,1]},{"Market no","Satisfied","Total","Percentage %"},Table[1,{4}]}]

];