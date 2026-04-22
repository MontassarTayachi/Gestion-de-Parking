library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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

    function hex_to_7seg(value : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case value is
            when "0000" => return "1000000";
            when "0001" => return "1111001";
            when "0010" => return "0100100";
            when "0011" => return "0110000";
            when "0100" => return "0011001";
            when "0101" => return "0010010";
            when "0110" => return "0000010";
            when "0111" => return "1111000";
            when "1000" => return "0000000";
            when "1001" => return "0010000";
            when "1010" => return "0001000";
            when "1011" => return "0000011";
            when "1100" => return "1000110";
            when "1101" => return "0100001";
            when "1110" => return "0000110";
            when others => return "0001110";
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

    seg <= hex_to_7seg(nb_places_dispos_int);
    an  <= "1110";
    dp  <= '1';

end Structural;