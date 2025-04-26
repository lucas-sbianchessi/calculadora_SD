library IEEE;
use IEEE.std_logic_1164.all;

use work.display;

entity control is port(
  position: in std_logic_vector(3 downto 0); 
  digit:    in std_logic_vector(3 downto 0);    
  clock:    in std_logic;                      
  reset:    in std_logic;                    


  segments_out : out std_logic_vector(63 downto 0)
);
end control;

architecture controlx of control is

  signal display_digits : std_logic_vector(31 downto 0) := (others => '0'); 

  signal seg_out_d0 : std_logic_vector(7 downto 0);
  signal seg_out_d1 : std_logic_vector(7 downto 0);
  signal seg_out_d2 : std_logic_vector(7 downto 0);
  signal seg_out_d3 : std_logic_vector(7 downto 0);
  signal seg_out_d4 : std_logic_vector(7 downto 0);
  signal seg_out_d5 : std_logic_vector(7 downto 0); 
  signal seg_out_d6 : std_logic_vector(7 downto 0); 
  signal seg_out_d7 : std_logic_vector(7 downto 0); 

begin


  process(clock, reset)
  begin
    if reset = '1' then
      display_digits <= (others => '0');
    elsif rising_edge(clock) then

      case position is
        when b"0000" => -- Posição 0 (mais à direita)
          display_digits(3 downto 0) <= digit;
        when b"0001" => -- Posição 1
          display_digits(7 downto 4) <= digit;
        when b"0010" => -- Posição 2
          display_digits(11 downto 8) <= digit;
        when b"0011" => -- Posição 3
          display_digits(15 downto 12) <= digit;
        when b"0100" => -- Posição 4
          display_digits(19 downto 16) <= digit;
        when b"0101" => -- Posição 5
          display_digits(23 downto 20) <= digit;
        when b"0110" => -- Posição 6
          display_digits(27 downto 24) <= digit;
        when b"0111" => -- Posição 7 (mais à esquerda)
          display_digits(31 downto 28) <= digit;
        when others =>
          display_digits <= (others => '0');
      end case;
    end if;
  end process;

  -- Display na Posição 0 (mais à direita)
  d0: entity work.display
        port map(
            data => display_digits(3 downto 0),
            segments => seg_out_d0
        );

  -- Display na Posição 1
  d1: entity work.display
        port map(
            data => display_digits(7 downto 4),
            segments => seg_out_d1
        );

  -- Display na Posição 2
  d2: entity work.display
        port map(
            data => display_digits(11 downto 8),
            segments => seg_out_d2
        );

  -- Display na Posição 3
  d3: entity work.display
        port map(
            data => display_digits(15 downto 12),
            segments => seg_out_d3
        );

  -- Display na Posição 4
  d4: entity work.display
        port map(
            data => display_digits(19 downto 16),
            segments => seg_out_d4
        );

  -- Display na Posição 5
  d5: entity work.display
        port map(
            data => display_digits(23 downto 20),
            segments => seg_out_d5
        );

  -- Display na Posição 6
  d6: entity work.display
        port map(
            data => display_digits(27 downto 24),
            segments => seg_out_d6
        );

  -- Display na Posição 7 (mais à esquerda)
  d7: entity work.display
        port map(
            data => display_digits(31 downto 28),
            segments => seg_out_d7
        );

  segments_out <= seg_out_d7 & seg_out_d6 & seg_out_d5 & seg_out_d4 & seg_out_d3 & seg_out_d2 & seg_out_d1 & seg_out_d0;

end architecture controlx;