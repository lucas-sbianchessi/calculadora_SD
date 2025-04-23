-----------------------------------------
-- Biblioteca
-----------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-----------------------------------------
-- Entidade
-----------------------------------------
entity tb_digit is 
end entity;

-----------------------------------------
-- Arquitetura
-----------------------------------------
architecture tb_digit of tb_digit is
  signal data     : std_logic_vector(3 downto 0) := "0000";
  signal segments : std_logic_vector(7 downto 0);
begin
 
  data <= "0001" after  10 ns, "0010" after  20 ns, "0011" after  30 ns,
          "0100" after  40 ns, "0101" after  50 ns, "0110" after  60 ns,
          "0111" after  70 ns, "1000" after  80 ns, "1001" after  90 ns,
          "1010" after 100 ns, "1011" after 110 ns, "1100" after 120 ns,
          "1101" after 130 ns, "1110" after 140 ns, "1111" after 150 ns;

  DUT: entity work.display
        port map(data => data, segments => segments); 
 
end architecture tb_digit;
