# TP1 : Gestion de Parking — Rapport VHDL

**Module :** Conception Numérique sur FPGA  
**Outil :** Vivado Design Suite / ModelSim  
**Carte cible :** Basys 3 (FPGA Artix-7)  
**Date :** Avril 2026

---

## 1. Objectifs

1. Modéliser en VHDL synthétisable un système de gestion de parking de voitures.
2. Valider et simuler le système via des testbenches.
3. Utiliser l'objet `assert ... report ... severity` pour valider le fonctionnement.
4. Implémenter la description sur FPGA Artix-7 (carte Basys 3).

---

## 2. Description du système

Le système gère la disponibilité des places d'un parking. Il fournit :

- **`nb_places_dispos`** : nombre de places disponibles (sortie 4 bits).
- **`complet`** : indicateur à `'1'` si le parking est plein.

Deux capteurs en entrée :

| Signal | Description |
|---|---|
| `capt_entree` | Capteur de présence à l'entrée du parking |
| `capt_sortie` | Capteur de présence à la sortie du parking |

Chaque passage de voiture incrémente ou décrémente un compteur interne. Le nombre de places disponibles est calculé par soustraction entre la capacité maximale et le nombre de voitures présentes.

---

## 3. Architecture globale

```
capt_entree ──→ [Detect_Front_1] ──→ up  ──┐
                                            ├──→ [Compteur 4 bits] ──→ count ──┬──→ [Comparateur] ──→ complet
capt_sortie ──→ [Detect_Front_1] ──→ down ─┘                                  │
                                                                               └──→ [Soustracteur] ──→ nb_places_dispos
max_places_in ──→ [Registre] ──→ max ──────────────────────────────────────────┴──→ (Comparateur + Soustracteur)
```

---

## 4. Description des composants

### 4.1 Composant `compteur`

**Fichier :** `compteur.vhd`

Compteur/décompteur 4 bits avec reset asynchrone actif haut.

| Port | Direction | Description |
|---|---|---|
| `clk` | in | Horloge système |
| `rst` | in | Reset asynchrone actif haut |
| `up` | in | `'1'` → incrémentation |
| `down` | in | `'1'` → décrémentation |
| `count` | out | Valeur de comptage (4 bits) |

**Comportement :**

```vhdl
if rst = '1' then
    count_reg <= "0000";
elsif rising_edge(clk) then
    if up = '1' and down = '0' then
        if count_reg < 15 then count_reg <= count_reg + 1; end if;
    elsif down = '1' and up = '0' then
        if count_reg > 0  then count_reg <= count_reg - 1; end if;
    end if;
end if;
```

- Protection **overflow** : la valeur ne dépasse pas 15 (4 bits max).
- Protection **underflow** : la valeur ne passe pas en dessous de 0.

---

### 4.2 Composant `registre`

**Fichier :** `registre.vhd`

Registre 4 bits permettant de stocker la capacité maximale du parking. Modifiable facilement sans recompilation.

| Port | Direction | Description |
|---|---|---|
| `clk` | in | Horloge système |
| `rst` | in | Reset asynchrone actif haut |
| `load` | in | `'1'` → chargement de `data_in` |
| `data_in` | in | Capacité maximale à charger (4 bits) |
| `data_out` | out | Capacité maximale stockée (4 bits) |

**Utilisation des niveaux de severity :**

| Severity | Condition | Message |
|---|---|---|
| `NOTE` | Valeur valide chargée | Affiche la capacité chargée |
| `WARNING` | `data_in = 0` | Capacité nulle détectée |
| `ERROR` | `data_in > 15` | Impossible sur 4 bits |

**Différences de comportement du simulateur :**

| Severity | Comportement ModelSim/GHDL |
|---|---|
| `NOTE` | Affichage dans la console, simulation continue normalement |
| `WARNING` | Affichage avec surbrillance, simulation continue |
| `ERROR` | Signalement d'erreur, la simulation peut s'arrêter selon les paramètres |
| `FAILURE` | Arrêt immédiat et inconditionnel de la simulation |

---

### 4.3 Composant `comparateur`

