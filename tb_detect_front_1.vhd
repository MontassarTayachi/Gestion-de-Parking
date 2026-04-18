-- ============================================================
-- Testbench : tb_detect_front_1
-- Valide le fonctionnement de la machine d'états detect_front_1 :
--   - Génère une impulsion (1 CLK) à chaque front montant de signal_in
--   - Le signal peut rester à '1' plusieurs cycles sans générer
--     d'impulsions supplémentaires
--   - Correspond aux signaux de la Figure 2 du document
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_detect_front_1 is
end tb_detect_front_1;

architecture Behavioral of tb_detect_front_1 is

    component detect_front_1 is
        Port (
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            signal_in : in  STD_LOGIC;
            pulse_out : out STD_LOGIC
        );
    end component;

    signal clk       : STD_LOGIC := '0';
    signal rst       : STD_LOGIC := '0';
    signal signal_in : STD_LOGIC := '0';
    signal pulse_out : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

begin

    UUT : detect_front_1
        port map (clk => clk, rst => rst,
                  signal_in => signal_in, pulse_out => pulse_out);

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
        wait for CLK_PERIOD;

        assert pulse_out = '0'
            report "[DETECT_FRONT_1] ERREUR: pulse_out devrait être 0 après reset" severity ERROR;
        report "[DETECT_FRONT_1] Reset OK" severity NOTE;

        -- -------------------------------------------------------
        -- Test 1 (Figure 2) : signal_in haut pendant 5 CLK
        --   → pulse_out = '1' pendant exactement 1 CLK, puis '0'
        -- -------------------------------------------------------
        wait until rising_edge(clk);
        wait for 2 ns;   -- légère attente après le front d'horloge
        signal_in <= '1';
        wait for 5 * CLK_PERIOD;    -- signal_in reste à '1' pendant 5 clocks

        signal_in <= '0';
        wait for 5 * CLK_PERIOD;    -- signal_in descend, on attend

        report "[DETECT_FRONT_1] Test 1 (front long) terminé - vérifier chronogramme" severity NOTE;

        -- -------------------------------------------------------
        -- Test 2 : signal_in haut pendant 2 CLK
        -- -------------------------------------------------------
        wait until rising_edge(clk);
        wait for 2 ns;
        signal_in <= '1';
        wait for 2 * CLK_PERIOD;
        signal_in <= '0';
        wait for 4 * CLK_PERIOD;

        report "[DETECT_FRONT_1] Test 2 (front court) terminé" severity NOTE;

        -- -------------------------------------------------------
        -- Test 3 : signal_in haut pendant très longtemps (10 CLK)
        -- -------------------------------------------------------
        wait until rising_edge(clk);
        wait for 2 ns;
        signal_in <= '1';
        wait for 10 * CLK_PERIOD;
        signal_in <= '0';
        wait for 4 * CLK_PERIOD;

        report "[DETECT_FRONT_1] Test 3 (front très long) terminé" severity NOTE;

        -- -------------------------------------------------------
        -- Test 4 : Deux fronts successifs
        -- -------------------------------------------------------
        wait until rising_edge(clk);
        wait for 2 ns;
        signal_in <= '1';
        wait for 3 * CLK_PERIOD;
        signal_in <= '0';
        wait for 3 * CLK_PERIOD;
        -- Second front
        signal_in <= '1';
        wait for 3 * CLK_PERIOD;
        signal_in <= '0';
        wait for 4 * CLK_PERIOD;

        report "[DETECT_FRONT_1] Test 4 (deux fronts successifs) terminé" severity NOTE;

        wait for 20 ns;
        assert false report "=== Simulation tb_detect_front_1 terminée ===" severity NOTE;
        wait;
    end process;

end Behavioral;
