-- ============================================================
-- Composant : detect_front_1
-- Description : Détecteur de front montant basé sur une machine d'états (FSM).
--   Le capteur peut rester à '1' pendant plusieurs coups d'horloge.
--   Ce composant génère une impulsion (pulse_out = '1') d'une seule
--   période d'horloge à chaque front montant détecté sur signal_in.
--
-- Diagramme d'états :
--
--   ┌──────────────┐  signal_in='1'  ┌──────────────┐
--   │  S0_IDLE     │ ─────────────── │  S1_PULSE    │
--   │  out = '0'   │                 │  out = '1'   │
--   └──────────────┘                 └──────────────┘
--         ↑                                 │
--         │ signal_in='0'                   │ (toujours)
--         │                                 ↓
--         │                          ┌──────────────┐
--         └──────────────────────────│  S2_WAIT     │
--           signal_in='0'            │  out = '0'   │
--                                    └──────────────┘
--
-- Chronogramme attendu (Figure 2 du document) :
--   clk        : __|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_...
--   signal_in  : _____|‾‾‾‾‾‾‾‾‾‾‾‾‾|_________
--   pulse_out  : _________|‾|___________________
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity detect_front_1 is
    Port (
        clk       : in  STD_LOGIC;   -- Horloge système
        rst       : in  STD_LOGIC;   -- Reset asynchrone actif haut
        signal_in : in  STD_LOGIC;   -- Signal d'entrée (capteur)
        pulse_out : out STD_LOGIC    -- Impulsion d'une période d'horloge
    );
end detect_front_1;

architecture Behavioral of detect_front_1 is

    -- Définition des états de la machine d'états
    type state_type is (
        S0_IDLE,   -- Attente d'un front montant (signal_in = '0')
        S1_PULSE,  -- Front montant détecté → sortie = '1' pendant 1 CLK
        S2_WAIT    -- Attente de la redescente du signal (signal_in = '0')
    );

    signal state : state_type := S0_IDLE;

begin

    -- -------------------------------------------------------
    -- Partie séquentielle : transitions d'états
    -- -------------------------------------------------------
    process(clk, rst)
    begin
        if rst = '1' then
            state <= S0_IDLE;

        elsif rising_edge(clk) then
            case state is

                -- État IDLE : on attend un front montant
                when S0_IDLE =>
                    if signal_in = '1' then
                        state <= S1_PULSE;   -- Front montant détecté !
                    else
                        state <= S0_IDLE;    -- Pas de front, on attend
                    end if;

                -- État PULSE : sortie à '1' pendant une seule période
                when S1_PULSE =>
                    state <= S2_WAIT;        -- On passe immédiatement en attente

                -- État WAIT : attente que le signal redescende à '0'
                when S2_WAIT =>
                    if signal_in = '0' then
                        state <= S0_IDLE;    -- Signal redescendu → prêt pour nouveau front
                    else
                        state <= S2_WAIT;    -- Signal encore haut, on continue d'attendre
                    end if;

            end case;
        end if;
    end process;

    -- -------------------------------------------------------
    -- Partie combinatoire : calcul de la sortie
    -- pulse_out = '1' uniquement dans l'état S1_PULSE
    -- -------------------------------------------------------
    pulse_out <= '1' when (state = S1_PULSE) else '0';

end Behavioral;