**Fichier :** `comparateur.vhd`

Compare le nombre de voitures présentes avec la capacité maximale du parking.

| Port | Direction | Description |
|---|---|---|
| `count` | in | Nombre de voitures dans le parking (4 bits) |
| `max` | in | Capacité maximale (4 bits) |
| `complet` | out | `'1'` si parking plein |

**Instruction concurrente conditionnelle :**

```vhdl
complet <= '1' when (UNSIGNED(count) >= UNSIGNED(max)) else '0';
```

---

### 4.4 Composant `soustracteur`

**Fichier :** `soustracteur.vhd`

Calcule le nombre de places disponibles.

$$\text{nb\_places\_dispos} = \text{max} - \text{count}$$

| Port | Direction | Description |
|---|---|---|
| `max` | in | Capacité maximale (4 bits) |
| `count` | in | Nombre de voitures (4 bits) |
| `nb_places_dispos` | out | Places disponibles (4 bits) |

```vhdl
nb_places_dispos <= STD_LOGIC_VECTOR(UNSIGNED(max) - UNSIGNED(count));
```

---

### 4.5 Composant `detect_front_1`

**Fichier :** `detect_front_1.vhd`

#### 5.1 — Problème

Le capteur peut rester à `'1'` pendant plusieurs coups d'horloge. Si le compteur s'incrémentait à chaque cycle, une seule voiture provoquerait plusieurs incrémentations. Il faut donc détecter **uniquement le front montant** et générer une impulsion d'exactement **1 période d'horloge**.

#### 5.1 — Diagramme d'états

```
                      signal_in = '1'
         ┌────────────────────────────────────┐
         │                                    ▼
    ┌────────────┐                    ┌──────────────┐
    │  S0_IDLE   │                    │  S1_PULSE    │
    │  out = '0' │                    │  out = '1'   │
    └────────────┘                    └──────────────┘
         ▲                                    │
         │  signal_in = '0'                   │ (toujours)
         │                                    ▼
         │                           ┌──────────────┐
         └───────────────────────────│  S2_WAIT     │
              signal_in = '0'        │  out = '0'   │
                                     └──────────────┘
```

| État | Condition de transition | État suivant | Sortie `pulse_out` |
|---|---|---|---|
| `S0_IDLE` | `signal_in = '1'` | `S1_PULSE` | `'0'` |
| `S0_IDLE` | `signal_in = '0'` | `S0_IDLE` | `'0'` |
| `S1_PULSE` | (toujours) | `S2_WAIT` | **`'1'`** |
| `S2_WAIT` | `signal_in = '1'` | `S2_WAIT` | `'0'` |
| `S2_WAIT` | `signal_in = '0'` | `S0_IDLE` | `'0'` |

#### 5.2 — Chronogramme (Figure 2)

```
clk        : __|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_
signal_in  : __________|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|__________
pulse_out  : _______________|‾|___________________
```

- `pulse_out = '1'` uniquement pendant **1 CLK** lors de la détection du front montant.
- Le signal `signal_in` peut rester haut aussi longtemps que nécessaire sans effet supplémentaire.

---

### 4.6 Composant `gestion_parking` (Top-Level)

**Fichier :** `gestion_parking.vhd`  
**Architecture :** Structurelle (`Structural`)

Instancie et connecte tous les composants par `port map` :

| Instance | Composant | Rôle |
|---|---|---|
| `U_DETECT_ENTREE` | `detect_front_1` | Détection front montant capteur entrée |
| `U_DETECT_SORTIE` | `detect_front_1` | Détection front montant capteur sortie |
| `U_COMPTEUR` | `compteur` | Décompte voitures dans le parking |
| `U_REGISTRE` | `registre` | Stocke la capacité maximale |
| `U_COMPARATEUR` | `comparateur` | Détecte l'état complet |
| `U_SOUSTRACTEUR` | `soustracteur` | Calcule les places disponibles |

**Ports du top-level :**

