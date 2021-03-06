Require Import Coq.Unicode.Utf8 Arith Bool Ring Setoid String.
Require Import Coq.Lists.ListSet.
Require Import Coq.Sets.Powerset.
Require Import Coq.Logic.Classical_Pred_Type.
Require Import Coq.Classes.EquivDec.
Require Import Coq.Classes.SetoidClass.
Require Import Coq.Logic.Decidable.
Require Import Coq.Structures.Equalities.
Require Import Coq.Logic.Eqdep_dec.
Require Import Coq.Logic.ClassicalFacts.
Require Import Coq.Logic.FunctionalExtensionality.
Require Import Coq.Logic.ProofIrrelevance.
Require Import Coq.Lists.List.
Import ListNotations.

(* helpers *)
Definition dec2decb {A : Type} (dec : ∀ a1 a2 : A, {a1 = a2} + {a1 ≠ a2}) : (A -> A -> bool) :=
  fun a b => if dec a b then true else false.
Definition except {A : Type} (A_decb : A -> A -> bool) (a b : list A) : list A :=
  filter (fun x => negb (existsb (A_decb x) b)) a.

Definition option_bind {A B : Type} (f : A -> option B) (x : option A) : option B :=
match x with
| Some x' => f x'
| None => None
end.

Definition nat_decb := dec2decb eq_nat_dec.
Hint Resolve eq_nat_dec.
Hint Resolve list_eq_dec eq_nat_dec.

Program Instance string_EqDec : EqDec string eq := string_dec.
Definition string_decb := dec2decb string_dec.
Hint Resolve string_dec.
Hint Resolve list_eq_dec string_dec.

(* Figure 1: Syntax of a Java-like language for core language *)
Definition C := string.
Definition f := string.
Definition m := string.
Definition o := nat.
Inductive x :=
| xUserDef : string -> x
| xthis : x
| xresult : x.
Inductive T :=
| TPrimitiveInt : T
| TClass : C -> T.
Inductive v :=
| vn : nat -> v
| vnull : v
| vo : o -> v.
Inductive e :=
| ev : v -> e
| ex : x -> e
| edot : e -> f -> e.
Inductive phi' :=
| phiTrue : phi'
| phiEq : e -> e -> phi'
| phiNeq : e -> e -> phi'
| phiAcc : e -> f -> phi'.
Definition phi := list phi'.
Inductive s :=
| sMemberSet : x -> f -> x -> s
| sAssign : x -> e -> s
| sAlloc : x -> C -> s
| sCall : x -> x -> m -> list x -> s
| sReturn : x -> s
| sAssert : phi' -> s
| sRelease : phi' -> s.
Inductive contract :=
| Contract : phi -> phi -> contract.
Inductive method :=
| Method : T -> m -> list (T * x) -> contract -> list s -> method.
Inductive field :=
| Field : T -> f -> field.
Inductive cls :=
| Cls : C -> list field -> list method -> cls.
Inductive program :=
| Program : (list cls) -> (list s) -> program.

Definition Gamma := x -> option T.
Definition H := o -> option (C * (f -> option v)).
Definition rho := x -> option v.
Inductive name :=
| namex : x -> name
| nameo : o -> name.
Definition A := list (name * f).
Definition S := list (rho * A * list s).

(* equality *)

Definition C_decb := string_decb.
Definition f_decb := string_decb.
Definition m_decb := string_decb.

Definition o_dec : ∀ n m : o, {n = m} + {n ≠ m}. decide equality. Defined.
Program Instance o_EqDec : EqDec o eq := o_dec.
Definition o_decb := dec2decb o_dec.
Hint Resolve o_dec.
Hint Resolve list_eq_dec o_dec.

Definition x_dec : ∀ n m : x, {n = m} + {n ≠ m}. decide equality. Defined.
Program Instance x_EqDec : EqDec x eq := x_dec.
Definition x_decb := dec2decb x_dec.
Hint Resolve x_dec.
Hint Resolve list_eq_dec x_dec.

Definition T_dec : ∀ n m : T, {n = m} + {n ≠ m}. decide equality. Defined.
Program Instance T_EqDec : EqDec T eq := T_dec.
Definition T_decb := dec2decb T_dec.
Hint Resolve T_dec.
Hint Resolve list_eq_dec T_dec.

Definition v_dec : ∀ n m : v, {n = m} + {n ≠ m}. decide equality. Defined.
Program Instance v_EqDec : EqDec v eq := v_dec.
Definition v_decb := dec2decb v_dec.
Hint Resolve v_dec.
Hint Resolve list_eq_dec v_dec.

Definition e_dec : ∀ n m : e, {n = m} + {n ≠ m}. decide equality. Defined.
Program Instance e_EqDec : EqDec e eq := e_dec.
Definition e_decb := dec2decb e_dec.
Hint Resolve e_dec.
Hint Resolve list_eq_dec e_dec.

Definition phi'_dec : ∀ n m : phi', {n = m} + {n ≠ m}. decide equality. Defined.
Program Instance phi'_EqDec : EqDec phi' eq := phi'_dec.
Definition phi'_decb := dec2decb phi'_dec.
Hint Resolve phi'_dec.
Hint Resolve list_eq_dec phi'_dec.

Definition phi_dec : ∀ n m : phi, {n = m} + {n ≠ m}. decide equality. Defined.
Program Instance phi_EqDec : EqDec phi eq := phi_dec.
Definition phi_decb := dec2decb phi_dec.
Hint Resolve phi_dec.
Hint Resolve list_eq_dec phi_dec.

Definition s_dec : ∀ n m : s, {n = m} + {n ≠ m}. decide equality. Defined.
Program Instance s_EqDec : EqDec s eq := s_dec.
Definition s_decb := dec2decb s_dec.
Hint Resolve s_dec.
Hint Resolve list_eq_dec s_dec.

Definition contract_dec : ∀ n m : contract, {n = m} + {n ≠ m}. decide equality. Defined.
Program Instance contract_EqDec : EqDec contract eq := contract_dec.
Definition contract_decb := dec2decb contract_dec.
Hint Resolve contract_dec.
Hint Resolve list_eq_dec contract_dec.

