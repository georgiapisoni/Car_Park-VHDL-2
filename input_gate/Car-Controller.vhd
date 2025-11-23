library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Parking_Controller is
    generic (
        PARKING_CAPACITY : integer := 7
    );
    port (
        -- Clock and Reset
        clk : in std_logic;
        nrst : in std_logic;
        
        -- Entry Gate 1 Sensors
        sensor_A_Gin1 : in std_logic; -- Before barrier
        sensor_B_Gin1 : in std_logic; -- After barrier
        
        -- Entry Gate 2 Sensors
        sensor_A_Gin2 : in std_logic;
        sensor_B_Gin2 : in std_logic;
        
        -- Exit Gate 1 Sensors
        sensor_A_Gout1 : in std_logic;
        sensor_B_Gout1 : in std_logic;

        -- Exit Gate 2 Sensors
        sensor_A_Gout2 : in std_logic;
        sensor_B_Gout2 : in std_logic;

        -- Payment Interface
        payment_done : in std_logic;
        payment_accepted : out std_logic;
        payment_request : out std_logic;

        -- Barrier Controls
        barrier_Gin1 : out std_logic; -- '1' = open
        barrier_Gin2 : out std_logic;
        barrier_Gout1 : out std_logic;
        barrier_Gout2 : out std_logic;
        
        -- Visual Indicators
        Green_Light : out std_logic;
        Red_Light : out std_logic;
        display : out std_logic_vector(6 downto 0)
    );
end entity;

architecture Behavioural of Parking_Controller is

    -- Component declarations
    component Gate_In is 
        generic (
            PARKING_CAPACITY : integer := 7
        );
        port (
            clk              : in std_logic;
            nrst             : in std_logic;
            sensor_A         : in std_logic;
            sensor_B         : in std_logic;
            can_enter        : in std_logic;
            barrier          : out std_logic;
            inc_car          : out std_logic;
            gate_green_light : out std_logic;
            gate_red_light   : out std_logic
        );
    end component;

    component Gate_Out is 
        generic (
            PARKING_CAPACITY : integer := 7
        );
        port (
            clk              : in std_logic;
            nrst             : in std_logic;
            sensor_A         : in std_logic;
            sensor_B         : in std_logic;
            payment_done     : in std_logic;
            can_exit         : in std_logic;
            barrier          : out std_logic;
            dec_car          : out std_logic;
            payment_request  : out std_logic;
            payment_accepted : out std_logic
        );
    end component;

    -- Internal signals
    signal car_count : integer range 0 to PARKING_CAPACITY := 0;
    
    -- Gate control signals
    signal can_enter_Gin1, can_enter_Gin2 : std_logic;
    signal can_exit_Gout1, can_exit_Gout2 : std_logic;
    
    -- Car count signals
    signal inc_car_Gin1, inc_car_Gin2 : std_logic;
    signal dec_car_Gout1, dec_car_Gout2 : std_logic;
    
    -- Payment signals
    signal payment_request_Gout1, payment_request_Gout2 : std_logic;
    signal payment_accepted_Gout1, payment_accepted_Gout2 : std_logic;
    
    -- Gate lighting signals (individual gate lights if needed)
    signal gate_green_light_Gin1, gate_red_light_Gin1 : std_logic;
    signal gate_green_light_Gin2, gate_red_light_Gin2 : std_logic;

    -- 7-segment display function
    function int_to_7seg(value : integer) return std_logic_vector is
        variable result : std_logic_vector(6 downto 0);
    begin
        case value is
            when 0 => result := "0000001"; -- Display '0'
            when 1 => result := "1001111"; -- Display '1'
            when 2 => result := "0010010"; -- Display '2'
            when 3 => result := "0000110"; -- Display '3'
            when 4 => result := "1001100"; -- Display '4'
            when 5 => result := "0100100"; -- Display '5'
            when 6 => result := "0100000"; -- Display '6'
            when 7 => result := "0001111"; -- Display '7'
            when others => result := "1111111"; -- Error (all off)
        end case;
        return result;
    end function;

