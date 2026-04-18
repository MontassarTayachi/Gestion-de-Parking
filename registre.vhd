-- ============================================================
-- Composant : registre
-- Description : Registre 4 bits pour stocker la capacité maximale du parking.
--   - load = '1' --> chargement de data_in dans le registre (sur front montant clk)
--   - Utilise assert/report pour valider les données chargées
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity registre is
    Port (
        clk      : in  STD_LOGIC;                        -- Horloge
        rst      : in  STD_LOGIC;                        -- Reset asynchrone actif haut
        load     : in  STD_LOGIC;                        -- Signal de chargement
        data_in  : in  STD_LOGIC_VECTOR(3 downto 0);    -- Données en entrée (capacité max)
        data_out : out STD_LOGIC_VECTOR(3 downto 0)     -- Données en sortie
    );
end registre;

architecture Behavioral of registre is
    signal reg : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
begin

    process(clk, rst)
    begin
        if rst = '1' then
            reg <= (others => '0');

        elsif rising_edge(clk) then
            if load = '1' then
                reg <= data_in;

                -- -------------------------------------------------------
                -- Validation avec assert/report (severity NOTE)
                -- Indique seulement dans le simulateur, ne bloque pas.
                -- -------------------------------------------------------
                assert (UNSIGNED(data_in) > 0)
                    report "[REGISTRE - WARNING] La capacité maximale du parking est 0 ! " &
                           "Veuillez charger une valeur strictement positive."
                    severity WARNING;

                -- -------------------------------------------------------
                -- Validation avec assert/report (severity NOTE)
                -- Simple information dans le journal du simulateur.
                -- -------------------------------------------------------
                assert not (UNSIGNED(data_in) > 0)
                    report "[REGISTRE - NOTE] Capacité maximale chargée : " &
                           integer'image(to_integer(UNSIGNED(data_in))) & " places."
                    severity NOTE;

                -- -------------------------------------------------------
                -- Validation avec assert/report (severity ERROR)
                -- La valeur 15 (1111) est la valeur max sur 4 bits.
                -- Si on dépasse, c'est une erreur de configuration.
                -- -------------------------------------------------------
                assert (UNSIGNED(data_in) <= 15)
                    report "[REGISTRE - ERROR] La capacité maximale ne peut pas dépasser 15 places (4 bits)."
                    severity ERROR;

            end if;
        end if;
    end process;

    -- Sortie permanente du registre
    data_out <= reg;

end Behavioral;

-- ============================================================
-- NOTE sur les niveaux de severity :
--
--  NOTE    : Information simple, le simulateur continue normalement.
--  WARNING : Avertissement, le simulateur continue normalement.
--  ERROR   : Erreur signalée, selon le simulateur peut continuer
--            ou s'arrêter (comportement outil-dépendant).
--  FAILURE : Erreur fatale, le simulateur s'arrête immédiatement.
-- ============================================================
