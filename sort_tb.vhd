----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2019 05:01:46 PM
-- Design Name: 
-- Module Name: sort_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sort_tb is
--  Port ( );
end sort_tb;

architecture Behavioral of sort_tb is
signal clk, reset, oled_sdin, oled_sclk, oled_dc, oled_res, oled_vbat, oled_vdd, start: std_logic;
begin
    uut: entity work.sort(Behavioral)
    port map(
             clk => clk,
             reset => reset,
             oled_sdin => oled_sdin,
             oled_sclk => oled_sclk,
             oled_dc => oled_dc,
             oled_res => oled_res,
             oled_vbat => oled_vbat,
             oled_vdd => oled_vdd,
             start => start
             );
    process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10ns;
    end process;
    
    process begin
        reset <= '1';
        start <= '0';
        wait for 200ns;
        reset <= '0';
        wait for 200ns;
        start <= '1';
        wait;
    end process;

end Behavioral;
