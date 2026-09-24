// tb_top_wrapper.v
// Testbench для ПОВНОГО проєкту (design_1_wrapper): MicroBlaze +
// AXI GPIO x3 (LED/BTN/SW) -- УСЕ РАЗОМ, в одній Behavioral
// Simulation, з реальним .elf, пов'язаним через Associate ELF files.
//
// МІСЦЯ, ПОЗНАЧЕНІ "ПЕРЕВІРИТИ" -- залежать від того, як САМЕ
// Vivado назве порти у ВАШІЙ конкретній збірці. Відкрийте
// згенерований design_1_wrapper.v і звірте реальні назви перед
// запуском.

`timescale 1ns / 100ps

module tb_top_wrapper;

    // ---- Такт і reset -- ПЕРЕВІРИТИ реальну назву порту такту у
    // вашій обгортці (залежить від джерела такту, обраного при
    // Block Automation) ----
    // ---- Диференційний такт -- ПЕРЕВІРИТИ реальні назви портів
    // (типово diff_clock_rtl_p/diff_clock_rtl_n чи sys_clk_p/sys_clk_n,
    // залежить від того, як саме назвали цей порт при Make External) ----
    reg clk = 0;
    reg reset = 0;   // ПЕРЕВІРИТИ активний рівень (0 чи 1)

    reg reset_rtl_0 = 0;   // ПЕРЕВІРИТИ активний рівень (0 чи 1)

    // ---- Зовнішні GPIO-порти -- перевірені раніше через Make External ----
    tri  [3:0] btn_tri_io_bidir;
    reg  [3:0] btn_tri_io;
    assign btn_tri_io_bidir = btn_tri_io;
//    tri  [1:0] sw_tri_io_bidir;
//    reg  [1:0] sw_tri_io;
//    assign sw_tri_io_bidir = sw_tri_io;
    tri  [3:0] led_tri_io_bidir;
//    wire [3:0] led_tri_io;
//    assign led_tri_io_bidir = led_tri_io;
//    assign led_tri_io = led_tri_io_bidir
    // ---- Інстанціювання ПОВНОЇ верхньої обгортки ----
    // ПЕРЕВІРИТИ точний список портів у вашому файлі design_1_wrapper.v
    mb_1_wrapper dut (
        .clk_in1_0 (clk),   // ПЕРЕВІРИТИ реальну назву
        .reset_rtl_0      (reset_rtl_0),
        .btn_tri_io  (btn_tri_io_bidir),
//        .sw_tri_io   (sw_tri_io_bidir),
        .led_tri_io  (led_tri_io_bidir)
    );

    // ---- Генерація такту (період залежить від реальної частоти
    // вашого проєкту; тут -- приклад для 100 МГц) ----
    always #5 clk = ~clk;
    
    localparam BTN_NO_BTN = 4'b0000;
    localparam BTN_REVERSE = 4'b0001;
    localparam BTN_SPEED_UP = 4'b0010;
    localparam BTN_SPEED_DOWN = 4'b0100;
    localparam BTN_PAUSE = 4'b1000;

    localparam DEBOUNCE_DELAY = 10000;

    // ---- Стимул: імітуємо реальні натискання кнопок ----
    initial begin
        reset_rtl_0 = 0;
//        sw_tri_io  = 2'b00;
        btn_tri_io = BTN_NO_BTN;
        #200;
        reset_rtl_0 = 1;

        // Дати MicroBlaze час "прокинутись" і дійти до while(1) --
        // орієнтовний запас, скоригувати за спостереженням у Waveform
        #100000;

        $display("[%0t] Тест 1: btn=0001", $time);
        btn_tri_io = BTN_REVERSE;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #100000;
        $display("[%0t] led_tri_io_bidir = %b", $time, led_tri_io_bidir);

        $display("[%0t] Тест 2: btn=0100", $time);
        btn_tri_io = BTN_SPEED_DOWN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_DOWN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_DOWN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_DOWN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_DOWN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_DOWN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_DOWN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_DOWN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_DOWN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_DOWN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;

        #100000;
        $display("[%0t] led_tri_io_bidir = %b", $time, led_tri_io_bidir);

        $display("[%0t] Тест 3: btn=0010", $time);
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_SPEED_UP;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;

        #100000;
        $display("[%0t] led_tri_io_bidir = %b", $time, led_tri_io_bidir);

        btn_tri_io = BTN_PAUSE;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;

        #100000;

        btn_tri_io = BTN_PAUSE;
        #DEBOUNCE_DELAY;
        btn_tri_io = BTN_NO_BTN;
        #DEBOUNCE_DELAY;

        #100000;

        $display("Симуляція завершена -- перевірте лог вище й Waveform Viewer");
        $finish;
    end

endmodule
