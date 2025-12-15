library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Parking_Controller_TB is
end Parking_Controller_TB;

architecture Behavioral of Parking_Controller_TB is

    -- Constants
    constant CLK_PERIOD : time := 10 ns;
    constant PARKING_CAPACITY : integer := 7;

    -- Component Declaration
    component Parking_Controller
        generic (
            PARKING_CAPACITY : integer := 7
        );
        port (
            clk : in std_logic;
            nrst : in std_logic;
            sensor_A_Gin1 : in std_logic;
            sensor_B_Gin1 : in std_logic;
            sensor_A_Gin2 : in std_logic;
            sensor_B_Gin2 : in std_logic;
            sensor_A_Gout1 : in std_logic;
            sensor_B_Gout1 : in std_logic;
            sensor_A_Gout2 : in std_logic;
            sensor_B_Gout2 : in std_logic;
            payment_done : in std_logic;
            payment_accepted : out std_logic;
            payment_request : out std_logic;
            barrier_Gin1 : out std_logic;
            barrier_Gin2 : out std_logic;
            barrier_Gout1 : out std_logic;
            barrier_Gout2 : out std_logic;
            Green_Light : out std_logic;
            Red_Light : out std_logic;
            display : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Signals
    signal clk : std_logic := '0';
    signal nrst : std_logic := '0';
    
    -- Entry Gate Sensors
    signal sensor_A_Gin1, sensor_B_Gin1 : std_logic := '0';
    signal sensor_A_Gin2, sensor_B_Gin2 : std_logic := '0';
    
    -- Exit Gate Sensors
    signal sensor_A_Gout1, sensor_B_Gout1 : std_logic := '0';
    signal sensor_A_Gout2, sensor_B_Gout2 : std_logic := '0';
    
    -- Payment Interface
    signal payment_done : std_logic := '0';
    signal payment_accepted : std_logic;
    signal payment_request : std_logic;
    
    -- Barrier Controls
    signal barrier_Gin1, barrier_Gin2 : std_logic;
    signal barrier_Gout1, barrier_Gout2 : std_logic;
    
    -- Visual Indicators
    signal Green_Light, Red_Light : std_logic;
    signal display : std_logic_vector(6 downto 0);

    -- Testbench control
    signal simulation_done : boolean := false;
    


begin

    -- Clock generation
    clk_process : process
    begin
        while not simulation_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Instantiate the Unit Under Test (UUT)
    UUT: Parking_Controller
        generic map (
            PARKING_CAPACITY => PARKING_CAPACITY
        )
        port map (
            clk => clk,
            nrst => nrst,
            sensor_A_Gin1 => sensor_A_Gin1,
            sensor_B_Gin1 => sensor_B_Gin1,
            sensor_A_Gin2 => sensor_A_Gin2,
            sensor_B_Gin2 => sensor_B_Gin2,
            sensor_A_Gout1 => sensor_A_Gout1,
            sensor_B_Gout1 => sensor_B_Gout1,
            sensor_A_Gout2 => sensor_A_Gout2,
            sensor_B_Gout2 => sensor_B_Gout2,
            payment_done => payment_done,
            payment_accepted => payment_accepted,
            payment_request => payment_request,
            barrier_Gin1 => barrier_Gin1,
            barrier_Gin2 => barrier_Gin2,
            barrier_Gout1 => barrier_Gout1,
            barrier_Gout2 => barrier_Gout2,
            Green_Light => Green_Light,
            Red_Light => Red_Light,
            display => display
        );

    -- Test process
    test_process : process
        procedure car_enters_gate1(delay_b_sensor: integer) is
        begin
            -- Car arrives at sensor A
            sensor_A_Gin1 <= '1';
            wait for CLK_PERIOD * 2;  -- Increased to ensure detection
            -- Car moves to sensor B
            sensor_B_Gin1 <= '1';
            wait for CLK_PERIOD * delay_b_sensor;
            -- Car clears sensor A
            sensor_A_Gin1 <= '0';
            wait for CLK_PERIOD * 2;
            -- Car clears sensor B
            sensor_B_Gin1 <= '0';
            wait for CLK_PERIOD * 2;  -- Added extra wait
        end procedure;

        procedure car_enters_gate2(delay_b_sensor: integer) is
        begin
            sensor_A_Gin2 <= '1';
            wait for CLK_PERIOD * 2;  -- Increased to ensure detection
            sensor_B_Gin2 <= '1';
            wait for CLK_PERIOD * delay_b_sensor;
            sensor_A_Gin2 <= '0';
            wait for CLK_PERIOD * 2;
            sensor_B_Gin2 <= '0';
            wait for CLK_PERIOD * 2;  -- Added extra wait
        end procedure;

        procedure car_exits_gate1(payment_delay: integer) is
        begin
            -- Car arrives at exit sensor A
            sensor_A_Gout1 <= '1';
            wait for CLK_PERIOD * 3;  -- Increased wait
            -- Wait for payment
            wait for CLK_PERIOD * payment_delay;
            payment_done <= '1';
            wait for CLK_PERIOD * 2;  -- Ensure payment is seen
            payment_done <= '0';
            -- Car moves to sensor B
            sensor_B_Gout1 <= '1';
            wait for CLK_PERIOD * 3;  -- Increased wait
            -- Car clears sensor A
            sensor_A_Gout1 <= '0';
            wait for CLK_PERIOD * 3;  -- Increased wait
            -- Car clears sensor B
            sensor_B_Gout1 <= '0';
            wait for CLK_PERIOD * 2;  -- Added extra wait
        end procedure;

        procedure car_exits_gate2(payment_delay: integer) is
        begin
            sensor_A_Gout2 <= '1';
            wait for CLK_PERIOD * 3;  -- Increased wait
            wait for CLK_PERIOD * payment_delay;
            payment_done <= '1';
            wait for CLK_PERIOD * 2;  -- Ensure payment is seen
            payment_done <= '0';
            sensor_B_Gout2 <= '1';
            wait for CLK_PERIOD * 3;  -- Increased wait
            sensor_A_Gout2 <= '0';
            wait for CLK_PERIOD * 3;  -- Increased wait
            sensor_B_Gout2 <= '0';
            wait for CLK_PERIOD * 2;  -- Added extra wait
        end procedure;

    begin
        -- Initialize
        nrst <= '0';
        wait for CLK_PERIOD * 3;  -- Increased reset time
        nrst <= '1';
        wait for CLK_PERIOD * 2;



        -- 1. First car arrives at GATE_IN 1
        car_enters_gate1(2);
        wait for CLK_PERIOD * 3;

        -- 2. Second car arrives after 5 clocks at GATE_IN 2
        wait for CLK_PERIOD * 5;
        car_enters_gate2(2);
        wait for CLK_PERIOD * 3;
         

        -- 3. Third car arrives after 5 clocks at GATE_IN 2
        wait for CLK_PERIOD * 5;
        car_enters_gate2(2);
        wait for CLK_PERIOD * 3;

        -- 4. Car exits from GATE_OUT 2 with payment after 2 clocks
        wait for CLK_PERIOD * 3;
        car_exits_gate2(2);
        wait for CLK_PERIOD * 3;

        -- 5. Multiple cars arrive to fill the parking (1 clock apart)
        wait for CLK_PERIOD * 3;
        
        -- We need to fill from current count to capacity
        -- Let's add more cars to ensure we reach capacity
        for i in 1 to 5 loop  -- Increased to 5 cars
            if i mod 2 = 1 then
                car_enters_gate1(1);  -- Odd cars at gate1
            else
                car_enters_gate2(1);  -- Even cars at gate2
            end if;
            wait for CLK_PERIOD;  -- 1 clock between arrivals
        end loop;

        -- Check if parking is full
        wait for CLK_PERIOD * 5;
        
       

        -- 6. Car arrives at full parking at GATE_IN 1, waits 3 clocks and leaves
        wait for CLK_PERIOD * 2;
        sensor_A_Gin1 <= '1';  -- Car arrives
        wait for CLK_PERIOD * 3;
        sensor_A_Gin1 <= '0';  -- Car leaves without entering
        wait for CLK_PERIOD * 3;

        -- 7. Car 'K' arrives at GATE_IN2, waits 7 clocks, then enters when space becomes available
        wait for CLK_PERIOD * 6;
        sensor_A_Gin2 <= '1';  -- Car K arrives
        
        -- Wait 7 clocks (car K waiting)
        wait for CLK_PERIOD * 7;
        
        -- During the wait, a car exits from GOUT1
        car_exits_gate1(2);  -- Takes 2 clocks to pay
        
        -- Car K should now be able to enter
        wait for CLK_PERIOD * 2;
        sensor_B_Gin2 <= '1';  -- Car K starts entering
        wait for CLK_PERIOD * 2;
        sensor_A_Gin2 <= '0';
        wait for CLK_PERIOD * 2;
        sensor_B_Gin2 <= '0';
        wait for CLK_PERIOD * 3;

        -- 8. After 3 clocks, one car exits from GOUT1
        wait for CLK_PERIOD * 3;
        car_exits_gate1(2);
        wait for CLK_PERIOD * 3;

        -- 9. Two cars arrive simultaneously for the last spot (testing priority)
        wait for CLK_PERIOD * 5;
        
        -- Both cars arrive at the same clock cycle
        sensor_A_Gin1 <= '1';
        sensor_A_Gin2 <= '1';
        wait for CLK_PERIOD * 2;
        
        -- Only Gate1 should proceed
        sensor_B_Gin1 <= '1';  -- Gate1 car enters
        wait for CLK_PERIOD * 2;
        sensor_A_Gin1 <= '0';
        wait for CLK_PERIOD * 2;
        sensor_B_Gin1 <= '0';
        
        -- Gate2 car should still be waiting (sensor A still high)
        wait for CLK_PERIOD * 2;
        sensor_A_Gin2 <= '0';  -- Gate2 car leaves
        wait for CLK_PERIOD * 2;

        -- 10. After 4 clocks, exit 2 cars simultaneously using both exit gates
        wait for CLK_PERIOD * 4;
        
        -- Start both exits at the same time
        sensor_A_Gout1 <= '1';
        sensor_A_Gout2 <= '1';
        wait for CLK_PERIOD * 3;
        
        -- Process payments with proper timing
        wait for CLK_PERIOD * 2;
        payment_done <= '1';  -- Pay for both gates
        wait for CLK_PERIOD * 2;
        payment_done <= '0';
        
        -- Both cars move through barriers
        wait for CLK_PERIOD * 2;
        sensor_B_Gout1 <= '1';
        sensor_B_Gout2 <= '1';
        wait for CLK_PERIOD * 3;
        sensor_A_Gout1 <= '0';
        sensor_A_Gout2 <= '0';
        wait for CLK_PERIOD * 3;
        sensor_B_Gout1 <= '0';
        sensor_B_Gout2 <= '0';
        
        wait for CLK_PERIOD * 5;

        report "=== TEST COMPLETE ===";
        simulation_done <= true;
        wait;
    end process;



end Behavioral;