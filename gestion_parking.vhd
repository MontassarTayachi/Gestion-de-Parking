-- ============================================================
-- Composant : gestion_parking (Top-Level)
-- Description : Système complet de gestion d'un parking.
--   Instancie et connecte tous les sous-composants :
--     - 2 × detect_front_1  (détection front capteur entrée et sortie)
--     - 1 × compteur         (comptage du nombre de voitures)
--     - 1 × registre         (stockage capacité maximale)
--     - 1 × comparateur      (détection état parking plein)
--     - 1 × soustracteur     (calcul des places disponibles)
--
-- Architecture :
--
--  capt_entree ─→ [detect_front_1] ─→ up   ─┐
--                                             ├→ [compteur] ─→ count ─┬→ [comparateur] ─→ complet
--  capt_sortie ─→ [detect_front_1] ─→ down ─┘                        │
--                                                                      └→ [soustracteur]─→ nb_places_dispos
--  max_places_in ─→ [registre] ─→ max ───────────────────────────────┴→ (comparateur + soustracteur)
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gestion_parking is
    Port (
        clk              : in  STD_LOGIC;                       -- Horloge système
        rst              : in  STD_LOGIC;                       -- Reset asynchrone actif haut
        capt_entree      : in  STD_LOGIC;                       -- Capteur de présence à l'entrée
        capt_sortie      : in  STD_LOGIC;                       -- Capteur de présence à la sortie
        load_max         : in  STD_LOGIC;                       -- Signal de chargement de la capacité max
        max_places_in    : in  STD_LOGIC_VECTOR(3 downto 0);   -- Capacité maximale du parking
        nb_places_dispos : out STD_LOGIC_VECTOR(3 downto 0);   -- Nombre de places disponibles
        complet          : out STD_LOGIC                        -- '1' si parking complet
    );
end gestion_parking;

architecture Structural of gestion_parking is

    -- ----------------------------------------------------------
    -- Déclarations des composants
    -- ----------------------------------------------------------
    component detect_front_1 is
        Port (
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            signal_in : in  STD_LOGIC;
            pulse_out : out STD_LOGIC
        );
    end component;

    component compteur is
        Port (
            clk   : in  STD_LOGIC;
            rst   : in  STD_LOGIC;
            up    : in  STD_LOGIC;
            down  : in  STD_LOGIC;
            count : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component registre is
        Port (
            clk      : in  STD_LOGIC;
            rst      : in  STD_LOGIC;
            load     : in  STD_LOGIC;
            data_in  : in  STD_LOGIC_VECTOR(3 downto 0);
            data_out : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component comparateur is
        Port (
            count   : in  STD_LOGIC_VECTOR(3 downto 0);
            max     : in  STD_LOGIC_VECTOR(3 downto 0);
            complet : out STD_LOGIC
        );
    end component;

    component soustracteur is
        Port (
            max              : in  STD_LOGIC_VECTOR(3 downto 0);
            count            : in  STD_LOGIC_VECTOR(3 downto 0);
            nb_places_dispos : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- ----------------------------------------------------------
    -- Signaux internes
    -- ----------------------------------------------------------
    signal pulse_entree : STD_LOGIC;                       -- Impulsion front montant capteur entrée
    signal pulse_sortie : STD_LOGIC;                       -- Impulsion front montant capteur sortie
    signal count_val    : STD_LOGIC_VECTOR(3 downto 0);   -- Nombre de voitures dans le parking
    signal max_val      : STD_LOGIC_VECTOR(3 downto 0);   -- Capacité maximale stockée
    signal complet_int  : STD_LOGIC;                       -- Signal interne parking complet (bloque up)

begin

    -- ----------------------------------------------------------
    -- Instanciation : détecteur de front montant (ENTRÉE)
    -- ----------------------------------------------------------
    U_DETECT_ENTREE : detect_front_1
        port map (
            clk       => clk,
            rst       => rst,
            signal_in => capt_entree,
            pulse_out => pulse_entree
        );

    -- ----------------------------------------------------------
    -- Instanciation : détecteur de front montant (SORTIE)
    -- ----------------------------------------------------------
    U_DETECT_SORTIE : detect_front_1
        port map (
            clk       => clk,
            rst       => rst,
            signal_in => capt_sortie,
            pulse_out => pulse_sortie
        );

    -- ----------------------------------------------------------
    -- Instanciation : compteur/décompteur 4 bits
    -- ----------------------------------------------------------
    U_COMPTEUR : compteur
        port map (
            clk   => clk,
            rst   => rst,
            up    => pulse_entree AND NOT complet_int,  -- Bloqué si parking complet
            down  => pulse_sortie,                      -- Décrémente à chaque voiture sortant
            count => count_val
        );

    -- ----------------------------------------------------------
    -- Instanciation : registre de capacité maximale
    -- ----------------------------------------------------------
    U_REGISTRE : registre
        port map (
            clk      => clk,
            rst      => rst,
            load     => load_max,
            data_in  => max_places_in,
            data_out => max_val
        );

    -- ----------------------------------------------------------
    -- Instanciation : comparateur (parking complet ?)
    -- ----------------------------------------------------------
    U_COMPARATEUR : comparateur
        port map (
            count   => count_val,
            max     => max_val,
            complet => complet_int
        );

    complet <= complet_int;

    -- ----------------------------------------------------------
    -- Instanciation : soustracteur (places disponibles)
    -- ----------------------------------------------------------
    U_SOUSTRACTEUR : soustracteur
        port map (
            max              => max_val,
            count            => count_val,
            nb_places_dispos => nb_places_dispos
        );

end Structural;
