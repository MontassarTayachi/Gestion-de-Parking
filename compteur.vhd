-- ============================================================
-- Composant : compteur
-- Description : Compteur/Décompteur 4 bits avec reset asynchrone
--   - up   = '1' --> incrémentation (comptage)
--   - down = '1' --> décrémentation (décomptage)
--   - reset asynchrone actif haut
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity compteur is
    Port (
        clk   : in  STD_LOGIC;                        -- Horloge
        rst   : in  STD_LOGIC;                        -- Reset asynchrone actif haut
        up    : in  STD_LOGIC;                        -- Incrémentation
        down  : in  STD_LOGIC;                        -- Décrémentation
        count : out STD_LOGIC_VECTOR(3 downto 0)     -- Valeur de comptage (4 bits)
    );
end compteur;

architecture Behavioral of compteur is
    signal count_reg : UNSIGNED(3 downto 0) := (others => '0');
begin

    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset asynchrone : remise à zéro immédiate
            count_reg <= (others => '0');

        elsif rising_edge(clk) then
            if up = '1' and down = '0' then
                -- Comptage avec protection contre le dépassement max (15)
                if count_reg < 15 then
                    count_reg <= count_reg + 1;
                end if;

            elsif down = '1' and up = '0' then
                -- Décomptage avec protection contre le passage en négatif
                if count_reg > 0 then
                    count_reg <= count_reg - 1;
                end if;
            end if;
        end if;
    end process;

    count <= STD_LOGIC_VECTOR(count_reg);

end Behavioral;
