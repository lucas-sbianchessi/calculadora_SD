library IEEE;
use IEEE.std_logic_1164.all;

entity display is port(
    data:     in  std_logic_vector(3 downto 0);
    segments: out std_logic_vector(7 downto 0)
    );
end entity;

architecture display of display is
begin

  segments <= "11111100" when data = "0000" else -- 0
              "01100000" when data = "0001" else -- 1
              "11011010" when data = "0010" else -- 2
              "11110010" when data = "0011" else -- 3
              "01100110" when data = "0100" else -- 4
              "10110110" when data = "0101" else -- 5
              "10111110" when data = "0110" else -- 6
              "11100000" when data = "0111" else -- 7
              "11111110" when data = "1000" else -- 8
              "11100110" when data = "1001" else -- 9
              "00000000";

end architecture display;