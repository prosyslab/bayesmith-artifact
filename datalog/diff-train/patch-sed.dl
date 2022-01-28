.type Node <: symbol

.decl Alarm(v0: Node, v1: Node)
.decl AlarmDerefExp(v0: Node, v1: Node)
.decl AlarmMemchr(v0: Node, v1: Node, v2: Node)
.decl AlarmStrcat(v0: Node, v1: Node, v2: Node)
.decl AlarmStrcpy(v0: Node, v1: Node, v2: Node)
.decl AlarmStrncpy(v0: Node, v1: Node, v2: Node, v3: Node)
.decl Assign(v0: Node, v1: Node, v2: Node)
.decl Assume(v0: Node, v1: Node)
.decl BinOpExp(v0: Node, v1: Node, v2: Node, v3: Node)
.decl CastExp(v0: Node, v1: Node)
.decl DUEdge(v0: Node, v1: Node)
.decl DUPath(v0: Node, v1: Node)
.decl FalseBranch(v0: Node, v1: Node)
.decl FalseCond(v0: Node)
.decl LibCall(v0: Node, v1: Node)
.decl LoopHead(v0: Node)
.decl LvalExp(v0: Node, v1: Node)
.decl SparrowAlarm(v0: Node, v1: Node, v2: Node)
.decl TrueBranch(v0: Node, v1: Node)
.decl TrueCond(v0: Node)

.input AlarmDerefExp
.input AlarmMemchr
.input AlarmStrcat
.input AlarmStrcpy
.input AlarmStrncpy
.input Assign
.input Assume
.input BinOpExp
.input CastExp
.input DUEdge
.input FalseBranch
.input FalseCond
.input LibCall
.input LoopHead
.input LvalExp
.input SparrowAlarm
.input TrueBranch
.input TrueCond
.output Alarm
.output DUPath
.decl Deriv_Alarm13(v0: Node, v1: Node, v2: Node, v3: Node)
.decl Deriv_Alarm14(v0: Node, v1: Node, v2: Node, v3: Node, v4: Node)
.decl Deriv_Alarm15(v0: Node, v1: Node, v2: Node, v3: Node, v4: Node)
.decl Deriv_Alarm17(v0: Node, v1: Node, v2: Node)
.decl Deriv_Alarm18(v0: Node, v1: Node, v2: Node)
.decl Deriv_Alarm19(v0: Node, v1: Node, v2: Node, v3: Node)
.decl Deriv_Alarm20(v0: Node, v1: Node, v2: Node, v3: Node)
.decl Deriv_Alarm21(v0: Node, v1: Node, v2: Node, v3: Node, v4: Node)
.decl Deriv_Alarm24(v0: Node, v1: Node, v2: Node, v3: Node, v4: Node, v5: Node)
.decl Deriv_Alarm25(v0: Node, v1: Node, v2: Node, v3: Node, v4: Node, v5: Node)
.decl Deriv_Alarm4(v0: Node, v1: Node, v2: Node, v3: Node)
.decl Deriv_Alarm7(v0: Node, v1: Node, v2: Node, v3: Node)
.decl Deriv_Alarm8(v0: Node, v1: Node, v2: Node, v3: Node)
.decl Deriv_Alarm9(v0: Node, v1: Node, v2: Node, v3: Node)
.decl Deriv_DUPath0(v0: Node, v1: Node)
.decl Deriv_DUPath1(v0: Node, v1: Node)
.decl Deriv_DUPath10(v0: Node, v1: Node, v2: Node)
.decl Deriv_DUPath11(v0: Node, v1: Node, v2: Node)
.decl Deriv_DUPath12(v0: Node, v1: Node, v2: Node)
.decl Deriv_DUPath16(v0: Node, v1: Node, v2: Node)
.decl Deriv_DUPath2(v0: Node, v1: Node)
.decl Deriv_DUPath22(v0: Node, v1: Node, v2: Node, v3: Node)
.decl Deriv_DUPath23(v0: Node, v1: Node, v2: Node, v3: Node)
.decl Deriv_DUPath3(v0: Node, v1: Node, v2: Node)
.decl Deriv_DUPath5(v0: Node, v1: Node, v2: Node)
.decl Deriv_DUPath6(v0: Node, v1: Node, v2: Node)