begin

    -- Gate instantiation
    U_GIN1: Gate_In
        generic map (PARKING_CAPACITY => PARKING_CAPACITY)
        port map (
            clk => clk,
            nrst => nrst,
            sensor_A => sensor_A_Gin1,
            sensor_B => sensor_B_Gin1,
            can_enter => can_enter_Gin1,
            barrier => barrier_Gin1,
            inc_car => inc_car_Gin1,
            gate_green_light => gate_green_light_Gin1,
            gate_red_light => gate_red_light_Gin1
        );

    U_GIN2: Gate_In
        generic map (PARKING_CAPACITY => PARKING_CAPACITY)
        port map (
            clk => clk,
            nrst => nrst,
            sensor_A => sensor_A_Gin2,
            sensor_B => sensor_B_Gin2,
            can_enter => can_enter_Gin2,
            barrier => barrier_Gin2,
            inc_car => inc_car_Gin2,
            gate_green_light => gate_green_light_Gin2,
            gate_red_light => gate_red_light_Gin2
        );

    U_GOUT1: Gate_Out
        generic map (PARKING_CAPACITY => PARKING_CAPACITY)
        port map (
            clk => clk,
            nrst => nrst,
            sensor_A => sensor_A_Gout1,
            sensor_B => sensor_B_Gout1,
            payment_done => payment_done,
            can_exit => can_exit_Gout1,
            barrier => barrier_Gout1,
            dec_car => dec_car_Gout1,
            payment_request => payment_request_Gout1,
            payment_accepted => payment_accepted_Gout1
        );

    U_GOUT2: Gate_Out
        generic map (PARKING_CAPACITY => PARKING_CAPACITY)
        port map (
            clk => clk,
            nrst => nrst,
            sensor_A => sensor_A_Gout2,
            sensor_B => sensor_B_Gout2,
            payment_done => payment_done,
            can_exit => can_exit_Gout2,
            barrier => barrier_Gout2,
            dec_car => dec_car_Gout2,
            payment_request => payment_request_Gout2,
            payment_accepted => payment_accepted_Gout2
        );

    -- Car counter management with priority for Gate 1
    counter_process: process(clk, nrst)
    begin
        if nrst = '0' then
            car_count <= 0;
        elsif rising_edge(clk) then
            -- Handle increments with priority for Gate 1
            if inc_car_Gin1 = '1' and car_count < PARKING_CAPACITY then
                car_count <= car_count + 1;
            elsif inc_car_Gin2 = '1' and car_count < PARKING_CAPACITY then
                car_count <= car_count + 1;
            -- Handle decrements
            elsif dec_car_Gout1 = '1' and car_count > 0 then
                car_count <= car_count - 1;
            elsif dec_car_Gout2 = '1' and car_count > 0 then
                car_count <= car_count - 1;
            end if;
        end if;
    end process;

    -- Entry permission logic with priority system
    -- Gate 1 can enter if there's at least 1 spot available
    can_enter_Gin1 <= '1' when car_count < PARKING_CAPACITY else '0';
    
    -- Gate 2 can enter only if there are at least 2 spots available OR 
    -- if Gate 1 is not currently detecting a car (your priority requirement)
    can_enter_Gin2 <= '1' when (car_count < PARKING_CAPACITY - 1) or 
                               (car_count = PARKING_CAPACITY - 1 and sensor_A_Gin1 = '0') 
                         else '0';

    -- Exit permission logic
    can_exit_Gout1 <= '1' when car_count > 0 else '0';
    can_exit_Gout2 <= '1' when car_count > 0 else '0';

    -- Payment signal aggregation
    payment_request <= payment_request_Gout1 or payment_request_Gout2;
    payment_accepted <= payment_accepted_Gout1 or payment_accepted_Gout2;

-- Display and lighting control - CLOCKED VERSION (more reliable)
display_process: process(clk, nrst)
begin
    if nrst = '0' then
        display <= int_to_7seg(PARKING_CAPACITY); -- Show 7 available spots
        Green_Light <= '1';
        Red_Light <= '0';
    elsif rising_edge(clk) then
        -- 7-segment display shows available spots
        display <= int_to_7seg(PARKING_CAPACITY - car_count);
        
        -- Main parking lights
        if car_count < PARKING_CAPACITY then
            Green_Light <= '1';
            Red_Light <= '0';
        else
            Green_Light <= '0';
            Red_Light <= '1';
        end if;
    end if;
end process; --important

end architecture Behavioural;