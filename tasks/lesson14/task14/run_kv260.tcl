connect

# Наступний скид — у режимі JTAG-завантаження, щоб прошивка з QSPI не запускалась.
# Регістр живе лише до вимкнення живлення, у flash нічого не пишеться.
targets -set -nocase -filter {name =~ "*PSU*"}
mwr 0xff5e0200 0x0100
rst -system
after 1000

# Bitstream у PL
fpga -file design_1_wrapper.bit

# Ініціалізація PS: такти (зокрема pl_clk0 = 100 МГц), MIO, DDR
targets -set -nocase -filter {name =~ "*PSU*"}
configparams force-mem-access 1
source psu_init.tcl
psu_init
after 500
psu_ps_pl_isolation_removal
after 500
psu_ps_pl_reset_config    ;# відпускає pl_resetn0 → лічильник стартує
