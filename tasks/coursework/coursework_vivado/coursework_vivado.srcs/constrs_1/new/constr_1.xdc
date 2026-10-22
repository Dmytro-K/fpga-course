# Pynq-Z2
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {led[4]}]

set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports mic_sck]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports mic_ws]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports mic_sd]

set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports reset]

create_clock -period 10 -name sys_clk [get_ports sys_clk]

# KV260
#set_property -dict {PACKAGE_PIN H12 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
#set_property -dict {PACKAGE_PIN B10 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
#set_property -dict {PACKAGE_PIN E10 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
#set_property -dict {PACKAGE_PIN E12 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
#set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
#set_property -dict {PACKAGE_PIN D11 IOSTANDARD LVCMOS33} [get_ports {mic_sck}]
#set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports {mic_ws}]
#set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports {mic_sd}]
