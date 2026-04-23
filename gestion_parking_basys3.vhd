library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gestion_parking_basys3 is
    Port (
        clk100mhz  : in  STD_LOGIC;
        btnC       : in  STD_LOGIC;
        btnL       : in  STD_LOGIC;
        btnR       : in  STD_LOGIC;
        btnD       : in  STD_LOGIC;
        sw         : in  STD_LOGIC_VECTOR(3 downto 0);
        seg        : out STD_LOGIC_VECTOR(6 downto 0);
        an         : out STD_LOGIC_VECTOR(3 downto 0);
        dp         : out STD_LOGIC;
        led_complet: out STD_LOGIC
    );
end gestion_parking_basys3;

architecture Structural of gestion_parking_basys3 is

    component gestion_parking is
        Port (
            clk              : in  STD_LOGIC;
            rst              : in  STD_LOGIC;
            capt_entree      : in  STD_LOGIC;
            capt_sortie      : in  STD_LOGIC;
            load_max         : in  STD_LOGIC;
            max_places_in    : in  STD_LOGIC_VECTOR(3 downto 0);
            nb_places_dispos : out STD_LOGIC_VECTOR(3 downto 0);
            complet          : out STD_LOGIC
        );
    end component;

    signal nb_places_dispos_int : STD_LOGIC_VECTOR(3 downto 0);
    signal refresh_counter      : UNSIGNED(16 downto 0) := (others => '0');
    signal digit_sel            : STD_LOGIC;
    signal tens_digit           : STD_LOGIC_VECTOR(3 downto 0);
    signal units_digit          : STD_LOGIC_VECTOR(3 downto 0);

    -- Segments actifs bas : "1111111" = éteint
    function dec_to_7seg(value : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case value is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when others => return "1111111"; -- éteint
        end case;
    end function;

begin

    U_GESTION_PARKING : gestion_parking
        port map (
            clk              => clk100mhz,
            rst              => btnC,
            capt_entree      => btnR,
            capt_sortie      => btnD,
            load_max         => btnL,
            max_places_in    => sw,
            nb_places_dispos => nb_places_dispos_int,
            complet          => led_complet
        );

    -- Diviseur d'horloge : ~760 Hz de rafraîchissement par digit
    process(clk100mhz)
    begin
        if rising_edge(clk100mhz) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;

    digit_sel <= refresh_counter(16);

    -- Décomposition décimale : valeurs 0-9 → unité seule ; 10-15 → dizaine=1, unité=valeur-10
    process(nb_places_dispos_int)
    begin
        case nb_places_dispos_int is
            when "1010" => tens_digit <= "0001"; units_digit <= "0000"; -- 10
            when "1011" => tens_digit <= "0001"; units_digit <= "0001"; -- 11
            when "1100" => tens_digit <= "0001"; units_digit <= "0010"; -- 12
            when "1101" => tens_digit <= "0001"; units_digit <= "0011"; -- 13
            when "1110" => tens_digit <= "0001"; units_digit <= "0100"; -- 14
            when "1111" => tens_digit <= "0001"; units_digit <= "0101"; -- 15
            when others => tens_digit <= "1111"; units_digit <= nb_places_dispos_int; -- 0-9
        end case;
    end process;

    -- Multiplexage 7 segments : AN0 = unités, AN1 = dizaines
    process(digit_sel, tens_digit, units_digit)
    begin
        if digit_sel = '0' then
            seg <= dec_to_7seg(units_digit);
            an  <= "1110"; -- AN0 actif
        else
            seg <= dec_to_7seg(tens_digit); -- "1111" => éteint pour 0-9
            an  <= "1101"; -- AN1 actif
        end if;
    end process;

    dp <= '1';

end Structural;