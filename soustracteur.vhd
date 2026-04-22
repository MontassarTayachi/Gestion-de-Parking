-- ============================================================
-- Composant : soustracteur
-- Description : Calcule le nombre de places disponibles dans le parking.
--   nb_places_dispos = max - count
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity soustracteur is
    Port (
        max              : in  STD_LOGIC_VECTOR(3 downto 0);  -- Capacité max du parking
        count            : in  STD_LOGIC_VECTOR(3 downto 0);  -- Nombre de voitures présentes
        nb_places_dispos : out STD_LOGIC_VECTOR(3 downto 0)   -- Nombre de places disponibles
    );
end soustracteur;

architecture Behavioral of soustracteur is
begin

    -- Soustraction combinatoire : places disponibles = capacité max - voitures présentes
    nb_places_dispos <= STD_LOGIC_VECTOR(UNSIGNED(max) - UNSIGNED(count));

end Behavioral;
