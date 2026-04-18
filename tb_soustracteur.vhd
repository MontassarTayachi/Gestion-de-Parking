-- ============================================================
-- Testbench : tb_soustracteur
-- Valide le fonctionnement du composant soustracteur :
--   nb_places_dispos = max - count
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_soustracteur is
end tb_soustracteur;

architecture Behavioral of tb_soustracteur is

    component soustracteur is
        Port (
            max              : in  STD_LOGIC_VECTOR(3 downto 0);
            count            : in  STD_LOGIC_VECTOR(3 downto 0);
            nb_places_dispos : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    signal max              : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal count            : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal nb_places_dispos : STD_LOGIC_VECTOR(3 downto 0);

begin

    UUT : soustracteur
        port map (max => max, count => count, nb_places_dispos => nb_places_dispos);

    stim_proc : process
    begin

        -- -------------------------------------------------------
        -- Test 1 : max=10, count=3 → dispos=7
        -- -------------------------------------------------------
        max <= "1010"; count <= "0011";   -- 10 - 3 = 7
        wait for 20 ns;

        assert UNSIGNED(nb_places_dispos) = 7
            report "[SOUSTRACTEUR] ERREUR: places dispo devrait être 7, valeur = " &
                   integer'image(to_integer(UNSIGNED(nb_places_dispos)))
            severity ERROR;
        report "[SOUSTRACTEUR] Test max=10, count=3 OK (dispos=7)" severity NOTE;

        -- -------------------------------------------------------
        -- Test 2 : max=5, count=5 → dispos=0 (parking plein)
        -- -------------------------------------------------------
        max <= "0101"; count <= "0101";   -- 5 - 5 = 0
        wait for 20 ns;

        assert UNSIGNED(nb_places_dispos) = 0
            report "[SOUSTRACTEUR] ERREUR: places dispo devrait être 0, valeur = " &
                   integer'image(to_integer(UNSIGNED(nb_places_dispos)))
            severity ERROR;
        report "[SOUSTRACTEUR] Test parking plein OK (dispos=0)" severity NOTE;

        -- -------------------------------------------------------
        -- Test 3 : max=8, count=0 → dispos=8 (parking vide)
        -- -------------------------------------------------------
        max <= "1000"; count <= "0000";   -- 8 - 0 = 8
        wait for 20 ns;

        assert UNSIGNED(nb_places_dispos) = 8
            report "[SOUSTRACTEUR] ERREUR: places dispo devrait être 8, valeur = " &
                   integer'image(to_integer(UNSIGNED(nb_places_dispos)))
            severity ERROR;
        report "[SOUSTRACTEUR] Test parking vide OK (dispos=8)" severity NOTE;

        -- -------------------------------------------------------
        -- Test 4 : max=15, count=7 → dispos=8
        -- -------------------------------------------------------
        max <= "1111"; count <= "0111";   -- 15 - 7 = 8
        wait for 20 ns;

        assert UNSIGNED(nb_places_dispos) = 8
            report "[SOUSTRACTEUR] ERREUR: places dispo devrait être 8, valeur = " &
                   integer'image(to_integer(UNSIGNED(nb_places_dispos)))
            severity ERROR;
        report "[SOUSTRACTEUR] Test max=15, count=7 OK (dispos=8)" severity NOTE;

        assert false report "=== Simulation tb_soustracteur terminée avec succès ===" severity NOTE;
        wait;
    end process;

end Behavioral;
