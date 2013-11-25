{-# OPTIONS --without-K #-}

{-
Truncated higher inductive types look like higher inductive types except that
they are truncated down to some fixed truncation level.
This allow to define truncations (obviously) but also free algebras for
algebraic theories, Eilenberg-MacLane spaces, etc.

The idea is that to get an n-truncated higher inductive type, you just have to
add the following two constructors, where [I] is the HIT you are defining.

    top  : (f : Sⁿ n → I) → I
    rays : (f : Sⁿ n → I) (x : Sⁿ n) → top f ≡ f x

In this file, I prove whatever is needed to go from the usual elimination rules
generated by the previous constructors to the elimination rules that we expect
from truncated higher inductive types.

We have to note that the previous definition does not work for [n = 0], because
this only adds a point to I instead of turning it into a contractible space.
0-truncated higher inductive types are not really interesting but handling
truncations is easier when 0 is not special

Hence I’m adding the following path constructor

    hack-prop : (p : n ≡ 0) (x y : τ) → (x ≡ y)

This will force [I] to be a prop (hence contractible because [top] of the empty
function is of type [I]) and does not change anything when [n] is not 0.


I may use the following syntax for [n]-truncated higher inductive types:

    (n)data I : Set i where
      …

-}

module Homotopy.TruncatedHIT where

open import Base
open import Spaces.Spheres public
open import Spaces.Suspension public

_+1 : ℕ₋₂ → ℕ
⟨-2⟩ +1 = 0
(S ⟨-2⟩) +1 = 0
(S n) +1 = S (n +1)

-- [hSⁿ n] is what is supposed to be filled to get something n-truncated
hSⁿ : ℕ₋₂ → Set
hSⁿ ⟨-2⟩ = ⊥
hSⁿ n = Sⁿ (n +1)

-- Type of fillings of a sphere
filling : ∀ {i} (n : ℕ₋₂) {A : Set i} (f : hSⁿ n → A) → Set i
filling {i} n {A} f = Σ A (λ t → ((x : hSⁿ n) → t ≡ f x))

-- Type of dependent fillings of a sphere above a ball
filling-dep : ∀ {i j} (n : ℕ₋₂) {A : Set i} (P : A → Set j) (f : hSⁿ n → A)
  (fill : filling n f) (p : (x : hSⁿ n) → P (f x)) → Set j
filling-dep {i} {j} n {A} P f fill p =
  Σ (P (π₁ fill)) (λ t → ((x : hSⁿ n) → transport P (π₂ fill x) t ≡ p x))

-- [has-n-spheres-filled n A] is inhabited iff every n-sphere in [A] can be
-- filled with an (n+1)-ball.
-- We will show that this is equivalent to being n-truncated, *for n > 0*
-- (for n = 0, having 0-spheres filled only means that A is inhabited)
has-spheres-filled : ∀ {i} (n : ℕ₋₂) (A : Set i) → Set i
has-spheres-filled n A = (f : hSⁿ n → A) → filling n f

-- [has-n-spheres-filled] satisfy the same inductive property
-- than [is-truncated]
fill-paths : ∀ {i} (n : ℕ₋₂) (A : Set i) (t : has-spheres-filled (S n) A)
  → (n ≡ ⟨-2⟩ → is-contr A) → ((x y : A) → has-spheres-filled n (x ≡ y))
fill-paths ⟨-2⟩ A t contr x y f =
  (contr-has-all-paths (contr refl) x y , abort)
fill-paths (S n) A t _ x y f =
  ((! (π₂ u (north _)) ∘ π₂ u (south _))
  , (λ z → ! (lemma (paths _ z)) ∘ suspension-β-paths-nondep _ _ _ _ f _)) where

  -- [f] is a map from [hSⁿ (S n)] to [x ≡ y], we can build from it a map
  -- from [hSⁿ (S n)] to [A]
  newf : hSⁿ (S (S n)) → A
  newf = suspension-rec-nondep _ _ x y f

  u : filling (S (S n)) newf
  u = t newf
  -- I’ve got a filling

  -- Every path in the sphere is equal (in A) to the canonical path going
  -- through the center of the filled sphere
  lemma : {p q : hSⁿ (S (S n))} (l : p ≡ q)
    → ap newf l ≡ ! (π₂ u p) ∘ π₂ u q
  lemma {p = a} refl = ! (opposite-left-inverse (π₂ u a))

-- We first prove that if n-spheres are filled, then the type is n-truncated,
-- we have to prove it for n = -1, and then use the previous lemma
abstract
  spheres-filled-is-truncated : ∀ {i} (n : ℕ₋₂) (A : Set i)
    → ((n ≡ ⟨-2⟩ → is-contr A) → has-spheres-filled n A → is-truncated n A)
  spheres-filled-is-truncated ⟨-2⟩ A contr t = contr refl
  spheres-filled-is-truncated (S ⟨-2⟩) A _ t =
    all-paths-is-prop (λ x y → ! (π₂ (t (f x y)) true) ∘ π₂ (t (f x y)) false)
    where
      f : (x y : A) → bool {zero} → A
      f x y true = x
      f x y false = y
  spheres-filled-is-truncated (S (S n)) A _ t = λ x y →
    spheres-filled-is-truncated (S n) (x ≡ y) (λ ())
      (fill-paths (S n) A t (λ ()) x y)

-- We now prove the converse
abstract
  truncated-has-spheres-filled : ∀ {i} (n : ℕ₋₂) (A : Set i)
    (t : is-truncated n A) → has-spheres-filled n A
  truncated-has-spheres-filled ⟨-2⟩ A t f = (π₁ t , abort)
  truncated-has-spheres-filled (S ⟨-2⟩) A t f =
    (f true , (λ {true → refl ; false → π₁ (t (f true) (f false))}))
  truncated-has-spheres-filled (S (S n)) A t f =
    (f (north _)
    , (suspension-rec _ _ refl (ap f (paths _ (⋆Sⁿ _)))
        (λ x → trans-cst≡app (f (north _)) f (paths _ _) _
               ∘ (! (π₂ filled-newf x) ∘ π₂ filled-newf (⋆Sⁿ _))))) where

    newf : hSⁿ (S n) → (f (north _) ≡ f (south _))
    newf x = ap f (paths _ x)

    filled-newf : filling (S n) newf
    filled-newf = truncated-has-spheres-filled (S n) _ (t _ _) newf

-- I prove that if [A] has [S n]-spheres filled, then the type of fillings
-- of [n]-spheres is a proposition. The idea is that two fillings of
-- an [n]-sphere define an [S n]-sphere, which is then filled.
filling-has-all-paths : ∀ {i} (n : ℕ₋₂) (A : Set i)
  ⦃ fill : has-spheres-filled (S n) A ⦄ (f : hSⁿ n → A)
  → has-all-paths (filling n f)
filling-has-all-paths ⟨-2⟩ A ⦃ fill ⦄ f fill₁ fill₂ =
  Σ-eq (! (π₂ big-map-filled true) ∘ π₂ big-map-filled false) (funext abort)
  where

  big-map : hSⁿ ⟨-1⟩ → A
  big-map true = π₁ fill₁
  big-map false = π₁ fill₂

  big-map-filled : filling ⟨-1⟩ big-map
  big-map-filled = fill big-map

filling-has-all-paths (S n) A ⦃ fill ⦄ f fill₁ fill₂ =
  Σ-eq (! (π₂ big-map-filled (north _)) ∘ π₂ big-map-filled (south _))
  (funext (λ x →
                   trans-Π2 _ (λ t x₁ → t ≡ f x₁)
                   (! (π₂ big-map-filled (north _)) ∘
                    π₂ big-map-filled (south _))
                   (π₂ fill₁) x
                   ∘ (trans-id≡cst
                        (! (π₂ big-map-filled (north _)) ∘
                         π₂ big-map-filled (south _))
                        (π₂ fill₁ x)
                   ∘ move!-right-on-left
                       (! (π₂ big-map-filled (north _)) ∘
                        π₂ big-map-filled (south _))
                       _ _
                    (move-left-on-right _
                       (! (π₂ big-map-filled (north _)) ∘
                        π₂ big-map-filled (south _))
                       _
                    (! (suspension-β-paths-nondep _ _ _ _ g x)
                     ∘ lemma (paths _ x)))))) where

  g : hSⁿ (S n) → (π₁ fill₁ ≡ π₁ fill₂)
  g x = π₂ fill₁ x ∘ ! (π₂ fill₂ x)

  big-map : hSⁿ (S (S n)) → A
  big-map = suspension-rec-nondep _ _ (π₁ fill₁) (π₁ fill₂) g

  big-map-filled : filling (S (S n)) big-map
  big-map-filled = fill big-map

  lemma : {u v : hSⁿ (S (S n))} (p : u ≡ v)
    → ap big-map p ≡ (! (π₂ big-map-filled u) ∘  π₂ big-map-filled v)
  lemma {u = a} refl = ! (opposite-left-inverse (π₂ big-map-filled a))

abstract
  truncated-has-filling-dep : ∀ {i j} (A : Set i) (P : A → Set j) (n : ℕ₋₂)
    ⦃ trunc : (x : A) → is-truncated n (P x) ⦄
    (contr : n ≡ ⟨-2⟩ → is-contr A)
    (fill : has-spheres-filled n A) (f : hSⁿ n → A) (p : (x : hSⁿ n) → P (f x))
    → filling-dep n P f (fill f) p
  truncated-has-filling-dep A P ⟨-2⟩ ⦃ trunc ⦄ contr fill f p =
    (π₁ (trunc (π₁ (fill f))) , abort)
  truncated-has-filling-dep A P (S n) ⦃ trunc ⦄ contr fill f p =
    transport (λ t → filling-dep (S n) P f t p) eq fill-dep  where

    -- Combining [f] and [p] we have a sphere in the total space of [P]
    newf : hSⁿ (S n) → Σ A P
    newf x = (f x , p x)

    -- But this total space is (S n)-truncated
    ΣAP-truncated : is-truncated (S n) (Σ A P)
    ΣAP-truncated =
      Σ-is-truncated (S n) (spheres-filled-is-truncated (S n) A contr fill)
                     trunc

    -- Hence the sphere is filled
    tot-fill : filling (S n) newf
    tot-fill = truncated-has-spheres-filled (S n) (Σ A P) ΣAP-truncated newf

    -- We can split this filling as a filling of [f] in [A] …
    new-fill : filling (S n) f
    new-fill = (π₁ (π₁ tot-fill) , (λ x → base-path (π₂ tot-fill x)))

    -- and a dependent filling above the previous filling of [f], along [p]
    fill-dep : filling-dep (S n) P f new-fill p
    fill-dep = (π₂ (π₁ tot-fill) , (λ x → fiber-path (π₂ tot-fill x)))

    A-has-spheres-filled-S : has-spheres-filled (S (S n)) A
    A-has-spheres-filled-S =
      truncated-has-spheres-filled (S (S n)) A
        (truncated-is-truncated-S (S n)
          (spheres-filled-is-truncated (S n) A contr fill))

    -- But both the new and the old fillings of [f] are equal, hence we will
    -- have a dependent filling above the old one
    eq : new-fill ≡ fill f
    eq = filling-has-all-paths (S n) A f new-fill (fill f)