Definition method_dec : ∀ n m : method, {n = m} + {n ≠ m}. decide equality. apply (list_eq_dec (prod_eqdec T_dec x_dec)). Defined.
Program Instance method_EqDec : EqDec method eq := method_dec.
Definition method_decb := dec2decb method_dec.
Hint Resolve method_dec.
Hint Resolve list_eq_dec method_dec.

Definition field_dec : ∀ n m : field, {n = m} + {n ≠ m}. decide equality. Defined.
Program Instance field_EqDec : EqDec field eq := field_dec.
Definition field_decb := dec2decb field_dec.
Hint Resolve field_dec.
Hint Resolve list_eq_dec field_dec.

Definition cls_dec : ∀ n m : cls, {n = m} + {n ≠ m}. decide equality. Defined.
Program Instance cls_EqDec : EqDec cls eq := cls_dec.
Definition cls_decb := dec2decb cls_dec.
Hint Resolve cls_dec.
Hint Resolve list_eq_dec cls_dec.

Definition program_dec : ∀ n m : program, {n = m} + {n ≠ m}. decide equality. Defined.
Program Instance program_EqDec : EqDec program eq := program_dec.
Definition program_decb := dec2decb program_dec.
Hint Resolve program_dec.
Hint Resolve list_eq_dec program_dec.

Definition name_dec : ∀ n m : name, {n = m} + {n ≠ m}. decide equality. Defined.
Program Instance name_EqDec : EqDec name eq := name_dec.
Definition name_decb := dec2decb name_dec.
Hint Resolve name_dec.
Hint Resolve list_eq_dec name_dec.

Definition A_dec : ∀ n m : A, {n = m} + {n ≠ m}. decide equality. apply (prod_eqdec name_dec string_dec). Defined.
Program Instance A_EqDec : EqDec A eq := A_dec.
Definition A_decb := dec2decb A_dec.
Hint Resolve A_dec.
Hint Resolve list_eq_dec A_dec.

Definition A'_decb (a b : name * f) : bool := name_decb (fst a) (fst b) && string_decb (snd a) (snd b).
Definition Aexcept := except A'_decb.


Module Semantics.

Parameter p : program.

