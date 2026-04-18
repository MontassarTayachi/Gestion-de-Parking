-- ============================================================
-- Testbench : tb_gestion_parking
-- Valide le système complet de gestion de parking :
--   - Chargement de la capacité maximale
--   - Entrées successives de voitures
--   - Sorties de voitures
--   - Vérification de l'état "complet"
--   - Vérification du nombre de places disponibles
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_gestion_parking is
end tb_gestion_parking;

architecture Behavioral of tb_gestion_parking is

    component gestion_parking is
        Port (
            clk              : in  STD_LOGIC;
            rst              : in  STD_LOGIC;
            capt_entree      : in  STD_LOGIC;
            capt_sortie      : in  STD_LOGIC;
            load_max         : in  STD_LOGIC;
            max_places_in    : in  STD_LOGIC_VECTOR(3 downto 0);
            nb_places_dispos : out STD_LOGIC_VECTOR(3 downto 0);
            complet          : out STD_LOGIC
        );
    end component;

    signal clk              : STD_LOGIC := '0';
    signal rst              : STD_LOGIC := '0';
    signal capt_entree      : STD_LOGIC := '0';
    signal capt_sortie      : STD_LOGIC := '0';
    signal load_max         : STD_LOGIC := '0';
    signal max_places_in    : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal nb_places_dispos : STD_LOGIC_VECTOR(3 downto 0);
    signal complet          : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

begin

    UUT : gestion_parking
        port map (
            clk              => clk,
            rst              => rst,
            capt_entree      => capt_entree,
            capt_sortie      => capt_sortie,
            load_max         => load_max,
            max_places_in    => max_places_in,
            nb_places_dispos => nb_places_dispos,
            complet          => complet
        );

    -- Génération de l'horloge
    clk_proc : process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    stim_proc : process
    begin
        -- -------------------------------------------------------
        -- Initialisation : Reset
        -- -------------------------------------------------------
        rst <= '1';
        wait for 25 ns;
        rst <= '0';
        wait for 2 * CLK_PERIOD;

        -- -------------------------------------------------------
        -- Configuration : Capacité max = 4 places
        -- -------------------------------------------------------
        max_places_in <= "0100";   -- 4 places
        load_max      <= '1';
        wait for CLK_PERIOD;
        load_max      <= '0';
        wait for 2 * CLK_PERIOD;

        assert UNSIGNED(nb_places_dispos) = 4
            report "[GESTION_PARKING] ERREUR: places dispo initiales devrait être 4, valeur = " &
                   integer'image(to_integer(UNSIGNED(nb_places_dispos)))
            severity ERROR;
        report "[GESTION_PARKING] Configuration capacité max=4 OK (dispos=4)" severity NOTE;

        -- -------------------------------------------------------
        -- Test : 1ère voiture entre → places = 3, complet = '0'
        -- -------------------------------------------------------
        capt_entree <= '1';
        wait for 3 * CLK_PERIOD;   -- capteur actif 3 CLK (front montant détecté par FSM)
        capt_entree <= '0';
        wait for 4 * CLK_PERIOD;

        assert UNSIGNED(nb_places_dispos) = 3
            report "[GESTION_PARKING] ERREUR: places dispo devrait être 3, valeur = " &
                   integer'image(to_integer(UNSIGNED(nb_places_dispos)))
            severity ERROR;
        assert complet = '0'
            report "[GESTION_PARKING] ERREUR: parking ne devrait pas être complet (1/4)" severity ERROR;
        report "[GESTION_PARKING] Voiture 1/4 OK (dispos=3, complet='0')" severity NOTE;

        -- -------------------------------------------------------
        -- Test : 2ème, 3ème voiture entrent
        -- -------------------------------------------------------
        capt_entree <= '1';
        wait for 3 * CLK_PERIOD;
        capt_entree <= '0';
        wait for 4 * CLK_PERIOD;

        capt_entree <= '1';
        wait for 3 * CLK_PERIOD;
        capt_entree <= '0';
        wait for 4 * CLK_PERIOD;

        assert UNSIGNED(nb_places_dispos) = 1
            report "[GESTION_PARKING] ERREUR: places dispo devrait être 1, valeur = " &
                   integer'image(to_integer(UNSIGNED(nb_places_dispos)))
            severity ERROR;
        assert complet = '0'
            report "[GESTION_PARKING] ERREUR: parking ne devrait pas être complet (3/4)" severity ERROR;
        report "[GESTION_PARKING] Voitures 2 et 3 entrées OK (dispos=1, complet='0')" severity NOTE;

        -- -------------------------------------------------------
        -- Test : 4ème voiture entre → parking COMPLET
        -- -------------------------------------------------------
        capt_entree <= '1';
        wait for 3 * CLK_PERIOD;
        capt_entree <= '0';
        wait for 4 * CLK_PERIOD;

        assert UNSIGNED(nb_places_dispos) = 0
            report "[GESTION_PARKING] ERREUR: places dispo devrait être 0, valeur = " &
                   integer'image(to_integer(UNSIGNED(nb_places_dispos)))
            severity ERROR;
        assert complet = '1'
            report "[GESTION_PARKING] ERREUR: parking devrait être COMPLET (4/4)" severity ERROR;
        report "[GESTION_PARKING] Parking COMPLET OK (dispos=0, complet='1')" severity NOTE;

        -- -------------------------------------------------------
        -- Test : Une voiture sort → parking plus complet, 1 place dispo
        -- -------------------------------------------------------
        capt_sortie <= '1';
        wait for 3 * CLK_PERIOD;
        capt_sortie <= '0';
        wait for 4 * CLK_PERIOD;

        assert UNSIGNED(nb_places_dispos) = 1
            report "[GESTION_PARKING] ERREUR: places dispo devrait être 1 après sortie, valeur = " &
                   integer'image(to_integer(UNSIGNED(nb_places_dispos)))
            severity ERROR;
        assert complet = '0'
            report "[GESTION_PARKING] ERREUR: parking ne devrait plus être complet après sortie" severity ERROR;
        report "[GESTION_PARKING] Sortie voiture OK (dispos=1, complet='0')" severity NOTE;

        -- -------------------------------------------------------
        -- Test : Reset du système
        -- -------------------------------------------------------
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        wait for 2 * CLK_PERIOD;

        -- Recharger la capacité max après reset (registre remis à 0)
        max_places_in <= "0100";
        load_max      <= '1';
        wait for CLK_PERIOD;
        load_max      <= '0';
        wait for 2 * CLK_PERIOD;

        assert UNSIGNED(nb_places_dispos) = 4
            report "[GESTION_PARKING] ERREUR: places dispo devrait être 4 après reset" severity ERROR;
        report "[GESTION_PARKING] Reset système OK (dispos=4)" severity NOTE;

        wait for 50 ns;
        assert false report "=== Simulation tb_gestion_parking terminée avec succès ===" severity NOTE;
        wait;
    end process;

end Behavioral;
