PCF = icebreaker.pcf

YOSYS_OPTS = -q

SYNTH_ICE40_OPTS = -abc2 -dsp


TOPLEVELS =


.PHONY: all

all: $(addsuffix .bin,$(TOPLEVELS))


# verification

%.vvp: %.v
	iverilog -o $@ $^

.PRECIOUS: %.vvp

%.run: %.vvp
	@vvp $<

%.stop: %.vvp
	@vvp -s $<


# synthesis

%.json: %.v
	yosys $(YOSYS_OPTS) -p "synth_ice40 $(SYNTH_ICE40_OPTS) -json $@" $<

%.asc: %.json $(PCF)
	nextpnr-ice40 --up5k --package sg48 --json $< --pcf $(PCF) --asc $@

%.bin: %.asc
	icepack $< $@

.PRECIOUS: %.bin

%.prog: %.bin
	iceprog $<


# various commands to inspect the synthesis process

%.inspect: %.v
	yosys $(YOSYS_OPTS) -p "read_verilog $<; synth_ice40 $(SYNTH_ICE40_OPTS); inspect"

%.show: %.v
	yosys $(YOSYS_OPTS) -p "read_verilog $<; synth_ice40 $(SYNTH_ICE40_OPTS); show"

%.synth.v: %.v
	yosys $(YOSYS_OPTS) -p "read_verilog $<; synth_ice40 $(SYNTH_ICE40_OPTS); write_verilog $@"

%.pnr-gui: %.json $(PCF)
	nextpnr-ice40 --up5k --package sg48 --json $< --pcf $(PCF) --gui


# dependencies
