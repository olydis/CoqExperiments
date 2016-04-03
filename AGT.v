Require Import Coq.Unicode.Utf8 Arith Bool Ring Setoid String.
Require Import Coq.Lists.ListSet.
Require Import Coq.Sets.Powerset.

(*set*)

(*
Inductive set (t : Type) : Type :=
| SetEmpty : set t
| SetCons : t -> set t -> set t.

Fixpoint set_in (t : Type) (x : t) (s : set t) :=
  match s with
  | SetEmpty _ => False
  | SetCons _ x' s' => x = x' \/ set_in t x s'
  end.*)

(*recusive approach... nope
Inductive type' (nested_type : Set) : Set :=
| Int : type' nested_type
| Bool : type' nested_type
| Func : nested_type -> nested_type -> type' nested_type.
*)

(**Types**)

Inductive primitive_type : Set :=
| Int : primitive_type
| Bool : primitive_type.

Inductive type : Set :=
| TPrimitive : primitive_type -> type
| TFunc : type -> type -> type.

Inductive gtype : Set :=
| GPrimitive : primitive_type -> gtype
| GFunc : gtype -> gtype -> gtype
| GUnknown : gtype.

Inductive tdom : type -> type -> Prop := 
| TDom : forall t a b, t = TFunc a b -> tdom t a.
Inductive tcod : type -> type -> Prop := 
| TCod : forall t a b, t = TFunc a b -> tcod t b.
Inductive tequate : type -> type -> type -> Prop :=
| TEquate : forall t, tequate t t t.

Inductive gdom : gtype -> gtype -> Prop := 
| GDom : forall t a b, t = GFunc a b -> gdom t a
| GDomU : gdom GUnknown GUnknown.
Inductive gcod : gtype -> gtype -> Prop := 
| GCod : forall t a b, t = GFunc a b -> gcod t b
| GCodU : gcod GUnknown GUnknown.
Inductive gequate : gtype -> gtype -> gtype -> Prop :=
| GEquatePrim : forall t, gequate (GPrimitive t) (GPrimitive t) (GPrimitive t)
| GEquateUL : forall t, gequate GUnknown t t
| GEquateUR : forall t, gequate t GUnknown t
| GEquateAbs : forall t11 t12 t21 t22 tx1 tx2, 
  gequate t11 t21 tx1 -> gequate t12 t22 tx2 -> gequate (GFunc t11 t12) (GFunc t21 t22)  (GFunc tx1 tx2).

Inductive class_gtype_cons : gtype -> gtype -> Prop :=
| GTypeConsRefl : forall t, class_gtype_cons t t
| GTypeConsUL : forall t, class_gtype_cons GUnknown t
| GTypeConsUR : forall t, class_gtype_cons t GUnknown
| GTypeConsAbs : forall t11 t12 t21 t22, 
  class_gtype_cons t11 t21 ->
  class_gtype_cons t12 t22 ->
  class_gtype_cons (GFunc t11 t12) (GFunc t21 t22).

(*checks*)
Theorem class_gtype_cons1 :
(class_gtype_cons
   (GFunc (GPrimitive Int) GUnknown)
   (GFunc GUnknown (GPrimitive Bool))).
Proof.
  apply GTypeConsAbs.
  apply GTypeConsUR.
  apply GTypeConsUL.
Qed.

Theorem class_gtype_cons2 :
~ (class_gtype_cons
   (GFunc (GPrimitive Int) (GPrimitive Int))
   (GFunc (GPrimitive Int) (GPrimitive Bool))).
Proof.
  unfold not.
  intros.
  inversion H.
  inversion H5.
Qed.


(**TFL**)
Definition tfl_Var := string.
Inductive tfl_t (tfl_T : Set) : Set :=
| TflTermNat : nat -> tfl_t tfl_T
| TflTermBool : bool -> tfl_t tfl_T
| TflTermVar : tfl_Var -> tfl_t tfl_T
| TflTermAbs : tfl_Var -> tfl_T -> tfl_t tfl_T -> tfl_t tfl_T
| TflTermApp : tfl_t tfl_T -> tfl_t tfl_T -> tfl_t tfl_T
| TflTermPlus : tfl_t tfl_T -> tfl_t tfl_T -> tfl_t tfl_T
| TflTermIf : tfl_t tfl_T -> tfl_t tfl_T -> tfl_t tfl_T -> tfl_t tfl_T
| TflTermAssert : tfl_t tfl_T -> tfl_T -> tfl_t tfl_T.

