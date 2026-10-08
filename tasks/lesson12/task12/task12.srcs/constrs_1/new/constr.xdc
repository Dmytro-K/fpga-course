set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 } [get_ports { gpio_data[0] }];
set_property -dict { PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 } [get_ports { gpio_data[1] }];
set_property -dict { PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 } [get_ports { gpio_data[2] }];
set_property -dict { PACKAGE_PIN Y17 IOSTANDARD LVCMOS33 } [get_ports { gpio_data[3] }];
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { gpio_data[4] }];
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports { gpio_data[5] }];
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports { gpio_data[6] }];
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports { gpio_data[7] }];
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports { gpio_data[8] }];

set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports { gpio_btn }];

create_clock -add -name sys_clk_pin -period 10 [get_ports { clk }];