-- ============================================================
-- Testbench : tb_compteur
-- Valide le fonctionnement du composant compteur 4 bits :
--   - Reset asynchrone
--   - Comptage (up)
--   - Décomptage (down)
--   - Protection dépassement (> 15 et < 0)
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_compteur is
end tb_compteur;

architecture Behavioral of tb_compteur is

    component compteur is
        Port (
            clk   : in  STD_LOGIC;
            rst   : in  STD_LOGIC;
            up    : in  STD_LOGIC;
            down  : in  STD_LOGIC;
            count : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    signal clk   : STD_LOGIC := '0';
    signal rst   : STD_LOGIC := '0';
    signal up    : STD_LOGIC := '0';
    signal down  : STD_LOGIC := '0';
    signal count : STD_LOGIC_VECTOR(3 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    UUT : compteur
        port map (clk => clk, rst => rst, up => up, down => down, count => count);

    -- Génération de l'horloge
    clk_proc : process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    stim_proc : process
    begin
        -- -------------------------------------------------------
        -- Test 1 : Reset asynchrone
        -- -------------------------------------------------------
        rst <= '1';
        wait for 25 ns;
        rst <= '0';
        wait for CLK_PERIOD;

        assert count = "0000"
            report "[COMPTEUR] ERREUR: count devrait être 0 après reset, valeur = " &
                   integer'image(to_integer(UNSIGNED(count)))
            severity ERROR;
        report "[COMPTEUR] Test reset OK (count = 0)" severity NOTE;

        -- -------------------------------------------------------
        -- Test 2 : Comptage +5
        -- -------------------------------------------------------
        for i in 1 to 5 loop
            up <= '1';
            wait for CLK_PERIOD;
            up <= '0';
            wait for CLK_PERIOD;
        end loop;

        assert UNSIGNED(count) = 5
            report "[COMPTEUR] ERREUR: count devrait être 5, valeur = " &
                   integer'image(to_integer(UNSIGNED(count)))
            severity ERROR;
        report "[COMPTEUR] Test comptage +5 OK (count = " &
               integer'image(to_integer(UNSIGNED(count))) & ")" severity NOTE;

        -- -------------------------------------------------------
        -- Test 3 : Décomptage -2
        -- -------------------------------------------------------
        for i in 1 to 2 loop
            down <= '1';
            wait for CLK_PERIOD;
            down <= '0';
            wait for CLK_PERIOD;
        end loop;

        assert UNSIGNED(count) = 3
            report "[COMPTEUR] ERREUR: count devrait être 3, valeur = " &
                   integer'image(to_integer(UNSIGNED(count)))
            severity ERROR;
        report "[COMPTEUR] Test décomptage -2 OK (count = " &
               integer'image(to_integer(UNSIGNED(count))) & ")" severity NOTE;

        -- -------------------------------------------------------
        -- Test 4 : Reset asynchrone après comptage
        -- -------------------------------------------------------
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;

        assert count = "0000"
            report "[COMPTEUR] ERREUR: count devrait être 0 après reset" severity ERROR;
        report "[COMPTEUR] Test reset #2 OK (count = 0)" severity NOTE;

        -- -------------------------------------------------------
        -- Test 5 : Protection underflow (count = 0, décrémenter)
        -- -------------------------------------------------------
        down <= '1';
        wait for CLK_PERIOD;
        down <= '0';
        wait for CLK_PERIOD;

        assert count = "0000"
            report "[COMPTEUR] ERREUR: count ne doit pas passer en dessous de 0" severity ERROR;
        report "[COMPTEUR] Test protection underflow OK (count = 0)" severity NOTE;

        -- -------------------------------------------------------
        -- Test 6 : Protection overflow (count = 15, incrémenter)
        -- -------------------------------------------------------
        -- Monter jusqu'à 15
        for i in 1 to 15 loop
            up <= '1';
            wait for CLK_PERIOD;
            up <= '0';
            wait for CLK_PERIOD;
        end loop;

        assert UNSIGNED(count) = 15
            report "[COMPTEUR] ERREUR: count devrait être 15" severity ERROR;

        -- Essayer d'aller au-delà de 15
        up <= '1';
        wait for CLK_PERIOD;
        up <= '0';
        wait for CLK_PERIOD;

        assert UNSIGNED(count) = 15
            report "[COMPTEUR] ERREUR: count ne doit pas dépasser 15" severity ERROR;
        report "[COMPTEUR] Test protection overflow OK (count = 15)" severity NOTE;

        wait for 50 ns;
        assert false report "=== Simulation tb_compteur terminée avec succès ===" severity NOTE;
        wait;
    end process;

end Behavioral;
