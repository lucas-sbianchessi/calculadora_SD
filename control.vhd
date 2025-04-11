library IEEE; 
use IEEE.std_logic_1164.all;


entity control is port(
  position: in std_logic_vector(3 downto 0);
  digit:    in std_logic_vector(3 downto 0);
  clock:    in std_logic;
  reset:    in std_logic
);
end control;

architecture controlx of control is 
  signal data : std_logic_vector(31 downto 0) := (others => '0'); -- 8 x 4 = 32
begin


  d0: entity work.display
        port map(data => data(3 downto 0));
  d1: entity work.display
        port map(data => data(7 downto 4));
  d2: entity work.display
        port map(data => data(11 downto 8));
  d3: entity work.display
        port map(data => data(15 downto 12));
  d4: entity work.display
        port map(data => data(19 downto 16));
  d5: entity work.display
        port map(data => data(23 downto 20));
  d6: entity work.display
        port map(data => data(27 downto 24));
  d7: entity work.display
        port map(data => data(31 downto 28));


  process(clock, reset)
  begin

		if reset = '1' then
      data <= (others => '0');
		elsif rising_edge(clock) then
      case position is
        when b"0000" =>
          data(03 downto 00) <= digit;
        when b"0001" =>
          data(07 downto 04) <= digit;
        when b"0010" =>
          data(11 downto 08) <= digit;
        when b"0011" =>
          data(15 downto 12) <= digit;
        when b"0100" =>
          data(19 downto 16) <= digit;
        when b"0101" =>
          data(23 downto 20) <= digit;
        when b"0110" =>
          data(27 downto 24) <= digit;
        when b"0111" =>
          data(31 downto 28) <= digit;
        when others => 
          data(31 downto 0) <= (others => '0');
      end case;

		end if;
  end process;

end architecture controlx;