.output Deriv_Alarm13
.output Deriv_Alarm14
.output Deriv_Alarm15
.output Deriv_Alarm17
.output Deriv_Alarm18
.output Deriv_Alarm19
.output Deriv_Alarm20
.output Deriv_Alarm21
.output Deriv_Alarm24
.output Deriv_Alarm25
.output Deriv_Alarm4
.output Deriv_Alarm7
.output Deriv_Alarm8
.output Deriv_Alarm9
.output Deriv_DUPath0
.output Deriv_DUPath1
.output Deriv_DUPath10
.output Deriv_DUPath11
.output Deriv_DUPath12
.output Deriv_DUPath16
.output Deriv_DUPath2
.output Deriv_DUPath22
.output Deriv_DUPath23
.output Deriv_DUPath3
.output Deriv_DUPath5
.output Deriv_DUPath6

DUPath(v6, v7) :- DUEdge(v6, v7).
DUPath(v6, v7) :- FalseBranch(v6, v7).
DUPath(v6, v7) :- TrueBranch(v6, v7).
DUPath(v6, v7) :- DUPath(v6, v8), FalseCond(v8), FalseBranch(v8, v7).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), AlarmDerefExp(v12, v13), LvalExp(v13, _).
DUPath(v6, v7) :- DUPath(v6, v8), TrueCond(v8), TrueBranch(v8, v7), Assume(v7, _).
DUPath(v6, v7) :- DUPath(v6, v8), TrueCond(v8), TrueBranch(v8, v7), !Assume(v7, _).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), AlarmStrcat(v12, v1581, _), !CastExp(v1581, _).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), AlarmDerefExp(v12, v13), BinOpExp(v13, _, _, _), !LvalExp(v13, _).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), AlarmDerefExp(v12, v13), !BinOpExp(v13, _, _, _), !LvalExp(v13, _).
DUPath(v6, v7) :- DUPath(v6, v8), SparrowAlarm(v6, _, _), Assign(v8, _, _), LoopHead(v8), DUEdge(v8, v7).
DUPath(v6, v7) :- DUPath(v6, v8), SparrowAlarm(v6, _, _), Assign(v8, _, _), !LoopHead(v8), DUEdge(v8, v7).
DUPath(v6, v7) :- DUPath(v6, v8), SparrowAlarm(v6, _, _), !Assign(v8, _, _), LoopHead(v8), DUEdge(v8, v7).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmStrcat(v12, _, _), AlarmStrncpy(v12, v192, _, _), !CastExp(v192, _).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), AlarmStrcat(v12, v1581, v1818), CastExp(v1581, _), CastExp(v1818, _).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), AlarmStrcat(v12, v1581, v1818), CastExp(v1581, _), !CastExp(v1818, _).
DUPath(v6, v7) :- DUPath(v6, v8), SparrowAlarm(v6, _, _), !Assign(v8, _, _), !LibCall(v8, _), !LoopHead(v8), DUEdge(v8, v7).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), AlarmMemchr(v12, _, _), !AlarmStrcat(v12, _, _), !AlarmStrcpy(v12, _, _), !AlarmStrncpy(v12, _, _, _).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmMemchr(v12, _, _), !AlarmStrcat(v12, _, _), !AlarmStrcpy(v12, _, _), !AlarmStrncpy(v12, _, _, _).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmStrcat(v12, _, _), !AlarmStrncpy(v12, _, _, _), AlarmStrcpy(v12, _, v6483), CastExp(v6483, _).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmStrcat(v12, _, _), !AlarmStrncpy(v12, _, _, _), AlarmStrcpy(v12, _, v6483), !CastExp(v6483, _).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmStrcat(v12, _, _), AlarmStrncpy(v12, v192, v202, _), CastExp(v192, _), !CastExp(v202, _).
DUPath(v6, v7) :- DUPath(v6, v8), SparrowAlarm(v6, _, _), !Assign(v8, _, _), !LoopHead(v8), DUEdge(v8, v7), LibCall(v8, v1666), LvalExp(v1666, _).
DUPath(v6, v7) :- DUPath(v6, v8), SparrowAlarm(v6, _, _), !Assign(v8, _, _), !LoopHead(v8), DUEdge(v8, v7), LibCall(v8, v1666), !LvalExp(v1666, _).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmStrcat(v12, _, _), CastExp(v192, _), AlarmStrncpy(v12, v192, v202, v208), CastExp(v202, _), CastExp(v208, _).
Alarm(v6, v7) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmStrcat(v12, _, _), CastExp(v192, _), AlarmStrncpy(v12, v192, v202, v208), CastExp(v202, _), !CastExp(v208, _).
Deriv_DUPath0(v6, v7) :- DUEdge(v6, v7).
Deriv_DUPath1(v6, v7) :- FalseBranch(v6, v7).
Deriv_DUPath2(v6, v7) :- TrueBranch(v6, v7).
Deriv_DUPath3(v6, v7, v8) :- DUPath(v6, v8), FalseCond(v8), FalseBranch(v8, v7).
Deriv_Alarm4(v6, v7, v12, v13) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), AlarmDerefExp(v12, v13), LvalExp(v13, _).
Deriv_DUPath5(v6, v7, v8) :- DUPath(v6, v8), TrueCond(v8), TrueBranch(v8, v7), Assume(v7, _).
Deriv_DUPath6(v6, v7, v8) :- DUPath(v6, v8), TrueCond(v8), TrueBranch(v8, v7), !Assume(v7, _).
Deriv_Alarm7(v6, v7, v12, v1581) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), AlarmStrcat(v12, v1581, _), !CastExp(v1581, _).
Deriv_Alarm8(v6, v7, v12, v13) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), AlarmDerefExp(v12, v13), BinOpExp(v13, _, _, _), !LvalExp(v13, _).
Deriv_Alarm9(v6, v7, v12, v13) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), AlarmDerefExp(v12, v13), !BinOpExp(v13, _, _, _), !LvalExp(v13, _).
Deriv_DUPath10(v6, v7, v8) :- DUPath(v6, v8), SparrowAlarm(v6, _, _), Assign(v8, _, _), LoopHead(v8), DUEdge(v8, v7).
Deriv_DUPath11(v6, v7, v8) :- DUPath(v6, v8), SparrowAlarm(v6, _, _), Assign(v8, _, _), !LoopHead(v8), DUEdge(v8, v7).
Deriv_DUPath12(v6, v7, v8) :- DUPath(v6, v8), SparrowAlarm(v6, _, _), !Assign(v8, _, _), LoopHead(v8), DUEdge(v8, v7).
Deriv_Alarm13(v6, v7, v12, v192) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmStrcat(v12, _, _), AlarmStrncpy(v12, v192, _, _), !CastExp(v192, _).
Deriv_Alarm14(v6, v7, v12, v1581, v1818) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), AlarmStrcat(v12, v1581, v1818), CastExp(v1581, _), CastExp(v1818, _).
Deriv_Alarm15(v6, v7, v12, v1581, v1818) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), AlarmStrcat(v12, v1581, v1818), CastExp(v1581, _), !CastExp(v1818, _).
Deriv_DUPath16(v6, v7, v8) :- DUPath(v6, v8), SparrowAlarm(v6, _, _), !Assign(v8, _, _), !LibCall(v8, _), !LoopHead(v8), DUEdge(v8, v7).
Deriv_Alarm17(v6, v7, v12) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), AlarmMemchr(v12, _, _), !AlarmStrcat(v12, _, _), !AlarmStrcpy(v12, _, _), !AlarmStrncpy(v12, _, _, _).
Deriv_Alarm18(v6, v7, v12) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmMemchr(v12, _, _), !AlarmStrcat(v12, _, _), !AlarmStrcpy(v12, _, _), !AlarmStrncpy(v12, _, _, _).
Deriv_Alarm19(v6, v7, v12, v6483) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmStrcat(v12, _, _), !AlarmStrncpy(v12, _, _, _), AlarmStrcpy(v12, _, v6483), CastExp(v6483, _).
Deriv_Alarm20(v6, v7, v12, v6483) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmStrcat(v12, _, _), !AlarmStrncpy(v12, _, _, _), AlarmStrcpy(v12, _, v6483), !CastExp(v6483, _).
Deriv_Alarm21(v6, v7, v12, v192, v202) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmStrcat(v12, _, _), AlarmStrncpy(v12, v192, v202, _), CastExp(v192, _), !CastExp(v202, _).
Deriv_DUPath22(v6, v7, v8, v1666) :- DUPath(v6, v8), SparrowAlarm(v6, _, _), !Assign(v8, _, _), !LoopHead(v8), DUEdge(v8, v7), LibCall(v8, v1666), LvalExp(v1666, _).
Deriv_DUPath23(v6, v7, v8, v1666) :- DUPath(v6, v8), SparrowAlarm(v6, _, _), !Assign(v8, _, _), !LoopHead(v8), DUEdge(v8, v7), LibCall(v8, v1666), !LvalExp(v1666, _).
Deriv_Alarm24(v6, v7, v12, v192, v202, v208) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmStrcat(v12, _, _), CastExp(v192, _), AlarmStrncpy(v12, v192, v202, v208), CastExp(v202, _), CastExp(v208, _).
Deriv_Alarm25(v6, v7, v12, v192, v202, v208) :- DUPath(v6, v7), SparrowAlarm(v6, v7, v12), !AlarmDerefExp(v12, _), !AlarmStrcat(v12, _, _), CastExp(v192, _), AlarmStrncpy(v12, v192, v202, v208), CastExp(v202, _), !CastExp(v208, _).