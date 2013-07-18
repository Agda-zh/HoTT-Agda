{-# OPTIONS --without-K #-}

open import lib.Base

module lib.PathGroupoid where

module _ {i} {A : Type i} where

  {- Concatenation of paths

  There are two different definitions of concatenation of paths, [_∙_] and [_∙'_],
  with different definitionnal behaviour. Maybe we should have only one but it’s
  sometimes useful to have both (in particular in lib.types.Paths).
  -}

  infixr 8 _∙_ _∙'_

  _∙_ : {x y z : A}
    → (x == y → y == z → x == z)
  idp ∙ q = q

  _∙'_ : {x y z : A}
    → (x == y → y == z → x == z)
  q ∙' idp = q

  ∙=∙' : {x y z : A} (p : x == y) (q : y == z)
    → p ∙ q == p ∙' q
  ∙=∙' idp idp = idp

  ∙'=∙ : {x y z : A} (p : x == y) (q : y == z)
    → p ∙' q == p ∙ q
  ∙'=∙ idp idp = idp

  ∙-assoc : {x y z t : A} (p : x == y) (q : y == z) (r : z == t)
    → (p ∙ q) ∙ r == p ∙ (q ∙ r)
  ∙-assoc idp idp idp = idp

  -- [∙-unit-l] and [∙'-unit-r] are definitional

  ∙-unit-r : {x y : A} (q : x == y) → q ∙ idp == q
  ∙-unit-r idp = idp

  ∙'-unit-l : {x y : A} (q : x == y) → idp ∙' q == q
  ∙'-unit-l idp = idp

  {- Reversal of paths -}

  ! : {x y : A} → (x == y → y == x)
  ! idp = idp

  !-inv-l : {x y : A} (p : x == y) → (! p) ∙ p == idp
  !-inv-l idp = idp

  !-inv-r : {x y : A} (p : x == y) → p ∙ (! p) == idp
  !-inv-r idp = idp

  {- Interactions between operations

  A lemma of the form [!-∙ …] gives a result of the form [! (_∙_ …) == …],
  and so on.
  -}

  !-∙ : {x y z : A} (p : x == y) (q : y == z) → ! (p ∙ q) == ! q ∙ ! p
  !-∙ idp idp = idp

  ∙-! : {x y z : A} (q : y == z) (p : x == y) → ! q ∙ ! p == ! (p ∙ q)
  ∙-! idp idp = idp

  !-! : {x y : A} (p : x == y) → ! (! p) == p
  !-! idp = idp

  {- Horizontal compositions -}

  _∙2_ : {x y z : A} {p p' : x == y} {q q' : y == z} (α : p == p') (β : q == q')
    → p ∙ q == p' ∙ q'
  _∙2_ {p = idp} idp β = β

  _∙'2_ : {x y z : A} {p p' : x == y} {q q' : y == z} (α : p == p') (β : q == q')
    → p ∙' q == p' ∙' q'
  _∙'2_ {q = idp} α idp = α

  idp∙2idp : {x y z : A} (p : x == y) (q : y == z)
    → (idp {a = p}) ∙2 (idp {a = q}) == idp
  idp∙2idp idp idp = idp

  idp∙'2idp : {x y z : A} (p : x == y) (q : y == z)
    → (idp {a = p}) ∙'2 (idp {a = q}) == idp
  idp∙'2idp idp idp = idp

{-
Sometimes we need to restart a new section in order to have everything in the
previous one generalized.
-}
module _ {i} {A : Type i} where

  -- Useful ?
  anti-whisker-right : {x y z : A} (p : y == z) {q r : x == y}
    → (q ∙ p == r ∙ p → q == r)
  anti-whisker-right idp {q} {r} h =
    ! (∙-unit-r q) ∙ (h ∙ ∙-unit-r r)

  -- anti-whisker-left : {x y z : A} (p : x == y) {q r : y == z}
  --   → (p ∙ q == p ∙ r → q == r)
  -- anti-whisker-left idp h = h


{- Dependent stuff -}
module _ {i j} {A : Type i} {B : A → Type j} where

  {- Dependent concatenation -}

  _∙dep_ : {x y z : A} {p : x == y} {p' : y == z}
    {u : B x} {v : B y} {w : B z}
    → (u == v [ B ↓ p ]
    → v == w [ B ↓ p' ]
    → u == w [ B ↓ (p ∙ p') ])
  _∙dep_ {p = idp} {p' = idp} q r = q ∙ r

  _◃_ = _∙dep_

  ◃idp : {x : A} {v w : B x} (q : w == v)
    → q ◃ idp == q
  ◃idp idp = idp

  _∙'dep_ : {x y z : A} {p : x == y} {p' : y == z}
    {u : B x} {v : B y} {w : B z}
    → (u == v [ B ↓ p ]
    → v == w [ B ↓ p' ]
    → u == w [ B ↓ (p ∙' p') ])
  _∙'dep_ {p = idp} {p' = idp} q r = q ∙' r

  _▹_ = _∙'dep_

  {- That’s not perfect, because [q] could be a dependent path. But in that case
     this is not well typed… -}
  idp▹ : {x : A} {v w : B x} (q : v == w)
    → idp ▹ q == q
  idp▹ idp = idp

  ▹idp : {x y : A} {p : x == y}
    {u : B x} {v : B y} (q : u == v [ B ↓ p ])
    → q ▹ idp == q
  ▹idp {p = idp} idp = idp

  _▹!_ : {x y z : A} {p : x == y} {p' : z == y}
    {u : B x} {v : B y} {w : B z}
    → u == v [ B ↓ p ]
    → w == v [ B ↓ p' ]
    → u == w [ B ↓ p ∙' (! p') ]
  _▹!_ {p' = idp} q idp = q

  idp▹! : {x : A} {v w : B x} (q : w == v)
    → idp ▹! q == ! q
  idp▹! idp = idp

  _!◃_ : {x y z : A} {p : y == x} {p' : y == z}
    {u : B x} {v : B y} {w : B z}
    → v == u [ B ↓ p ]
    → v == w [ B ↓ p' ]
    → u == w [ B ↓ (! p) ∙ p' ]
  _!◃_ {p = idp} idp q = q

  !◃idp :{x : A} {v w : B x} (q : v == w)
    → q !◃ idp == ! q
  !◃idp idp = idp


  {-
  This is some kind of dependent horizontal composition (used in [apd∙]).
  -}

  _∙2ᵈ_ : {x y z : Π A B}
    {a a' : A} {p : a == a'} {q : x a == y a} {q' : x a' == y a'}
    {r : y a == z a} {r' : y a' == z a'}
    → (q == q'            [ (λ a → x a == y a) ↓ p ])
    → (r == r'            [ (λ a → y a == z a) ↓ p ])
    → (q ∙ r == q' ∙ r' [ (λ a → x a == z a) ↓ p ])
  _∙2ᵈ_ {p = idp} α β = α ∙2 β

  _∙'2ᵈ_ : {x y z : Π A B}
    {a a' : A} {p : a == a'} {q : x a == y a} {q' : x a' == y a'}
    {r : y a == z a} {r' : y a' == z a'}
    → (q == q'            [ (λ a → x a == y a) ↓ p ])
    → (r == r'            [ (λ a → y a == z a) ↓ p ])
    → (q ∙' r == q' ∙' r' [ (λ a → x a == z a) ↓ p ])
  _∙'2ᵈ_ {p = idp} α β = α ∙'2 β

  {-
  [apd∙] reduces a term of the form [apd (λ a → q a ∙ r a) p], do not confuse it
  with [apd-∙] which reduces a term of the form [apd f (p ∙ q)].
  -}

  apd∙ : {a a' : A} {x y z : Π A B}
    (q : (a : A) → x a == y a) (r : (a : A) → y a == z a)
    (p : a == a')
    → apd (λ a → q a ∙ r a) p == apd q p ∙2ᵈ apd r p
  apd∙ q r idp = ! (idp∙2idp (q _) (r _))

  apd∙' : {a a' : A} {x y z : Π A B}
    (q : (a : A) → x a == y a) (r : (a : A) → y a == z a)
    (p : a == a')
    → apd (λ a → q a ∙' r a) p == apd q p ∙'2ᵈ apd r p
  apd∙' q r idp = ! (idp∙'2idp (q _) (r _))