Definition tfl_T_context (tfl_T : Set) := tfl_Var -> tfl_T -> Prop.

Definition tfl_T_context_empty (tfl_T : Set) : tfl_T_context tfl_T := fun x' t' => False.
Definition tfl_T_context_set (tfl_T : Set) (x : tfl_Var) (t : tfl_T) (c : tfl_T_context tfl_T) : tfl_T_context tfl_T :=
  fun x' t' => (x = x' /\ t = t') \/ c x' t'.

(**STFL**)
Definition stfl_T := type.
Definition stfl_Tcons := fun (a b : stfl_T) => a = b.
Definition stfl_t : Set := tfl_t stfl_T.
Definition stfl_T_context := tfl_T_context stfl_T.

Inductive stfl_term_type : stfl_T_context -> stfl_t -> stfl_T -> Prop :=
| StflTx : forall (c : stfl_T_context) (x : tfl_Var) (t : stfl_T), 
    c x t -> stfl_term_type c (TflTermVar stfl_T x) t
| StflTn : forall c n, 
    stfl_term_type c (TflTermNat stfl_T n) (TPrimitive Int)
| StflTb : forall c b, 
    stfl_term_type c (TflTermBool stfl_T b) (TPrimitive Bool)
| StflTapp : forall c t1 tt1 t2 tt2 ttx,
    stfl_term_type c t1 tt1 ->
    stfl_term_type c t2 tt2 ->
    tdom tt1 tt2 ->
    tcod tt1 ttx ->
    stfl_term_type c (TflTermApp stfl_T t1 t2) ttx
| StflTplus : forall c t1 t2,
    stfl_term_type c t1 (TPrimitive Int) ->
    stfl_term_type c t2 (TPrimitive Int) ->
    stfl_term_type c (TflTermPlus stfl_T t1 t2) (TPrimitive Int)
| StflTif : forall c t1 t2 tt2 t3 tt3 ttx,
    stfl_term_type c t1 (TPrimitive Bool) ->
    stfl_term_type c t2 tt2 ->
    stfl_term_type c t3 tt3 ->
    tequate tt2 tt3 ttx ->
    stfl_term_type c (TflTermIf stfl_T t1 t2 t3) ttx
| StflTlambda : forall (c : stfl_T_context) t tt1 tt2 (x : tfl_Var),
    stfl_term_type (tfl_T_context_set stfl_T x tt1 c) t tt2 ->
    stfl_term_type c (TflTermAbs stfl_T x tt1 t) (TFunc tt1 tt2)
| StflTassert : forall c t tt,
    stfl_term_type c t tt ->
    stfl_term_type c (TflTermAssert stfl_T t tt) tt
.

(**GTFL**)
Definition gtfl_T := gtype.
Definition gtfl_Tcons := class_gtype_cons.
Definition gtfl_t : Set := tfl_t gtfl_T.
Definition gtfl_T_context := tfl_T_context gtfl_T.

Inductive gtfl_term_type : gtfl_T_context -> gtfl_t -> gtfl_T -> Prop :=
| GtflTx : forall (c : gtfl_T_context) (x : tfl_Var) (t : gtfl_T), 
    c x t -> gtfl_term_type c (TflTermVar gtfl_T x) t
| GtflTn : forall c n, 
    gtfl_term_type c (TflTermNat gtfl_T n) (GPrimitive Int)
| GtflTb : forall c b, 
    gtfl_term_type c (TflTermBool gtfl_T b) (GPrimitive Bool)
| GtflTapp : forall c t1 tt1 t2 tt2 ttx,
    gtfl_term_type c t1 tt1 ->
    gtfl_term_type c t2 tt2 ->
    gdom tt1 tt2 ->
    gcod tt1 ttx ->
    gtfl_term_type c (TflTermApp gtfl_T t1 t2) ttx
| GtflTplus : forall c t1 tt1 t2 tt2,
    gtfl_term_type c t1 tt1 ->
    gtfl_term_type c t2 tt2 ->
    gtfl_Tcons tt1 (GPrimitive Int) ->
    gtfl_Tcons tt2 (GPrimitive Int) ->
    gtfl_term_type c (TflTermPlus gtfl_T t1 t2) (GPrimitive Int)
