-----------------------------------------
-- Biblioteca
-----------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-----------------------------------------
-- Entidade
-----------------------------------------
entity tb is 
end entity;

-----------------------------------------
-- Arquitetura
-----------------------------------------
architecture tb of tb is
  signal position: std_logic_vector(3 downto 0) := "0000";
  signal digit:    std_logic_vector(3 downto 0) := "0000";
  signal count:    std_logic_vector(2 downto 0) := "000";
  signal clock:    std_logic;
  signal reset:    std_logic;
begin
 
  --clock

  process(clock)
  begin 
    if rising_edge(clock) then
      digit <= std_logic_vector(unsigned(digit) + "0001");
      count <= std_logic_vector(unsigned(count) + "001");
      if count = "001" then 
        count    <= std_logic_vector(unsigned(count) + "000");
        digit    <= "0000";
        position <= std_logic_vector(unsigned(position) + 1);
      end if;
    end if;

  end process;


  DUT: entity work.control
        port map(position => position, digit => digit, clock <= clock, reset <= reset); 
 
end architecture tb;
