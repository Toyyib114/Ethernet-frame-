transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Progressive/Documents/CHIPMANGO/ETHERNET\ PROJECT/new\ with\ crc {C:/Users/Progressive/Documents/CHIPMANGO/ETHERNET PROJECT/new with crc/Ethernet_tx.v}
vlog -vlog01compat -work work +incdir+C:/Users/Progressive/Documents/CHIPMANGO/ETHERNET\ PROJECT/new\ with\ crc {C:/Users/Progressive/Documents/CHIPMANGO/ETHERNET PROJECT/new with crc/Ethernet_rx.v}
vlog -vlog01compat -work work +incdir+C:/Users/Progressive/Documents/CHIPMANGO/ETHERNET\ PROJECT/new\ with\ crc {C:/Users/Progressive/Documents/CHIPMANGO/ETHERNET PROJECT/new with crc/Ethernet_tx_rx.v}

vlog -vlog01compat -work work +incdir+C:/Users/Progressive/Documents/CHIPMANGO/ETHERNET\ PROJECT/new\ with\ crc {C:/Users/Progressive/Documents/CHIPMANGO/ETHERNET PROJECT/new with crc/Ethernet_tx_rx_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L maxv_ver -L rtl_work -L work -voptargs="+acc"  Ethernet_tx_rx_tb

add wave *
view structure
view signals
run -all