| GtflTif : forall c t1 tt1 t2 tt2 t3 tt3 ttx,
    gtfl_term_type c t1 tt1 ->
    gtfl_term_type c t2 tt2 ->
    gtfl_term_type c t3 tt3 ->
    gtfl_Tcons tt1 (GPrimitive Bool) ->
    gequate tt2 tt3 ttx ->
    gtfl_term_type c (TflTermIf gtfl_T t1 t2 t3) ttx
| GtflTlambda : forall (c : gtfl_T_context) t tt1 tt2 (x : tfl_Var),
    gtfl_term_type (tfl_T_context_set gtfl_T x tt1 c) t tt2 ->
    gtfl_term_type c (TflTermAbs gtfl_T x tt1 t) (GFunc tt1 tt2)
| GtflTassert : forall c t tt tt1,
    gtfl_term_type c t tt ->
    gtfl_Tcons tt tt1 ->
    gtfl_term_type c (TflTermAssert gtfl_T t tt1) tt1
.

(**naive subtyping relation (<:)**)
Inductive class_gsubt : gtype -> gtype -> Prop :=
| SubtUnknown : forall t, class_gsubt t GUnknown
| SubtRefl : forall t, class_gsubt t t
| SubtLift : forall t11 t12 t21 t22, 
  class_gsubt t11 t21 -> class_gsubt t12 t22 -> class_gsubt (GFunc t11 t12) (GFunc t21 t22)
.

(**powerset lifting (pseudo but sufficient so far!)**)
Inductive ptype : Set :=
| PTypeSingletonPrim : primitive_type -> ptype
| PTypeTotal : ptype
| PTypeMFunc : ptype -> ptype -> ptype.

(*subset*)
Inductive ptSpt : ptype -> ptype -> Prop :=
| PSPrefl : forall a, ptSpt a a
| PSPtot : forall a, ptSpt a PTypeTotal
| PSPlift : forall t11 t12 t21 t22,
  ptSpt t11 t12 -> ptSpt t21 t22 -> ptSpt (PTypeMFunc t11 t21) (PTypeMFunc t12 t22)
.

(*Definition 1 - Concretization (gamma)*)
Fixpoint g2pt (t : gtype) : ptype := match t with
| GPrimitive pt => PTypeSingletonPrim pt
| GFunc a b => PTypeMFunc (g2pt a) (g2pt b)
| GUnknown => PTypeTotal
end.

(*lift type*)
Fixpoint t2gt (t : type) : gtype := match t with
| TPrimitive pt => GPrimitive pt
| TFunc a b => GFunc (t2gt a) (t2gt b)
end.
Definition t2pt (t : type) : ptype := g2pt (t2gt t).
Fixpoint pt2t (t : ptype) : type := match t with (**draws sample**)
| PTypeSingletonPrim pt => TPrimitive pt
| PTypeMFunc a b => TFunc (pt2t a) (pt2t b)
| PTypeTotal => TPrimitive Bool
end.

(*Definition 2 - Type Precision (\sqsubseteq)*)
Definition gtSgt (a : gtype) (b : gtype) : Prop := ptSpt (g2pt a) (g2pt b).

(*Definition 3 - Predicate Lifting*)
Definition plift (pred : type -> type -> Prop) (a b : ptype) : Prop :=
exists a' b', pred a' b' /\ ptSpt (t2pt a') a /\ ptSpt (t2pt b') b.
Definition glift (pred : type -> type -> Prop) (a b : gtype) : Prop :=
plift pred (g2pt a) (g2pt b).

(*Definition 5 - alpha*)
Fixpoint pt2g (t : ptype) : gtype := match t with
| PTypeSingletonPrim t => GPrimitive t
| PTypeTotal => GUnknown
| PTypeMFunc a b => GFunc (pt2g a) (pt2g b)
end.

Ltac helpTac := 
  unfold gtSgt, g2pt;
  split;
  intros;
  try inversion H;
  try apply SubtRefl;
  try apply SubtUnknown;
  try apply PSPrefl;
  try apply PSPtot.

