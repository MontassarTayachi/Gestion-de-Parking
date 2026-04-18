-- ============================================================
-- Composant : comparateur
-- Description : Compare la sortie du compteur (nombre de voitures présentes)
--               avec la capacité maximale du parking.
--   - complet = '1' si count >= max  (parking plein)
--   - complet = '0' sinon            (places disponibles)
--   Utilise une instruction concurrente conditionnelle (when/else).
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity comparateur is
    Port (
        count   : in  STD_LOGIC_VECTOR(3 downto 0);  -- Nombre de voitures dans le parking
        max     : in  STD_LOGIC_VECTOR(3 downto 0);  -- Capacité maximale du parking
        complet : out STD_LOGIC                       -- '1' si parking complet
    );
end comparateur;

architecture Behavioral of comparateur is
begin

    -- Instruction concurrente conditionnelle (when/else)
    complet <= '1' when (UNSIGNED(count) >= UNSIGNED(max)) else '0';

end Behavioral;