| Port | Direction | Description |
|---|---|---|
| `clk` | in | Horloge système |
| `rst` | in | Reset asynchrone actif haut |
| `capt_entree` | in | Capteur de présence entrée |
| `capt_sortie` | in | Capteur de présence sortie |
| `load_max` | in | Signal de chargement capacité max |
| `max_places_in` | in | Capacité maximale (4 bits) |
| `nb_places_dispos` | out | Nombre de places disponibles (4 bits) |
| `complet` | out | `'1'` si parking complet |

---

## 5. Validation et simulation

### 5.1 Plan de test

| Testbench | Composant testé | Cas couverts |
|---|---|---|
| `tb_compteur.vhd` | `compteur` | Reset, +5, -2, underflow, overflow |
| `tb_registre.vhd` | `registre` | Chargement valide, stabilité, valeur 0, assert severity |
| `tb_comparateur.vhd` | `comparateur` | count < max, count = max, count > max |
| `tb_soustracteur.vhd` | `soustracteur` | Cas normaux, max=count, count=0 |
| `tb_detect_front_1.vhd` | `detect_front_1` | Front long, front court, deux fronts successifs |
| `tb_gestion_parking.vhd` | `gestion_parking` | Scénario complet d'utilisation |

### 5.2 Scénario de simulation du top-level

Capacité max configurée à **4 places** :

| Étape | Action | `count` | `nb_places_dispos` | `complet` |
|---|---|---|---|---|
| Init | Reset + load max=4 | 0 | 4 | `'0'` |
| 1 | capt_entree pulse | 1 | 3 | `'0'` |
| 2 | capt_entree pulse | 2 | 2 | `'0'` |
| 3 | capt_entree pulse | 3 | 1 | `'0'` |
| 4 | capt_entree pulse | 4 | 0 | **`'1'`** |
| 5 | capt_sortie pulse | 3 | 1 | `'0'` |
| 6 | Reset système | 0 | 4 | `'0'` |

---

## 6. Structure des fichiers

```
PW_GestionParking/
├── compteur.vhd           # Composant 1 : Compteur/décompteur 4 bits
├── registre.vhd           # Composant 2 : Registre capacité max
├── comparateur.vhd        # Composant 3 : Comparateur
├── soustracteur.vhd       # Composant 4 : Soustracteur
├── detect_front_1.vhd     # Composant 5 : Détecteur de front montant (FSM)
├── gestion_parking.vhd    # Composant 6 : Top-level structurel
├── tb_compteur.vhd        # Testbench du compteur
├── tb_registre.vhd        # Testbench du registre
├── tb_comparateur.vhd     # Testbench du comparateur
├── tb_soustracteur.vhd    # Testbench du soustracteur
├── tb_detect_front_1.vhd  # Testbench du détecteur de front
├── tb_gestion_parking.vhd # Testbench du top-level
└── RAPPORT.md             # Ce rapport
```

---

## 7. Ordre de compilation (ModelSim / Vivado)

Les fichiers doivent être compilés dans la bibliothèque `work` dans l'ordre suivant :

```bash
# 1. Composants de base (pas de dépendances)
vcom compteur.vhd
vcom registre.vhd
vcom comparateur.vhd
vcom soustracteur.vhd
vcom detect_front_1.vhd

# 2. Top-level (dépend de tous les composants ci-dessus)
vcom gestion_parking.vhd

# 3. Testbenches
vcom tb_compteur.vhd
vcom tb_registre.vhd
vcom tb_comparateur.vhd
vcom tb_soustracteur.vhd
vcom tb_detect_front_1.vhd
vcom tb_gestion_parking.vhd
```

---

## 8. Conclusion

Le système de gestion de parking a été entièrement décrit en VHDL synthétisable. L'architecture structurelle du composant top-level `gestion_parking` permet d'assembler proprement tous les sous-composants. La machine d'états `detect_front_1` garantit qu'une voiture ne compte qu'une seule fois même si le capteur reste actif plusieurs cycles. L'utilisation des assertions VHDL dans le composant `registre` illustre les quatre niveaux de severity (`NOTE`, `WARNING`, `ERROR`, `FAILURE`) et leur impact sur le comportement du simulateur.