(*Proposition 1 - Type Precision == naive subtyping relation*)
Theorem typePrecision : forall t1 t2, gtSgt t1 t2 <-> class_gsubt t1 t2.
Proof.
  induction t1, t2;
  try destruct p;
  try destruct p0.

  helpTac.
  helpTac.
  helpTac.
  helpTac.
  helpTac.
  helpTac.
  helpTac.
  helpTac.
  helpTac.
  helpTac.
  
  (*hard case begin*)
  specialize (IHt1_1 t2_1).
  specialize (IHt1_2 t2_2).
  split.

  (*dir1*)
  intros.
  inversion H.

  assert (gtSgt t1_1 t2_1). unfold gtSgt. rewrite H2. apply PSPrefl.
  assert (gtSgt t1_2 t2_2). unfold gtSgt. rewrite H3. apply PSPrefl.
  apply SubtLift.
  apply IHt1_1. assumption.
  apply IHt1_2. assumption.

  apply SubtLift.
  apply IHt1_1. assumption.
  apply IHt1_2. assumption.

  (*dir2*)
  intros.
  inversion H.
  unfold gtSgt.
  apply PSPrefl.

  unfold gtSgt.
  simpl.
  apply PSPlift.
  apply IHt1_1. assumption.
  apply IHt1_2. assumption.
  (*hard case end*)

  helpTac.
  helpTac.
  helpTac.
  helpTac.
  helpTac.
Qed.

(*
Inductive class_gtype_cons : gtype -> gtype -> Prop :=
| GTypeConsRefl : forall t, class_gtype_cons t t
| GTypeConsUL : forall t, class_gtype_cons GUnknown t
| GTypeConsUR : forall t, class_gtype_cons t GUnknown
| GTypeConsAbs : forall t11 t12 t21 t22, 
  class_gtype_cons t11 t21 ->
  class_gtype_cons t12 t22 ->
  class_gtype_cons (GFunc t11 t12) (GFunc t21 t22).*)

