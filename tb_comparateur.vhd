-- ============================================================
-- Testbench : tb_comparateur
-- Valide le fonctionnement du composant comparateur :
--   - count < max  → complet = '0'
--   - count = max  → complet = '1'
--   - count > max  → complet = '1'
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_comparateur is
end tb_comparateur;

architecture Behavioral of tb_comparateur is

    component comparateur is
        Port (
            count   : in  STD_LOGIC_VECTOR(3 downto 0);
            max     : in  STD_LOGIC_VECTOR(3 downto 0);
            complet : out STD_LOGIC
        );
    end component;

    signal count   : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal max     : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal complet : STD_LOGIC;

begin

    UUT : comparateur
        port map (count => count, max => max, complet => complet);

    stim_proc : process
    begin

        -- -------------------------------------------------------
        -- Test 1 : count (3) < max (5) → complet = '0'
        -- -------------------------------------------------------
        count <= "0011"; max <= "0101";   -- count=3, max=5
        wait for 20 ns;

        assert complet = '0'
            report "[COMPARATEUR] ERREUR: complet devrait être 0 (count=3 < max=5)" severity ERROR;
        report "[COMPARATEUR] Test count < max OK (complet='0')" severity NOTE;

        -- -------------------------------------------------------
        -- Test 2 : count (5) = max (5) → complet = '1'
        -- -------------------------------------------------------
        count <= "0101"; max <= "0101";   -- count=5, max=5
        wait for 20 ns;

        assert complet = '1'
            report "[COMPARATEUR] ERREUR: complet devrait être 1 (count=5 = max=5)" severity ERROR;
        report "[COMPARATEUR] Test count = max OK (complet='1')" severity NOTE;

        -- -------------------------------------------------------
        -- Test 3 : count (7) > max (5) → complet = '1'
        -- -------------------------------------------------------
        count <= "0111"; max <= "0101";   -- count=7, max=5
        wait for 20 ns;

        assert complet = '1'
            report "[COMPARATEUR] ERREUR: complet devrait être 1 (count=7 > max=5)" severity ERROR;
        report "[COMPARATEUR] Test count > max OK (complet='1')" severity NOTE;

        -- -------------------------------------------------------
        -- Test 4 : count (0) < max (10) → complet = '0'
        -- -------------------------------------------------------
        count <= "0000"; max <= "1010";   -- count=0, max=10
        wait for 20 ns;

        assert complet = '0'
            report "[COMPARATEUR] ERREUR: complet devrait être 0 (count=0, max=10)" severity ERROR;
        report "[COMPARATEUR] Test parking vide OK (complet='0')" severity NOTE;

        -- -------------------------------------------------------
        -- Test 5 : count (0) = max (0) → complet = '1' (cas limite)
        -- -------------------------------------------------------
        count <= "0000"; max <= "0000";   -- count=0, max=0
        wait for 20 ns;

        assert complet = '1'
            report "[COMPARATEUR] ERREUR: complet devrait être 1 (max=0, parking plein par défaut)" severity ERROR;
        report "[COMPARATEUR] Test max=0 OK (complet='1')" severity NOTE;

        assert false report "=== Simulation tb_comparateur terminée avec succès ===" severity NOTE;
        wait;
    end process;

end Behavioral;