(* accessors *)
Definition classes : list cls := match p with Program clss _ => clss end.
Definition class (C' : C) : option cls :=
    find (fun class => match class with Cls C'' _ _ => C_decb C'' C' end) classes.
Definition fields (C' : C) : option (list (T * f)) :=
  match class C' with
  | None => None
  | Some class => 
    match class with
    | Cls _ fs _ => Some (map (fun f => match f with Field T' f' => (T', f') end) fs)
    end
  end.
Definition fieldType (C' : C) (f' : f) : option T :=
  match class C' with
  | None => None
  | Some class => 
    match class with
    | Cls C'' fs _ => option_map
        (fun f => match f with Field T' _ => T' end)
        (find (fun f => match f with Field _ f'' => f_decb f'' f' end) fs)
    end
  end.
Definition allMethods : list method := flat_map (fun cl => match cl with Cls _ _ x => x end) classes.
Definition mmethod (C' : C) (m' : m) : option method :=
  match class C' with
  | None => None
  | Some class => 
    match class with
    | Cls C'' _ ms =>
      find (fun me => match me with Method _ m'' _ _ _ => m_decb m'' m' end) ms
    end
  end.
Definition mcontract (C' : C) (m' : m) : option contract :=
  option_map
    (fun me => match me with Method _ _ _ contr _ => contr end)
    (mmethod C' m').
Definition mpre (C' : C) (m' : m) : option phi :=
  option_map
    (fun contr => match contr with Contract res _ => res end)
    (mcontract C' m').
Definition mpost (C' : C) (m' : m) : option phi :=
  option_map
    (fun contr => match contr with Contract _ res => res end)
    (mcontract C' m').
Definition mbody (C' : C) (m' : m) : option (list s) :=
  option_map
    (fun me => match me with Method _ _ _ _ instrs => instrs end)
    (mmethod C' m').
Definition mparams (C' : C) (m' : m) : option (list x) :=
  option_map
    (fun me => match me with Method _ _ params _ _ => map snd params end)
    (mmethod C' m').

Definition getMain : list s := match p with Program _ main => main end.

(* substitution *)
Fixpoint eSubst (x' : x) (e' : e) (ee : e) : e :=
match ee with
| ex x'' => if x_decb x'' x' then e' else ee
| edot e'' f' => edot (eSubst x' e' e'') f'
| _ => ee
end.

Definition eSubsts (r : list (x * e)) (ee : e) : e :=
  fold_left (fun a b => eSubst (fst b) (snd b) a) r ee.

Definition phi'Subst (x' : x) (e' : e) (p : phi') : phi' :=
match p with
| phiEq  e1 e2 => phiEq  (eSubst x' e' e1) (eSubst x' e' e2)
| phiNeq e1 e2 => phiNeq (eSubst x' e' e1) (eSubst x' e' e2)
| phiAcc e'' f'' => phiAcc (eSubst x' e' e'') f''
| _ => p
end.

Definition phiSubst (x' : x) (e' : e) (p : phi) : phi :=
  map (phi'Subst x' e') p.

Definition phiSubsts (r : list (x * e)) (p : phi) : phi :=
  fold_left (fun a b => phiSubst (fst b) (snd b) a) r p.

Definition HSubst (o' : o) (f' : f) (v' : v) (h : H) : H :=
  fun o'' =>
    if o_decb o'' o'
      then 
      (
        match h o'' with
        | Some (C', ff') => Some (C', fun f'' => if f_decb f'' f' then Some v' else ff' f'')
        | None => None
        end
      )
      else h o''
.

Definition HSubsts (o' : o) (r : list (f * v)) (h : H) : H :=
  fold_left (fun a b => HSubst o' (fst b) (snd b) a) r h.

Definition rhoSubst (x' : x) (v' : v) (r : rho) : rho :=
  fun x'' => if x_decb x'' x' then Some v' else r x''.

Definition GammaSubst (x' : x) (T' : T) (g : Gamma) : Gamma :=
  fun x'' => if x_decb x'' x' then Some T' else g x''.

(* Figure 2: Static typing rules for expressions of the core language *)
Inductive sfrme : A -> e -> Prop :=
| WFVar : forall a (x' : x),
    sfrme a (ex x')
| WFValue : forall a (v' : v),
    sfrme a (ev v')
| WFField : forall a (x' : x) (f' : f),
    In (namex x', f') a ->
    sfrme a (edot (ex x') f')
.


(* Figure 4: Deﬁnition of a static version of footprint *)
Fixpoint staticFootprint (p : phi) : A := flat_map (fun p =>
  match p with
  | phiAcc (ex x') f' => [(namex x', f')]
  | _ => []
  end) p.

(* Figure 3: Static rules for syntactically self-framed formulas *)
Inductive sfrmphi' : A -> phi' -> Prop :=
| WFTrue : forall a, sfrmphi' a phiTrue
| WFEqual : forall a (e1 e2 : e), sfrme a e1 -> sfrme a e2 -> sfrmphi' a (phiEq e1 e2)
| WFNEqual : forall a (e1 e2 : e), sfrme a e1 -> sfrme a e2 -> sfrmphi' a (phiNeq e1 e2)
| WFAcc : forall a e' f, sfrme a e' -> sfrmphi' a (phiAcc e' f)
.
Definition sfrmphi (a : A) (p : phi) : Prop :=
  forall p', In p' p -> sfrmphi' a p'.

(* static type derivation *)
Definition getType' (v' : v) : option T :=
  match v' with
  | vnull => None
  | vn _ => Some TPrimitiveInt
  | vo _ => None
  end.
Fixpoint getType (G : Gamma) (e' : e) : option T :=
  match e' with
  | ev v => getType' v
  | ex x => G x
  | edot e' f' => 
    option_bind
      (fun t => 
        match t with
        | TPrimitiveInt => None
        | TClass C' => fieldType C' f'
        end)
      (getType G e')
  end.

(* Figure 6: Evaluation of expressions for core language *)
Fixpoint evale (h : H) (r : rho) (e' : e) : option v :=
  match e' with
  | ex x' => r x'
  | edot e'' f' =>
    match evale h r e'' with
    | Some (vo o') =>
      match h o' with
      | Some (_, ho') => ho' f'
      | _ => None
      end
    | _ => None
    end
  | ev v => Some v
  end.
(* NOTE: there are tons of calls like "evale h r (ex x)", wouldn't it be clearer to just say "r x"? or is that less consistent? *)

(* Figure 7: Evaluation of formulas for core language *)
Inductive evalphi' : H -> rho -> A -> phi' -> Prop :=
| EATrue : forall h r a,
    evalphi' h r a phiTrue
| EAEqual : forall h r a e1 e2 v1 v2,
    evale h r e1 = Some v1 ->
    evale h r e2 = Some v2 ->
    v1 = v2 ->
    evalphi' h r a (phiEq e1 e2)
| EANEqual : forall h r a e1 e2 v1 v2,
    evale h r e1 = Some v1 ->
    evale h r e2 = Some v2 ->
    v1 <> v2 ->
    evalphi' h r a (phiNeq e1 e2)
| EAAcc : forall h r a e' o' f',
    evale h r e' = Some (vo o') ->
    In (nameo o', f') a ->
    evalphi' h r a (phiAcc e' f')
.
Definition evalphi : H -> rho -> A -> phi -> Prop :=
  fun h r a p => forall p', In p' p -> evalphi' h r a p'.

(* implication on phi *)
Definition phiImplies (p1 p2 : phi) : Prop :=
  forall h r a, evalphi h r a p1 -> evalphi h r a p2.

(* well-typedness *)
Definition wellTypedX (G : Gamma) (x' : x) : Prop :=
  exists T', G x' = Some T'.
Definition wellTypedE (G : Gamma) (e' : e) : Prop :=
  exists T', getType G e' = Some T'.
Definition wellTypedPhi' (G : Gamma) (p : phi') : Prop :=
  match p with
  | phiTrue => True
  | phiEq e1 e2 => wellTypedE G e1 /\ wellTypedE G e2 /\ getType G e1 = getType G e2
  | phiNeq e1 e2 => wellTypedE G e1 /\ wellTypedE G e2 /\ getType G e1 = getType G e2
  | phiAcc e' f => wellTypedE G (edot e' f)
  end.
Definition wellTypedPhi (G : Gamma) (p : phi) : Prop :=
  forall p', In p' p -> wellTypedPhi' G p'.
Definition wellTyped (G : Gamma) (s' : s) : Prop :=
  match s' with
  | sMemberSet x' f' y' => let e1 := (edot (ex x') f') in
                           let e2 := ex y' in 
                            wellTypedE G e1 /\ wellTypedE G e2 /\ getType G e1 = getType G e2
  | sAssign x' e' => True
  | sAlloc x' C' => G x' = Some (TClass C')
  | sCall x' y' f' z' => exists C' T' ps' contr s',
                G y' = Some (TClass C') /\
                mmethod C' f' = Some (Method T' f' ps' contr s') /\
                G x' = Some T' /\
                map Some (map fst ps') = map G z' (* /\ anything with contr and s' ???*)
  | sReturn x' => wellTypedX G x'
  | sAssert p => wellTypedPhi' G p
  | sRelease p => wellTypedPhi' G p
  end.

(* Figure 5: Hoare-based proof rules for core language *)
Inductive hoareSingle : Gamma -> phi -> s -> phi -> Prop :=
| HNewObj : forall (G : Gamma) p x' (C' : C) fs,
    G x' = Some (TClass C') ->
    fields C' = Some fs ->
    hoareSingle
      G
      p
      (sAlloc x' C')
      (fold_left 
        (fun a b => phiAcc (ex x') (snd b) :: a) 
        fs 
        (phiNeq (ex x') (ev vnull) :: p))
| HFieldAssign : forall G (p : phi) (x' y' : x) (f' : f) e',
    In (phiAcc (ex x') f') p ->
    In (phiNeq (ex x') (ev vnull)) p ->
    In (phiEq (ex y') e') p ->
    hoareSingle G p (sMemberSet x' f' y') (p ++ [phiEq (edot (ex x') f') (ex y')])
| HVarAssign : forall G p' p (x' : x) (e' e2' : e),
    p' = phiSubst x' e' p ->
    In (phiEq e' e2') p' ->
    sfrmphi [] p' ->
    sfrme (staticFootprint p') e' ->
    hoareSingle G p' (sAssign x' e') p
| HReturn : forall G p (x' : x) e' p',
    p' = phiSubst x' e' p ->
    In (phiEq (ex x') e') p' ->
    hoareSingle G p' (sReturn x') p
| HApp : forall G p pp pr pq (x' y' : x) (C' : C) (m' : m) (Xz' : list (x * x)) (zs' := map snd Xz') (Xze' := map (fun pr => (fst pr, ex (snd pr))) Xz'),
    G y' = Some (TClass C') ->
    In (phiNeq (ex y') (ev vnull)) p ->
    phiImplies p (pp ++ pr) ->
    Some pp = option_map (phiSubsts ((xthis, ex y') :: Xze')) (mpre C' m') ->
    Some pq = option_map (phiSubsts (((xthis, ex y') :: Xze') ++ [(xresult, ex x')])) (mpost C' m') ->
    hoareSingle G p (sCall x' y' m' zs') (pq ++ pr)
| HAssert : forall G p1 p2,
    In p2 p1 ->
    hoareSingle G p1 (sAssert p2) p1
| HRelease : forall G p1 p2 pr,
    phiImplies p1 (p2 :: pr) ->
    sfrmphi [] pr ->
    hoareSingle G p1 (sRelease p2) pr
.

Inductive hoare : phi -> list s -> phi -> Prop :=
| HSec : forall G (p q1 q2 r : phi) (s1 : s) (s2 : list s), (* w.l.o.g.??? *)
    hoareSingle G p s1 q1 ->
    phiImplies q1 q2 ->
    hoare q2 s2 r ->
    hoare p (s1 :: s2) r
| HEMPTY : forall p, hoare p [] p
.


(* Figure 8: Definition of footprint meta-function *)
Fixpoint footprint' (h : H) (r : rho) (p : phi') : A :=
  match p with
  | phiAcc e' f' => 
      match evale h r e' with
      | Some (vo o') => [(nameo o', f')]
      | _ => [] (*???*)
      end
  | _ => []
  end.
Fixpoint footprint (h : H) (r : rho) (p : phi) : A :=
  flat_map (footprint' h r) p.

(* Figure 9: Dynamic semantics for core language *)
Definition execState : Set := H * S.
Inductive dynSem : execState -> execState -> Prop :=
| ESFieldAssign : forall h h' (S' : S) (s' : list s) (a : A) r (x' y' : x) (yv' : v) (o' : o) (f' : f),
    evale h r (ex x') = Some (vo o') ->
    evale h r (ex y') = Some yv' ->
    In (nameo o', f') a ->
    h' = HSubst o' f' yv' h ->
    dynSem (h, (r, a, sMemberSet x' f' y' :: s') :: S') (h', (r, a, s') :: S')
(*| ESDefVar : forall h (S' : S) (s' : list s) (a : A) r r' (x' : x) (T' : T),
    r' = rhoSubst x' vnull r ->
    dynSem (h, (r, a, sDeclare T' x' :: s') :: S') (h, (r', a, s') :: S')*)
| ESVarAssign : forall h (S' : S) (s' : list s) (a : A) r r' (x' : x) (e' : e) (v' : v),
    evale h r e' = Some v' ->
    r' = rhoSubst x' v' r ->
    dynSem (h, (r, a, sAssign x' e' :: s') :: S') (h, (r', a, s') :: S')
| ESNewObj : forall h h' (S' : S) (s' : list s) (a a' : A) r r' (x' : x) (o' : o) (C' : C) Cf',
    h o' = None ->
    fields C' = Some Cf' ->
    r' = rhoSubst x' (vo o') r ->
    a' = a ++ map (fun cf' => (nameo o', snd cf')) Cf' ->
    h' = HSubsts o' (map (fun cf' => (snd cf', vnull)) Cf') h ->
    dynSem (h, (r, a, sAlloc x' C' :: s') :: S') (h', (r', a', s') :: S')
| ESReturn : forall h (S' : S) (s' : list s) (a : A) r r' (x' : x) (vx : v),
    evale h r (ex x') = Some vx ->
    r' = rhoSubst xresult vx r ->
    dynSem (h, (r, a, sReturn x' :: s') :: S') (h, (r', a, s') :: S')
| ESApp : forall pre h (S' : S) (s' rs : list s) (a a' : A) (r r' : rho) (x' y' : x) (zs' : list x) (wvs' : list (x * v)) (ws' := map fst wvs') (vs' := map snd wvs') (m' : m) (o' : o) (C' : C) fvf,
    evale h r (ex y') = Some (vo o') ->
    map (fun z' => evale h r (ex z')) zs' = map Some vs' ->
    h o' = Some (C', fvf) ->
    mbody C' m' = Some rs ->
    mparams C' m' = Some ws' ->
    mpre C' m' = Some pre ->
    r' = (fun rx => if x_decb rx xthis 
      then Some (vo o')
      else (match find (fun wv => x_decb rx (fst wv)) wvs' with
            | Some x => Some (snd x)
            | None => None
            end)) ->
    evalphi h r' a pre ->
    a' = footprint h r' pre ->
    dynSem (h, (r, a, sCall x' y' m' zs' :: s') :: S') (h, (r', a', rs) :: (r, Aexcept a a', sCall x' y' m' zs' :: s') :: S')
| ESAppFinish : forall post h (S' : S) (s' : list s) (a a' a'' : A) r r' (x' : x) zs' (m' : m) y' (C' : C) vresult,
    mpost C' m' = Some post ->
    evalphi h r' a' post ->
    a'' = footprint h r' post ->
    evale h r' (ex xresult) = Some vresult ->
    dynSem (h, (r', a', []) :: (r, a, sCall x' y' m' zs' :: s') :: S') (h, (rhoSubst x' vresult r, a ++ a'', s') :: S')
| ESAssert : forall h r a p s' S',
    evalphi' h r a p ->
    dynSem (h, (r, a, sAssert p :: s') :: S') (h, (r, a, s') :: S')
| ESRelease : forall h r a a' p s' S',
    evalphi' h r a p ->
    a' = Aexcept a (footprint' h r p) ->
    dynSem (h, (r, a, sRelease p :: s') :: S') (h, (r, a', s') :: S')
.

(* helper definitions *)
Definition isStuck (s : execState) : Prop :=
  ~ exists s', dynSem s s'.
Definition isFinished (s : execState) : Prop :=
  exists r a, snd s = [(r,a,[])].
Definition isFail (s : execState) : Prop :=
  isStuck s /\ ~ isFinished s.

Inductive dynSemStar : execState -> execState -> Prop :=
| ESSNone : forall a, dynSemStar a a
| ESSStep : forall a b c, dynSem a b -> dynSemStar b c -> dynSemStar a c
.
(*Definition dynSemFull (initial final : execState) : Prop := dynSemStar initial final /\ isFinished final.
*)
Definition newHeap : H := fun _ => None.
Definition newRho : rho := fun _ => None.
Definition newAccess : A := [].

(* ASSUMPTIONS *)
Definition mWellDefined (m : method) := 
  match m with Method T' m' p c s =>
    match c with Contract pre post =>
      hoare pre s post /\
      sfrmphi (staticFootprint pre) pre /\
      sfrmphi (staticFootprint post) post
    end
  end.
Axiom pWellDefined : forall m, In m allMethods -> mWellDefined m.

(* PROOF SECTION *)
Notation "'φ'" := phi.
Notation "'ρ'" := rho.
Notation "'Γ'" := Gamma.

(* determinism? *)

Lemma hoareImplies : forall q1 q2 q3 q4 s', phiImplies q1 q2 -> hoare q2 s' q3 -> phiImplies q3 q4 -> hoare q1 s' q4.
Admitted.

Lemma phiImpliesRefl : forall x, phiImplies x x.
Proof.
  unfold phiImplies.
  auto.
Qed.
Hint Resolve phiImpliesRefl.

Lemma AexceptReverse : forall a1 a2, Aexcept (a1 ++ a2) a2 = a1.
Admitted.

Lemma evalPhiImplies : forall H' r A' q1 q2,
  phiImplies q1 q2 -> evalphi H' r A' q1 -> evalphi H' r A' q2.
Proof.
  intros.
  unfold phiImplies in H0.
  specialize (H0 H' r A').
  intuition.
Qed.

Lemma InAexcept : forall x a a', In x (Aexcept a a') -> In x a.
Proof.
  unfold Aexcept.
  unfold except.
  induction a; intros.
  - compute in H0.
    inversion H0.
  - simpl.
    simpl filter in H0.
    destruct (existsb (A'_decb a) a'); simpl in H0.
    * apply IHa in H0.
      auto.
    * inversion H0; auto.
      apply IHa in H1.
      auto.
Qed.

Lemma HnotTotal : forall (H' : H), exists x, H' x = None.
Admitted.

Lemma mapSplitFst : forall {A B : Type} (x : list (A * B)), map fst x = fst (split x).
Admitted.
Lemma mapSplitSnd : forall {A B : Type} (x : list (A * B)), map snd x = snd (split x).
Admitted.

(*
Lemma phiTrueSubst : forall a b p, phiTrue = phiSubst a b p -> p = phiTrue.
Proof.
  intros.
  destruct p; auto;
  unfold phiSubst in H0; inversion H0.
Qed.
Lemma phiTrueSubsts : forall a p, phiTrue = phiSubsts a p -> p = phiTrue.
Proof.
  induction a; intros.
  - simpl in H0.
    auto.
  - simpl in H0.
    apply IHa in H0.
    symmetry in H0.
    apply phiTrueSubst in H0.
    assumption.
Qed.
Lemma phiEqSubsts : forall a p e1 e2, phiEq e1 e2 = phiSubsts a p -> exists e1' e2', p = phiEq e1' e2' /\ e1 = eSubsts a e1' /\ e2 = eSubsts a e2'.
Proof.
  induction a; intros.
  - repeat eexists.
    simpl in H0.
    subst.
    auto.
  - simpl in H0.
    apply IHa in H0.
    inversion H0; clear H0.
    inversion H1; clear H1.
    intuition.
    subst.
    destruct p; simpl in H1; inversion H1.
    repeat eexists.
    * admit.
    * admit.
Admitted.

Lemma eSubstsVal : forall x v, eSubsts x (ev v) = (ev v).
Proof.
  induction x0; intros.
  - simpl; tauto.
  - specialize (IHx0 v0).
    assert (eSubsts (a :: x0) (ev v0) = eSubsts x0 (ev v0)).
    * admit.
    * rewrite IHx0 in H0.
      assumption.
Admitted.

Lemma phiImpliesConj : forall a b c, phiImplies a (phiConj b c) -> phiImplies a b.
Admitted.*)

Ltac tmp := repeat eexists; econstructor; econstructor; eauto.
Ltac unfWT := 
  unfold wellTyped in *;
  unfold wellTypedPhi in *;
  unfold wellTypedE in *;
  simpl getType in *.

Lemma evaleTClass : forall G e' C' h r, getType G e' = Some (TClass C') -> (let res := evale h r e' in res = Some vnull \/ exists o', res = Some (vo o')).
Admitted. (* TODO: entangle *)

Definition consistent (H' : H) (r : rho) := forall x' o' res, r x' = Some (vo o') -> H' o' = Some res.

Lemma lengthId : forall {A : Type} (a b : list A), a = b -> Datatypes.length a = Datatypes.length b.
Proof.
  intros.
  rewrite H0.
  tauto.
Qed.

Theorem staSemProgress : forall G (s'' : s) (s' : list s) (pre post : phi) initialHeap initialRho initialAccess S',
  wellTyped G s'' ->
  hoareSingle G pre s'' post ->
  consistent initialHeap initialRho ->
  evalphi initialHeap initialRho initialAccess pre ->
  exists finalHeap finalRho finalAccess,
    dynSemStar (initialHeap, (initialRho, initialAccess, s'' :: s') :: S') (finalHeap, (finalRho, finalAccess, s') :: S')
.
Proof.
  destruct s''; intros;
  inversion H1; clear H1; subst; unfold evalphi in H3.
  (*unfWT; simpl in H0; intuition.*)
  * apply H3 in H9.
    apply H3 in H11.
    apply H3 in H12.
    clear H3.
    inversion H9; clear H9; subst.
    inversion H11; clear H11; subst.
    inversion H12; clear H12; subst.
    simpl in *.
    inversion H10; clear H10. subst.
    rewrite H4 in *.
    inversion H7; clear H7. subst.
    tmp.
  * apply H3 in H7.
    clear H3.
    inversion H7; clear H7; subst.
    tmp.
  * specialize (HnotTotal initialHeap). intros.
    inversion H1.
    tmp.
  * subst.
    apply H3 in H11.
    inversion H11; clear H11; subst.
    simpl in *.
    inversion H10; clear H10; subst.
    specialize (evaleTClass G (ex x1) C' initialHeap initialRho).
    intros.
    intuition.
    inversion H4; simpl in H1; rewrite H5 in H1; inversion H1; clear H1; try (contradict H12; assumption; fail).
    inversion H6; clear H6; subst.
    clear H12 H4.
    inversion H0; clear H0.
    inversion H1; clear H1.
    inversion H0; clear H0.
    inversion H1; clear H1.
    inversion H0; clear H0.
    inversion H1; clear H1.
    inversion H4; clear H4.
    inversion H6; clear H6.
    rewrite H0 in *.
    inversion H8; clear H8.
    subst.

    destruct x6.

    unfold mpre in H14.
    unfold mcontract in H14.
    rewrite H1 in H14.
    simpl in H14.
    inversion H14; clear H14.
    subst.
    unfold phiImplies in H13.
    unfold evalphi in H13.
    specialize (H13 initialHeap initialRho initialAccess).
    intuition.
    clear H3.

    repeat eexists. econstructor; econstructor.
    instantiate (pre := p0).
    - eauto.
    - simpl.
      instantiate (wvs' := combine (map snd x5) (map (fun xx => match xx with 
            | Some vv => vv
            | None => vnull
            end) (map initialRho (map snd Xz')))).
      rewrite mapSplitSnd.
      rewrite mapSplitSnd.
      rewrite combine_split.
      + simpl.
        admit.
        (*rewrite map_map.
        admit.
        erewrite map_ext_in.*)
      + rewrite map_length.
        rewrite map_length.
        rewrite map_length.
        rewrite split_length_r.
        apply lengthId in H7.
        rewrite map_length in H7.
        rewrite map_length in H7.
        rewrite map_length in H7.
        rewrite map_length in H7.
        assumption.
    - eauto.
    - instantiate (C' := C').
      unfold mbody.
      rewrite H1.
      simpl.
      eauto.
    - unfold mparams.
      rewrite H1.
      simpl.
      rewrite mapSplitFst.
      rewrite combine_split.
      + simpl.
        tauto.
      + rewrite map_length.
        rewrite map_length.
        rewrite map_length.
        rewrite map_length.
        apply lengthId in H7.
        rewrite map_length in H7.
        rewrite map_length in H7.
        rewrite map_length in H7.
        rewrite map_length in H7.
        assumption.
    - unfold mpre. unfold mcontract.
      rewrite H1.
      simpl.
      eauto.
    - intuition.
    - admit.
    - intuition.
    - admit.
    - admit.
  * apply H3 in H8.
    inversion H8; clear H8; subst.
    tmp.
  * tmp.
  * tmp.
    unfold phiImplies in H5.
    unfold evalphi in H5.
    specialize (H5 initialHeap initialRho initialAccess).
    apply H5; try assumption.
    apply in_eq.
Admitted.

Lemma exists_forall : forall {A : Type} (b : A -> Prop) (c : Prop), ((exists a, b a) -> c) -> (forall a, b a -> c).
Proof.
  intros.
  apply H0.
  eauto.
Qed.
  

Lemma rhoVSeSubst : forall e'' e''' h r e' x' v', 
 evale h r e' = Some v' ->
 eSubst x' e' e'' = e''' ->
  evale h (rhoSubst x' v' r) e'' =
  evale h r e'''.
Proof.
  induction e''; intros; subst.
  - simpl. auto.
  - simpl eSubst. simpl. unfold rhoSubst.
    case_eq (x_decb x0 x'); intros; simpl; try tauto.
    rewrite H0.
    tauto.
Qed.

Lemma rhoVSphiSubst1 : forall e'' e''' h r e' x' v' a, 
 evale h r e' = Some v' ->
 phi'Subst x' e' e'' = e''' ->
  (evalphi' h (rhoSubst x' v' r) a e'' ->
  evalphi' h r a e''').
Proof.
  induction e''; intros; subst; intros; try constructor; simpl in *.
  - inversion H2; clear H2; subst.
    econstructor.
    * erewrite rhoVSeSubst in H4; eauto.
    * erewrite rhoVSeSubst in H8; eauto.
    * tauto.
  - inversion H2; clear H2; subst.
    econstructor.
    * erewrite rhoVSeSubst in H4; eauto.
    * erewrite rhoVSeSubst in H8; eauto.
    * tauto.
  - inversion H2; clear H2; subst.
    econstructor.
    * erewrite rhoVSeSubst in H7; eauto.
    * tauto.
Qed.
Lemma rhoVSphiSubst2 : forall e'' e''' h r e' x' v' a, 
 evale h r e' = Some v' ->
 phi'Subst x' e' e'' = e''' ->
  (evalphi' h r a e''' ->
  evalphi' h (rhoSubst x' v' r) a e'').
Proof.
  induction e''; intros; subst; intros; try constructor; simpl in *.
  - inversion H2; clear H2; subst.
    specialize (rhoVSeSubst e0 (eSubst x' e' e0) h r e' x' v').
    intros.
    specialize (rhoVSeSubst e1 (eSubst x' e' e1) h r e' x' v').
    intros.
    intuition.
    rewrite H8, H4 in *.
    econstructor; eauto.
  - inversion H2; clear H2; subst.
    specialize (rhoVSeSubst e0 (eSubst x' e' e0) h r e' x' v').
    intros.
    specialize (rhoVSeSubst e1 (eSubst x' e' e1) h r e' x' v').
    intros.
    intuition.
    rewrite H8, H4 in *.
    econstructor; eauto.
  - inversion H2; clear H2; subst.
    specialize (rhoVSeSubst e0 (eSubst x' e' e0) h r e' x' v').
    intros.
    intuition.
    rewrite H7 in *.
    econstructor; eauto.
Qed.

Theorem staSemPreservation : forall G (s'' : s) (s' : list s) (pre post : phi) initialHeap initialRho initialAccess S' finalHeap finalRho finalAccess sRem,
  wellTyped G s'' ->
  hoareSingle G pre s'' post ->
  consistent initialHeap initialRho ->
  evalphi initialHeap initialRho initialAccess pre ->
  dynSem (initialHeap, (initialRho, initialAccess, s'' :: s') :: S') (finalHeap, (finalRho, finalAccess, sRem) :: S') ->
  evalphi finalHeap finalRho finalAccess post.
Proof.
  destruct s'';
  intros;
  inversion H4; clear H4;
  inversion H1; clear H1;
  simpl in H0;
  try subst;
  unfold evalphi; intros;
  unfold consistent in H2.
  - apply in_app_or in H1.
    inversion H1; clear H1.
    * admit.
    * inversion H4; clear H4; try inversion H1; clear H1.
      subst.
      econstructor; simpl in *.
      + rewrite H9.
        instantiate (v1 := yv').
        unfold HSubst.
        assert (o_decb o' o' = true). unfold o_decb. unfold dec2decb. destruct (o_dec o' o'); auto.
        rewrite H1.
        eapply H2 in H9.
        rewrite H9.
        instantiate (res := (_, _)).
        simpl.
        unfold f_decb.
        unfold string_decb.
        unfold dec2decb.
        destruct (string_dec f0 f0); auto.
        contradict n; auto.
      + eauto.
      + auto.
  - unfold evalphi in H3.
    specialize (H3 (phi'Subst x0 e0 p')).
    eapply rhoVSphiSubst2; eauto.
    apply H3.
    unfold phiSubst.
    apply in_map.
    assumption.
  - rewrite H26 in *.
    inversion H17; clear H17; subst.
    clear H24.
    generalize H26.
    generalize H1.
    generalize Cf'.
    clear H26 H1 Cf'.
    induction Cf'; simpl; intros.
    * rewrite app_nil_r.
      inversion H1; clear H1.
      + subst.
        econstructor; simpl.
          unfold rhoSubst.
          unfold x_decb.
          unfold dec2decb.
          destruct (x_dec x0 x0); try (contradict n; tauto).
          auto.

          auto.

          unfold not. intros. inversion H1.
      + admit. (* unfold evalphi in H3.
        apply H3 in H4. clear H3.
        eapply (evaleTClass G (ex x0) c initialHeap (rhoSubst x0 (vo o') initialRho)) in H0; simpl in H0.
        inversion H0.
          unfold rhoSubst in H1.
          unfold x_decb in H1.
          unfold dec2decb in H1.
          destruct (x_dec x0 x0); try (contradict n; tauto).
          inversion H1.
        
        case_eq (initialRho x0); intros.
          .
        specialize H2
        eapply rhoVSphiSubst2 in H4; eauto.
          instantiate (e' := ex x0).
          simpl; auto.
          generalize evaleTClass.
          instantiate (e' := ev (vo o')).
          simpl; auto.
          
          simpl; auto.
          
          unfold phi'Subst.
          destruct p'; auto.
          
          *)
    * admit.
  - apply lengthId in H19.
    simpl in H19.
    contradict H19.
    auto with arith.
  - eapply rhoVSphiSubst2; eauto.
    unfold evalphi in H3.
    admit.
  - unfold evalphi in H3.
    intuition.
  - unfold phiImplies in H17.
    apply H17 in H3.
    unfold evalphi in H3.
    specialize (H3 p').
    assert (In p' (p0 :: post)).
      apply in_cons; assumption.
    intuition.
    destruct p'; inversion H5; clear H5; subst; econstructor; try eauto.
    unfold Aexcept.
    unfold except.
    apply filter_In.
    intuition.
    apply negb_true_iff.
    apply not_true_is_false.
    unfold not.
    intros.
    apply existsb_exists in H3.
    inversion H3; clear H3.
    intuition.
    unfold A'_decb in *.
    apply andb_prop in H6.
    intuition.
    unfold name_decb, string_decb in *.
    unfold dec2decb in *.
    destruct (name_dec (fst (nameo o', f0)) (fst x0)); inversion H5.
    destruct (string_dec (snd (nameo o', f0)) (snd x0)); inversion H8.
    simpl in *.
    clear H8 H5 H4 H17.
    destruct x0. simpl in *.
    subst.
    unfold sfrmphi in *.
    apply H20 in H1.
    inversion H1; clear H1; subst.
    inversion H6; clear H6; subst; simpl in *.
    destruct p0; simpl in H3; try inversion H3.
    destruct e1; simpl in H3.
    * destruct v0; try (inversion H3; clear H3).
      inversion H20.
      + inversion H4; clear H4. subst.
        inversion H7; clear H7. subst.

    apply in_app_or in H1.
    inversion H1; clear H1.
    * apply H3 in H4.
      eapply rhoVSphiSubst2; eauto.
      assert (p' = phi'Subst xresult (ex x0) p').
    assert (H333 := H3).
    specialize (H3 p').
    unfold phiSubst in H3.
    rewrite (in_map_iff (phi'Subst x0 e0) post p') in H3.
    assert (forall x : phi', (phi'Subst x0 e0 x = p' ∧ In x post) → evalphi' finalHeap initialRho finalAccess p').
      intros.
      apply H3.
      eexists. eassumption.
    
    eapply rhoVSphiSubst.
    
    clear H3.
    pose proof (H4 p').
    destruct (phi'Subst x0 e0 p' == p').
    * rewrite e1 in *. intuition.
      inversion H5; clear H5; subst; econstructor.
      + simpl in e1.
        destruct e2; intros; simpl.
          eauto.

          unfold rhoSubst.
          unfold x_decb.
          unfold dec2decb.
          destruct (x_dec x1 x0).
            subst.
            inversion e1; clear e1.
            unfold x_decb in *.
            unfold dec2decb in *.
            case_eq (x_dec x0 x0); intros;
            try (clear H5; contradict n; auto; fail).
            rewrite H5 in *. rewrite H8 in *. clear e1 H5 H8.
            simpl in *. rewrite H7 in *.
            assumption.

            simpl in H3. assumption.

          inversion H3; clear H3.
          assert (evale finalHeap (rhoSubst x0 v' initialRho) e2 = evale finalHeap initialRho e2).
            inversion e1; clear e1.
            eapply rhoVSeSubst; eauto. rewrite H5. assumption.
          rewrite H3.
          tauto.
      + assert (evale finalHeap (rhoSubst x0 v' initialRho) e3 = evale finalHeap initialRho e3).
          inversion e1; clear e1.
          eapply rhoVSeSubst; eauto. rewrite H9. assumption.
        rewrite H5.
        eauto.
      + tauto.
      + simpl in e1.
        destruct e2; simpl.
          eauto.

          unfold rhoSubst.
          unfold x_decb.
          unfold dec2decb.
          destruct (x_dec x1 x0).
            subst.
            inversion e1; clear e1.
            unfold x_decb in *.
            unfold dec2decb in *.
            case_eq (x_dec x0 x0); intros;
            try (clear H5; contradict n; auto; fail).
            rewrite H5 in *. rewrite H9 in *. clear e1 H5 H9.
            simpl in *. rewrite H7 in *.
            assumption.

            simpl in H3. assumption.

          inversion H3; clear H3.
          assert (evale finalHeap (rhoSubst x0 v' initialRho) e2 = evale finalHeap initialRho e2).
            inversion e1; clear e1.
            eapply rhoVSeSubst; eauto. rewrite H5. assumption.
          rewrite H3.
          tauto.
      + assert (evale finalHeap (rhoSubst x0 v' initialRho) e3 = evale finalHeap initialRho e3).
          inversion e1; clear e1.
          eapply rhoVSeSubst; eauto. rewrite H10. assumption.
        rewrite H5.
        eauto.
      + tauto.
      + simpl in *.
        unfold rhoSubst.
        destruct (x_decb x' x0); inversion e1.
        eauto.
      + assumption.
    * specialize (H333 p').
      clear H4.
      destruct p'; simpl in *.
      + intuition.
      + econstructor.
        admit. admit. admit.
      + econstructor.
        admit. admit. admit.
      + econstructor.
          simpl.
          unfold rhoSubst.
          destruct (x_decb x1 x0).
        
         clear e1.
        simpl in *.

inversion e1; clear e1.
          
          clear H3 H8.
          inversion e1; clear e1.
          rewrite H5.
          rewrite H8.

      + econstructor.
    intuition.
    SearchAbout (forall).
    specialize (H3 p').
    destruct p'; try constructor.
    * econstructor.
      

    SearchPattern (((exists _, _) -> _) -> forall _, _ -> _).
    SearchAbout In.
    rewrite in_map in H3.
     econstructor.
    


Theorem staSemSound : forall (prog : program) (body : list s) (pre post : phi) initialHeap initialRho initialAccess S',
  @hoare prog pre body post ->
  evalphi initialHeap initialRho initialAccess pre ->
  exists finalHeap finalRho finalAccess, (
    @dynSemStar prog (initialHeap, (initialRho, initialAccess, body) :: S') (finalHeap, (finalRho, finalAccess, []) :: S') /\
    evalphi finalHeap finalRho finalAccess post
  ).
Proof.
  intro prog.
  induction body; intros.
  - repeat eexists.
    * constructor.
    * inversion H0.
      subst.
      assumption.
  - inversion H0. clear H0.
    subst.
    specialize (IHbody q1 post).
    destruct a; inversion H4; clear H4; subst.
    * edestruct IHbody; clear IHbody.
      + eapply hoareImplies; repeat eauto.
      + econstructor.
      ++  eauto.
      ++  specialize (AexceptReverse initialAccess); intros.
          rewrite H0.
          eauto.
      ++  econstructor.
          ** simpl.
          inversion H0; clear H0.
          inversion H2; clear H2.
          inversion H0; clear H0.
          instantiate (initialAccess := x2).
          symmetry in H2. rewrite H2 in *.
          apply H1.

    edestruct IHbody; clear IHbody.

    Focus 3.
      inversion H0; clear H0.
      inversion H2; clear H2.
      inversion H0; clear H0.
      repeat eexists; eauto.
      econstructor.
      + destruct a; inversion H4; clear H4; subst.
    

    + eapply hoareImplies; repeat eauto.
    +
    + eapply hoareSingleEvalPhi; repeat eauto.
    + inversion H0; clear H0.
      inversion H2; clear H2.
      inversion H0; clear H0.
      repeat eexists; eauto.



    destruct a; inversion H4; clear H4; subst.
    * edestruct IHbody; clear IHbody.
      + eapply hoareImplies; repeat eauto.
      + econstructor.
      ++  eauto.
      ++  specialize (AexceptReverse initialAccess); intros.
          inversion H0; clear H0.
          inversion H2; clear H2.
          inversion H0; clear H0.
          instantiate (initialAccess := x2).
          symmetry in H2. rewrite H2 in *.
          apply H1.




      destruct a.
      * repeat econstructor.
        ++ simpl. .econstructor.
      econstructor.
      * destruct a.
      exists x0. exists x1. exists x2.
      repeat eexists.
      ++ econstructor.
      repeat eexists; eauto.
      econstructor; eauto.
      destruct a.
    inversion H4; clear H4; subst;
    repeat eexists.
    * 
      econstructor;
      edestruct IHbody.
      + econstructor.
        auto.
      + edestruct IHbody.
        specialize (IHbody initialHeap (rhoSubst x' vnull initialRho) initialAccess S').
        destruct IHbody.
        assert 
        erewrite IHbody.
        instantiate (b := (_, _)).
        admit.
      + 
    rewrite ESSStep.
    
    apply IHbody.
  generalize body. clear body


Theorem staSemSoundCorollary : forall prog : program,
  @hoare prog phiTrue (getMain prog) phiTrue -> exists endState : execState, @dynSemFull prog (newHeap, [(newRho, newAccess, getMain prog)]) endState.
Proof.
  destruct prog as [classes main]; simpl.
  generalize main. clear main.
  induction main; intros.
  - unfold runsThrough.
    eexists.
    split.
    * constructor.
    * unfold isFinished.
      repeat eexists.
  - destruct main.
    * 
  
  simpl in *.
  
  

(* playground *)
Open Scope string_scope.

Notation "AA '⊢sfrme' ee" := (sfrme AA ee) (at level 90).

Print sfrme.
Print dynSem.

Notation "classes 'main:' main" := (Program classes main) (at level 100).
Notation "'class' c { fs ms }" := (Cls c fs ms).

Check (Cls "a" [] []).