Lemma funcLift1 : forall a a' b b',
t2pt (TFunc a b) = PTypeMFunc (g2pt a') (g2pt b')
->
(a' = t2gt a).
Proof.
  induction a, a', b, b'; 
  intros; 
  try (compute in *; congruence);
  specialize (IHa1 a'1 a2 a'2);
  specialize (IHa2 a'2 a1 a'1);
  unfold t2pt in H; simpl g2pt in H; inversion H; symmetry in H1, H2;
  try (destruct p, p0);
  try (compute in *; congruence);
  simpl;
  apply f_equal2;
  try (
    unfold t2gt;
    try (apply IHa1);
    try (apply IHa2);
    unfold t2pt;
    rewrite H1, H2;
    simpl g2pt;
    congruence).
Qed.
Lemma funcLift2 : forall a a' b b',
t2pt (TFunc a b) = PTypeMFunc (g2pt a') (g2pt b')
->
(b' = t2gt b).
Proof.
  induction b, b', a, a'; 
  intros; 
  try (compute in *; congruence);
  specialize (IHb1 b'1);
  specialize (IHb2 b'2);
  unfold t2pt in H; simpl g2pt in H; inversion H; symmetry in H3, H2;
  try (destruct p, p0);
  try (compute in *; congruence);
  simpl;
  apply f_equal2;
  try (
    try (apply IHb1);
    try (apply IHb2);
    unfold t2pt;
    simpl g2pt;
    apply f_equal2;
    congruence).
Qed.

Lemma funcLift : forall a a' b b',
t2pt (TFunc a b) = PTypeMFunc (g2pt a') (g2pt b')
<->
(a' = t2gt a /\ b' = t2gt b).
Proof.
  split.
    split.
    apply funcLift1 in H. assumption.
    apply funcLift2 in H. assumption.
  intros.
  inversion H.
  unfold t2pt.
  simpl t2gt.
  simpl g2pt.
  apply f_equal2; congruence.
Qed.

Lemma drawSample : forall p, ptSpt (t2pt (pt2t p)) p.
Proof.
  intros.
  induction p.
    compute. constructor.
    compute. constructor.

    simpl pt2t.
    unfold t2pt in *.
    simpl t2gt.
    simpl g2pt.
    apply PSPlift;
    congruence.
Qed.

Lemma eqCycle : forall x, x = pt2t (g2pt (t2gt x)).
Proof.
  intros.
  induction x.
    compute; congruence.
    simpl t2gt.
    simpl g2pt.
    simpl pt2t.
    symmetry in IHx1.
    symmetry in IHx2.
    rewrite IHx1.
    rewrite IHx2.
    congruence.
Qed.

Lemma eqGfunc : forall x t1 t2, t2pt x = PTypeMFunc t1 t2 -> x = TFunc (pt2t t1) (pt2t t2).
Proof.
  intros.
  induction x.
    compute in H. congruence.

    apply f_equal2; inversion H; apply eqCycle.
Qed.

Lemma ptSptLift : forall a b, ptSpt a b -> exists x, ptSpt (t2pt x) a /\ ptSpt (t2pt x) b.
Proof.
  induction a.
    intros.
    inversion H. 
      exists (TPrimitive p). split; compute; constructor.
      exists (TPrimitive p). split; compute; constructor.

    intros.
    inversion H; exists (TPrimitive Bool); split; compute; constructor.

    intros.
    inversion H. 
      exists (TFunc (pt2t a1) (pt2t a2)).
      split; unfold t2pt; simpl t2gt; simpl g2pt; apply PSPlift; apply drawSample.

      exists (TFunc (pt2t a1) (pt2t a2)).
      split; unfold t2pt; simpl t2gt; simpl g2pt; try (apply PSPlift; apply drawSample); try constructor.

      symmetry in H0. symmetry in H1. rewrite H0 in *. rewrite H1 in *. symmetry in H3. rewrite H3 in *.
      clear H H3 H0 H1.
      specialize (IHa1 t12 H2).
      specialize (IHa2 t22 H4).
      clear H2 H4 b.
      elim IHa1. intros.
      elim IHa2. intros.
      inversion H.
      inversion H0.
      clear IHa1 IHa2 H H0.
      exists (TFunc x x0).
      split; unfold t2pt; simpl t2gt; simpl g2pt; apply PSPlift; assumption.
Qed.

Lemma ptSptTrans : forall a b c, ptSpt a b /\ ptSpt b c -> ptSpt a c.
Proof.
  induction a, b, c; firstorder; inversion H; inversion H0; try congruence.
  constructor.
  clear H1 H2 H3 H5 H7 H8 H9 H11 t0 t1 t2 t3 t11 t12 t21 t22 H H0.
  specialize (IHa1 b1 c1).
  specialize (IHa2 b2 c2).
  intuition.
  constructor; assumption.
Qed.

Lemma ptSptGfunc1 : forall x t1_1 t1_2 t2_1 t2_2,
ptSpt (t2pt x) (g2pt (GFunc t1_1 t1_2)) ->
ptSpt (t2pt x) (g2pt (GFunc t2_1 t2_2)) ->
exists a' b' : type, stfl_Tcons a' b' ∧ ptSpt (t2pt a') (g2pt t1_1) ∧ ptSpt (t2pt b') (g2pt t2_1).
Proof.
  intros.
  inversion H; inversion H0; clear H H0.
    clear H1 H2 a a0.
    apply eqGfunc in H3.
    apply eqGfunc in H5.
    rewrite H3 in H5.
    inversion H5.
    exists (pt2t (g2pt t1_1)).
    exists (pt2t (g2pt t2_1)).
    split. congruence. split; apply drawSample.

    clear H1 a.
    apply ptSptLift in H6.
    apply ptSptLift in H7.
    elim H6. intros.
    elim H7. intros.
    inversion H.
    inversion H0.
    clear H H0 H6 H7.
    exists x0.
    exists x0.
    split. 
      constructor.
      split.
        rewrite H3 in H2.
        inversion H2.
        congruence.
        assumption.

    clear H6 a.
    apply ptSptLift in H4.
    apply ptSptLift in H5.
    elim H4. intros.
    elim H5. intros.
    inversion H.
    inversion H0.
    clear H H0 H4 H5.
    exists x0.
    exists x0.
    split. 
      constructor.
      split.
        assumption.
        rewrite H8 in H1.
        inversion H1.
        congruence.

    symmetry in H2. rewrite H2 in *.
    symmetry in H3. rewrite H3 in *.
    symmetry in H7. rewrite H7 in *.
    symmetry in H8. rewrite H8 in *.
    clear H2 H3 H7 H8 t2_1 t2_2 t1_1 t1_2.
    symmetry in H6.
    rewrite H6 in H1. 
    inversion H1.
    rewrite H0 in *.
    rewrite H2 in *.
    clear H6 H1 H0 H2.
    exists (pt2t t0).
    exists (pt2t t0).
    split. 
      constructor.

      assert (ptSpt (t2pt (pt2t t0)) t0).
      apply drawSample.
      split.
        specialize (ptSptTrans (t2pt (pt2t t0)) t0 t12). intuition.
        specialize (ptSptTrans (t2pt (pt2t t0)) t0 t1). intuition.
Qed.

Lemma ptSptGfunc2 : forall x t1_1 t1_2 t2_1 t2_2,
ptSpt (t2pt x) (g2pt (GFunc t1_1 t1_2)) ->
ptSpt (t2pt x) (g2pt (GFunc t2_1 t2_2)) ->
exists a' b' : type, stfl_Tcons a' b' ∧ ptSpt (t2pt a') (g2pt t1_2) ∧ ptSpt (t2pt b') (g2pt t2_2).
Proof.
  intros.
  inversion H; inversion H0; clear H H0.
    clear H1 H2 a a0.
    apply eqGfunc in H3.
    apply eqGfunc in H5.
    rewrite H3 in H5.
    inversion H5.
    exists (pt2t (g2pt t1_2)).
    exists (pt2t (g2pt t2_2)).
    split. congruence. split; apply drawSample.

    clear H1 a.
    apply ptSptLift in H6.
    apply ptSptLift in H7.
    elim H6. intros.
    elim H7. intros.
    inversion H.
    inversion H0.
    clear H H0 H6 H7.
    exists x1.
    exists x1.
    split. 
      constructor.
      split.
        rewrite H3 in H2.
        inversion H2.
        congruence.
        assumption.

    clear H6 a.
    apply ptSptLift in H4.
    apply ptSptLift in H5.
    elim H4. intros.
    elim H5. intros.
    inversion H.
    inversion H0.
    clear H H0 H4 H5.
    exists x1.
    exists x1.
    split. 
      constructor.
      split.
        assumption.
        rewrite H8 in H1.
        inversion H1.
        congruence.

    symmetry in H2. rewrite H2 in *.
    symmetry in H3. rewrite H3 in *.
    symmetry in H7. rewrite H7 in *.
    symmetry in H8. rewrite H8 in *.
    clear H2 H3 H7 H8 t2_1 t2_2 t1_1 t1_2.
    symmetry in H6.
    rewrite H6 in H1. 
    inversion H1.
    rewrite H0 in *.
    rewrite H2 in *.
    clear H6 H1 H0 H2.
    exists (pt2t t2).
    exists (pt2t t2).
    split.
      constructor.

      assert (ptSpt (t2pt (pt2t t2)) t2).
      apply drawSample.
      split.
        specialize (ptSptTrans (t2pt (pt2t t2)) t2 t22). intuition.
        specialize (ptSptTrans (t2pt (pt2t t2)) t2 t3). intuition.
Qed.

(*Proposition 2 - consistency as lifted equality*)
Theorem consistencyAsLiftedEq : forall t1 t2, glift (stfl_Tcons) t1 t2 <-> class_gtype_cons t1 t2.
Proof.
  unfold glift, plift;
  induction t1, t2;
  firstorder.

  destruct p, p0; 
  try apply GTypeConsRefl;
  unfold g2pt in H0, H1;
  inversion H0; inversion H1;
  congruence.

  inversion H.
  exists (TPrimitive p0).
  exists (TPrimitive p0).
  split.
  congruence.
  split; apply PSPrefl.

  unfold g2pt in H0, H1;
  inversion H0; inversion H1;
  congruence.

  inversion H.

  apply GTypeConsUR.

  inversion H.
  exists (TPrimitive p).
  exists (TPrimitive p).
  split.
  congruence.
  split; 
  try constructor.

  unfold g2pt in H0, H1;
  inversion H0; inversion H1;
  congruence.

  inversion H.

  constructor; try (apply IHt1_1); try (apply IHt1_2); clear IHt1_1 IHt1_2.
    inversion H.
    rewrite H2 in *; clear H2 x H.
    specialize (ptSptGfunc1 x0 t1_1 t1_2 t2_1 t2_2).
    auto.
    inversion H.
    rewrite H2 in *; clear H2 x H.
    specialize (ptSptGfunc2 x0 t1_1 t1_2 t2_1 t2_2).
    auto.

  inversion H. 
    rewrite H2 in *. rewrite H3 in *. clear H H2 H3 H0. clear t t1_1 t1_2.
    specialize (IHt1_1 t2_1).
    specialize (IHt1_2 t2_2).
    assert (class_gtype_cons t2_1 t2_1). constructor.
    assert (class_gtype_cons t2_2 t2_2). constructor.
    apply IHt1_1 in H.
    apply IHt1_2 in H0.
    elim H; intros.
    elim H1; intros.
    elim H0; intros.
    elim H3; intros.
    inversion H2.
    inversion H6.
    inversion H4.
    inversion H10.
    clear H H0 H1 H2 H3 H4 H6 H10 IHt1_1 IHt1_2.
    exists (TFunc x x1).
    exists (TFunc x0 x2).
    unfold t2pt.
    simpl t2gt.
    simpl g2pt.
    split.
      congruence.
      split; constructor; unfold t2pt in *; congruence.

    clear H0 H1 H2 H4 t11 t12 t21 t22.
    apply IHt1_1 in H3.
    apply IHt1_2 in H5.
    clear IHt1_1 IHt1_2 H.
    elim H3. intros. elim H. intros.
    elim H5. intros. elim H1. intros.
    exists (TFunc x x1).
    exists (TFunc x0 x2).
    unfold t2pt.
    simpl t2gt.
    simpl g2pt.
    inversion H0.
    inversion H2.
    inversion H6.
    inversion H8.
    clear H0 H2 H6 H8.
    split.
      congruence.
      split; constructor; unfold t2pt in *; congruence.

  constructor.

  inversion H.
  exists (pt2t (g2pt (GFunc t1_1 t1_2))).
  exists (pt2t (g2pt (GFunc t1_1 t1_2))).
  split.
  congruence.
  split.
  apply drawSample.
  constructor.

  constructor.

  inversion H.
  exists (TPrimitive p).
  exists (TPrimitive p).
  split.
  congruence.
  split; 
  try constructor.

  constructor.

  inversion H.
  exists (pt2t (g2pt (GFunc t2_1 t2_2))).
  exists (pt2t (g2pt (GFunc t2_1 t2_2))).
  split.
  congruence.
  split.
  constructor.
  apply drawSample.

  constructor.

  exists (TPrimitive Bool).
  exists (TPrimitive Bool).
  split.
  congruence.
  split; 
  try constructor.
Qed.


(*Proposition 3 - alpha sound*)
Theorem soundnessAlpha : forall pt, ptSpt pt (g2pt (pt2g pt)).
Proof.
  apply ptype_ind.
  intros.
  apply PSPrefl.
  apply PSPrefl.
  intros.
  simpl.
  apply PSPlift; congruence.
Qed.

(*Proposition 4 - alpha optimal*)
Theorem optimalAlpha : forall pt gt, ptSpt pt (g2pt gt) -> gtSgt (pt2g pt) gt.
Proof.
  unfold gtSgt.
  induction pt; firstorder.
  compute. fold g2pt. fold pt2g.
  induction gt; simpl pt2g; inversion H; firstorder.
    compute. fold g2pt. fold pt2g.
    specialize (IHpt1 gt1).
    specialize (IHpt2 gt2).
    symmetry in H2. rewrite H2 in *.
    symmetry in H3. rewrite H3 in *.
    clear H2 H3 H H0 a IHgt1 IHgt2.
    constructor; try (apply IHpt1); try (apply IHpt2); constructor.

    compute. fold g2pt. fold pt2g.
    specialize (IHpt1 gt1).
    specialize (IHpt2 gt2).
    symmetry in H2. rewrite H2 in *.
    symmetry in H4. rewrite H4 in *.
    clear H2 H4 H IHgt1 IHgt2 H0 H1 t11 t21.
    constructor; firstorder.

    constructor.
Qed.

