----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2019 09:27:09 PM
-- Design Name: 
-- Module Name: sort - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity sort is
  Port 
  (
    clk: in std_logic;
    reset: in std_logic; --center button
    
    --onboard OLED display
    oled_sdin   : out std_logic;
    oled_sclk   : out std_logic;
    oled_dc     : out std_logic;
    oled_res    : out std_logic;
    oled_vbat   : out std_logic;
    oled_vdd    : out std_logic;
    
    start: in std_logic --up button
  );
end sort;


architecture Behavioral of sort is
type ram_type is array (0 to 15) of integer;
signal ram: ram_type;

shared variable A, B: integer range 0 to 255;
shared variable k: integer range 0 to 16:= 16;
signal i: integer := 0;
shared variable addr: integer;

type state_type is (s0, s1, s2, s3, done, dxfer, displayed, final);
signal state: state_type;

signal go, ready, valid, refresh: std_logic; --go for starting the oled display
signal din : std_logic_vector (7 downto 0);

type oled_row is array(0 to 15) of std_logic_vector(7 downto 0);
type oled_page is array (0 to 3) of oled_row;
        
signal oled_screen : oled_page := ( 
                                         (x"40", x"41", x"42",  x"43", x"44", x"45", x"46",x"47", x"48", x"49", x"4A", x"4B", x"4C", x"4D", x"4E", x"4F"),
                                         (x"40", x"41", x"42",  x"43", x"44", x"45", x"46",x"47", x"48", x"49", x"4A", x"4B", x"4C", x"4D", x"4E", x"4F"),
                                         (x"40", x"41", x"42",  x"43", x"44", x"45", x"46",x"47", x"48", x"49", x"4A", x"4B", x"4C", x"4D", x"4E", x"4F"),
                                         (x"40", x"41", x"42",  x"43", x"44", x"45", x"46",x"47", x"48", x"49", x"4A", x"4B", x"4C", x"4D", x"4E", x"4F")
                                         );
                                         

      shared variable row, position, temp, Z: integer := 0;
      shared variable tens, ones: integer;

begin
    
        
    
    oled: entity work.oled_ctrl(behavioral)
        port map (  clk =>clk,
                    rst => reset,
                    oled_sdin => oled_sdin,
                    oled_sclk => oled_sclk,
                    oled_dc => oled_dc,
                    oled_res => oled_res,
                    oled_vbat => oled_vbat,
                    oled_vdd => oled_vdd,
                    start => go,
                    ready => ready,
                    din => din,
                    valid => valid,
                    refresh => refresh
                    
                  );
    
    process(clk, i)
    variable j: integer;
    variable x: integer := 0; --increment for entry into datascreen array
    begin
    
        if rising_edge(clk) then
            if (reset = '1') then
                ram <= (0, 5, 2, 6, 70, 15, 204, 54, 87, 99,
                        9, 55, 77, 44, 0, 11);
                state <= s0;
                valid<= '0';
                Z := 0;
                row := 0;
            else
               case state is
                when s0 => 

                    if(start = '1') then
                        go <= '1';
                        state <= s1;
                        i <= 0;
                    end if;
                when s1 =>
                    if (i < (k-1)) then
                        addr := i;
                        A := ram(addr);
                        j := i+1;
                        state <= s2;
                    elsif ( not (i < (k-1))) then
                        state <= done;
                    end if;
                when s2=>
                    if(j < k) then
                        addr := j;
                        B := ram(addr);
                        state <= s3;
                    elsif (not (j < k)) then
                        i <= i+ 1;
                        state <= s1;
            end if;
        when s3=>
            if (A > B) then
                addr  := i;
                ram(addr) <= B;
                addr := j;
                ram(addr) <= A;
                A := B;
                j := j + 1;
            elsif (not(A>B)) then
                j := j+1;
            end if;
            state <= s2;
        when done =>
            
            if (Z <= 15 and row < 4) then --for a in 0 to 15 loop --added ready condition
                --state <= dxfer;
                case (position mod 4) is
                    when 0 =>
                        temp := (ram(Z) / 100) + 48;
                        oled_screen(row)(position) <= std_logic_vector(to_unsigned(temp, 8));
                        tens := ram(Z) mod 100;
                        temp := (tens / 10)+48;
                        position := position + 1;
                    when 1=>
                        oled_screen(row)(position) <= std_logic_vector(to_unsigned(temp, 8));
                        ones := (tens mod 10)+48;
                        position := position + 1;
                    when 2=>
                        oled_screen(row)(position) <= std_logic_vector(to_unsigned(ones, 8));
                        position := position + 1;
                    when others=>
                        oled_screen(row)(position) <= x"20";
                        Z := Z + 1;
                        if(position = 15) then
                            if(row = 3) then
                                state <= dxfer;
                                go <= '1';
                                position := 0;
                                row := 0;
                            else
                                position := 0;
                                row := row + 1;
                            end if;
                        else
                            position := position + 1;
                        end if;
                end case;
                
             end if;
            when dxfer =>
                if (ready = '1') then
                    --din <= oled_screen(row)(position);
                    --valid <= '1';
                    if(position = 15) then
                        if(row = 3) then
                            state <= displayed;
                            din <= oled_screen(row)(position);
                            valid <= '1';
                        else 
                            din <= oled_screen(row)(position);
                            valid <= '1';
                            row := row + 1;
                            position := 0;
                        end if;
                    else 
                        din <= oled_screen(row)(position);
                        valid <= '1';
                        position := position + 1;
                    end if;
                else valid  <= '0';
                end if;
            when displayed =>
                refresh <= '1';
                valid <= '0'; --might need to change
                state <= final;
            when final =>
                valid <= '0';
                refresh <= '0';
         end case;

     end if;
    end if;
        
        
     
end process;



end Behavioral;
