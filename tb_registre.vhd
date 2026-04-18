-- ============================================================
-- Testbench : tb_registre
-- Valide le fonctionnement du composant registre :
--   - Chargement d'une valeur avec load='1'
--   - Stabilité sans load
--   - Messages assert/report selon severity
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_registre is
end tb_registre;

architecture Behavioral of tb_registre is

    component registre is
        Port (
            clk      : in  STD_LOGIC;
            rst      : in  STD_LOGIC;
            load     : in  STD_LOGIC;
            data_in  : in  STD_LOGIC_VECTOR(3 downto 0);
            data_out : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    signal clk      : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '0';
    signal load     : STD_LOGIC := '0';
    signal data_in  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal data_out : STD_LOGIC_VECTOR(3 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    UUT : registre
        port map (clk => clk, rst => rst, load => load,
                  data_in => data_in, data_out => data_out);

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

        assert data_out = "0000"
            report "[REGISTRE] ERREUR: data_out devrait être 0 après reset" severity ERROR;
        report "[REGISTRE] Reset OK (data_out = 0)" severity NOTE;

        -- -------------------------------------------------------
        -- Test 1 : Chargement capacité max = 10 (1010)
        --          → severity NOTE attendu dans le simulateur
        -- -------------------------------------------------------
        data_in <= "1010";   -- 10 places
        load    <= '1';
        wait for CLK_PERIOD;
        load    <= '0';
        wait for CLK_PERIOD;

        assert data_out = "1010"
            report "[REGISTRE] ERREUR: data_out devrait être 10 (1010), valeur = " &
                   integer'image(to_integer(UNSIGNED(data_out)))
            severity ERROR;
        report "[REGISTRE] Test chargement 10 OK (data_out = " &
               integer'image(to_integer(UNSIGNED(data_out))) & ")" severity NOTE;

        -- -------------------------------------------------------
        -- Test 2 : Stabilité sans load (data_in change mais load='0')
        -- -------------------------------------------------------
        data_in <= "1111";   -- Changement de data_in sans load
        wait for 3 * CLK_PERIOD;

        assert data_out = "1010"
            report "[REGISTRE] ERREUR: data_out ne doit pas changer sans load" severity ERROR;
        report "[REGISTRE] Test stabilité OK (data_out reste 10)" severity NOTE;

        -- -------------------------------------------------------
        -- Test 3 : Chargement valeur 0
        --          → severity WARNING attendu dans le simulateur
        -- -------------------------------------------------------
        data_in <= "0000";
        load    <= '1';
        wait for CLK_PERIOD;
        load    <= '0';
        wait for CLK_PERIOD;

        assert data_out = "0000"
            report "[REGISTRE] ERREUR: data_out devrait être 0" severity ERROR;
        report "[REGISTRE] Test chargement 0 OK (WARNING généré attendu ci-dessus)" severity NOTE;

        -- -------------------------------------------------------
        -- Test 4 : Chargement nouvelle capacité = 8 (1000)
        -- -------------------------------------------------------
        data_in <= "1000";   -- 8 places
        load    <= '1';
        wait for CLK_PERIOD;
        load    <= '0';
        wait for CLK_PERIOD;

        assert UNSIGNED(data_out) = 8
            report "[REGISTRE] ERREUR: data_out devrait être 8, valeur = " &
                   integer'image(to_integer(UNSIGNED(data_out)))
            severity ERROR;
        report "[REGISTRE] Test chargement 8 OK" severity NOTE;

        wait for 50 ns;
        assert false report "=== Simulation tb_registre terminée avec succès ===" severity NOTE;
        wait;
    end process;

end Behavioral;
